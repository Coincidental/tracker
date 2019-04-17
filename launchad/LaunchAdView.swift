//
//  LaunchAdView.swift
//  Tracker
//
//  Created by StephenLouis on 2019/1/14.
//  Copyright © 2019 StephenLouis. All rights reserved.
//

import UIKit

public class LaunchAdView: UIView {
    
    // MARK: - private
    static var `default` = LaunchAdView(frame: UIScreen.main.bounds)
    var adRequest: ((LaunchAdView)->())?
    var waitTime: Int = 3
    fileprivate var skipBtnConfig: LaunchSkipButtonConfig = LaunchSkipButtonConfig()
    fileprivate var originalTimer: DispatchSourceTimer?
    fileprivate var dataTimer: DispatchSourceTimer?
    fileprivate var adTapAction: LaunchClosure?
    fileprivate var imageResource: LaunchAdImageResourceConfigure?
    fileprivate var skipBtn: LaunchAdButton?
    /// UIApplicationWillEnterForeground Notification.Name
    fileprivate let launchAdAppearTimeStamp = "LaunchAdAppearTimeStamp"
    /// 倒计时结束闭包
    fileprivate var endOfCountDownClosure: LaunchClosure?
    
    /// 加载图片, 网络图片/本地图片/GIF图片
    ///
    /// - Parameters:
    ///   - imageResource: 配置图片资源
    ///   - buttonConfig:  配置跳过按钮
    ///   - action:        广告点击响应
    @objc public func setImageResource(_ imageResource: LaunchAdImageResourceConfigure,
                                       buttonConfig: LaunchSkipButtonConfig? = nil,
                                       action: LaunchClosure?)
    {
        if let buttonConfig = buttonConfig { skipBtnConfig = buttonConfig }
        self.imageResource = imageResource
        adTapAction = action
        addAdImageView()
    }
    
    /// 倒计时结束回调
    @objc public func endOfCountDown(_ action: LaunchClosure?) {
        self.endOfCountDownClosure = action
    }
    
    fileprivate lazy var launchAdImgView: LaunchAdImageView = {
        let imgView = LaunchAdImageView(frame: .zero)
        imgView.adImageViewClick = { [weak self] in
            self?.launchAdTapAction()
        }
        return imgView
    }()
    
    fileprivate func launchAdTapAction() {
        if adTapAction != nil {
            launchAdVCRemove() {
                self.adTapAction!()
            }
        }
    }
    
    /// 出现
    @objc fileprivate func show() {
        UIApplication.shared.keyWindow?.addSubview(self)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        let launchImageView = LaunchAdImageView(frame: UIScreen.main.bounds)
        addSubview(launchImageView)
    }
    
    func appear(showEnterForeground: Bool, timeForWillEnterForeground: Double = 10, customNotificationName: String? = nil) {
        if showEnterForeground {
            NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: nil){ _ in
                /// 上次出现的时间戳
                let lastAppearTimeStamp = UserDefaults.standard.double(forKey: self.launchAdAppearTimeStamp)
                let currentTimeStamp = self.getSystemTimestamp()
                if currentTimeStamp - lastAppearTimeStamp > timeForWillEnterForeground * 1000 {
                    self.show()
                }
            }
            NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: nil) { (_) in
                // 记录时间戳
                UserDefaults.standard.set(self.getSystemTimestamp(), forKey: self.launchAdAppearTimeStamp)
            }
        } else if customNotificationName != nil {
            NotificationCenter.default.addObserver(self, selector: #selector(show), name: NSNotification.Name(customNotificationName!), object: nil)
        }
    }
    
    public override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        if newWindow != nil {
            frame = UIScreen.main.bounds
            startTimer()
            if adRequest != nil {
                adRequest!(self)
            } else {
                addAdImageView()
            }
        }
    }
    
    /// 获取系统时间戳
    fileprivate func getSystemTimestamp() -> Double {
        let date = Date()
        let time = String(format: "%.3f", date.timeIntervalSince1970)
        let timeSp = time.replacingOccurrences(of: ".", with: "") as NSString
        return timeSp.doubleValue
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("dealloc")
    }
}

// MARK: - setup subview
extension LaunchAdView {
    fileprivate func addAdImageView() {
        guard let imageResource = imageResource,
            let imageNameOrImageURL = imageResource.imageNameOrImageURL,
            imageNameOrImageURL != "" else {
                return
        }
        launchAdImgView.frame = imageResource.imageFrame
        addSubview(launchAdImgView)
        if imageNameOrImageURL.contains("http://") || imageNameOrImageURL.contains("https://") {
            launchAdImgView.setImage(with: imageNameOrImageURL, options: imageResource.imageOptions) {
                self.setImage(duration: imageResource.imageDuration)
            }
        } else if imageNameOrImageURL.contains(".gif") {
            launchAdImgView.setGifImage(named: imageNameOrImageURL) {
                self.setImage(duration: imageResource.imageDuration)
            }
        } else {
            launchAdImgView.image = UIImage(named: imageNameOrImageURL)
            setImage(duration: imageResource.imageDuration)
        }
    }
    
    fileprivate func setImage(duration: Int) {
        let adDuration = max(1, duration)
        skipBtn = LaunchAdButton(type: .custom)
        skipBtn?.titleLabel?.textAlignment = .center
        skipBtn?.addTarget(self, action: #selector(skipBtnClick), for: .touchUpInside)
        skipBtn?.setSkipApperance(skipBtnConfig)
        addSubview(skipBtn!)
        if originalTimer?.isCancelled == true { return }
        adStartTimer(adDuration)
    }
    
    @objc fileprivate func skipBtnClick() {
        launchAdVCRemove()
    }
}

// MARK: - remove
extension LaunchAdView {
    fileprivate func launchAdVCRemove(completion: LaunchClosure? = nil) {
        if originalTimer?.isCancelled == false { originalTimer?.cancel() }
        if dataTimer?.isCancelled == false { dataTimer?.cancel() }
        LaunchAdAnimation().animationType(imageResource?.animationType ?? .crossDissolve, animationView: self, animationClosure: {
            for (index, view) in self.subviews.enumerated() {
                if index != 0 {
                    view.removeFromSuperview()
                }
            }
            self.skipBtn = nil
            self.removeFromSuperview()
        })
        /// #10 有没有倒计时结束时的回调函数
        if endOfCountDownClosure != nil {
            endOfCountDownClosure!()
        }
        if completion != nil {
            completion!()
        }
    }
}

extension LaunchAdView {
    fileprivate func startTimer() {
        var duration: Int = waitTime
        originalTimer = DispatchSource.makeTimerSource(flags: [], queue: .global())
        originalTimer?.schedule(deadline: .now(), repeating: .seconds(1), leeway: .milliseconds(duration))
        originalTimer?.setEventHandler(handler: {
            if duration == 0 {
                DispatchQueue.main.async {
                    self.launchAdVCRemove()
                }
                return
            }
            duration -= 1
        })
        originalTimer?.resume()
    }
    
    fileprivate func adStartTimer(_ duration: Int) {
        var adDuration = duration
        dataTimer = DispatchSource.makeTimerSource(flags: [], queue: .global())
        dataTimer?.schedule(deadline: .now(), repeating: .seconds(1), leeway: .milliseconds(adDuration))
        dataTimer?.setEventHandler(handler: {
            DispatchQueue.main.async {
                if self.originalTimer?.isCancelled == false {
                    self.originalTimer?.cancel()
                }
                self.skipBtn?.setDuration(adDuration)
                if adDuration == 0 {
                    self.launchAdVCRemove()
                    return
                }
                adDuration -= 1
            }
        })
        dataTimer?.resume()
    }
}


