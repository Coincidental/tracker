//
//  UnbindViewController.swift
//  Tracker
//
//  Created by StephenLouis on 2018/12/26.
//  Copyright © 2018 StephenLouis. All rights reserved.
//

import Foundation
import SwiftyJSON

protocol UnbindDeviceCallback {
    func unbindDeviceCallback()
}

class UnbindViewController: UIViewController {
    
    var token: String?
    var trackerNumber: String?
    
    var navBgView: UIView!
    var navIcon: UIImageView!
    var navTitle: UILabel!
    var navLine: UIView!

    var deviceBgView: UIView!
    var deviceIcon: UIImageView!
    var deviceTitle: UILabel!
    var deviceNum: UILabel!
    var unbind: UIButton!
    
    var unbindCallback: UnbindDeviceCallback?
    
    override func viewDidLoad() {
        self.view.backgroundColor = colorWithRGBA(241.0, 243.0, 244.0, 1.0)

        initNavView()
        initView()
    }
    
    fileprivate func initNavView() {
        navBgView = UIView()
        navBgView.backgroundColor = colorWithRGBA(255, 255, 255, 1.0)
        self.view.addSubview(navBgView)
        navBgView.snp.makeConstraints{ make in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(kStatusHeight + kNavigationBarHeight)
        }
        
        navIcon = UIImageView(image: UIImage(named: "icon_back04"))
        navIcon.contentMode = .scaleAspectFit
        self.navBgView.addSubview(navIcon)
        navIcon.snp.makeConstraints{ make in
            make.top.equalTo(kStatusHeight + 8)
            make.left.equalTo(AdaptW(10))
            make.width.equalTo(AdaptW(25))
            make.height.equalTo(AdaptH(20))
        }
        let exitClick1 = UITapGestureRecognizer(target: self, action: #selector(exit))
        exitClick1.numberOfTapsRequired = 1
        exitClick1.numberOfTouchesRequired = 1
        navIcon.isUserInteractionEnabled = true
        navIcon.addGestureRecognizer(exitClick1)
        
        navTitle = UILabel()
        navTitle.text = "设置"
        navTitle.font = UIFont.boldSystemFont(ofSize: 22)
        navTitle.textColor = colorWithRGBA(61.0, 87.0, 132.0, 1.0)
        self.navBgView.addSubview(navTitle)
        navTitle.snp.makeConstraints{ make in
            make.top.equalTo(kStatusHeight + 7)
            make.left.equalTo(AdaptW(40))
            make.width.equalTo(AdaptW(50))
            make.height.equalTo(AdaptH(20))
        }
        let exitClick2 = UITapGestureRecognizer(target: self, action: #selector(exit))
        exitClick2.numberOfTapsRequired = 1
        exitClick2.numberOfTouchesRequired = 1
        navTitle.isUserInteractionEnabled = true
        navTitle.addGestureRecognizer(exitClick2)
        
        navLine = UIView()
        navLine.backgroundColor = colorWithRGBA(191.0, 195.0, 199.0, 1.0)
        self.navBgView.addSubview(navLine)
        navLine.snp.makeConstraints{ make in
            make.top.equalTo(kStatusHeight + kNavigationBarHeight)
            make.left.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(AdaptH(1))
        }
    }
    
    fileprivate func initView() {
        deviceBgView = UIView()
        deviceBgView.backgroundColor = colorWithRGBA(255, 255, 255, 1.0)
        self.view.addSubview(deviceBgView)
        deviceBgView.snp.makeConstraints{ make in
            make.top.equalTo(kStatusHeight+kNavigationBarHeight+15)
            make.left.equalToSuperview()
            make.height.equalTo(AdaptH(50))
            make.width.equalToSuperview()
        }
        
        deviceIcon = UIImageView(image: UIImage(named: "number"))
        deviceIcon.contentMode = .scaleAspectFit
        self.deviceBgView.addSubview(deviceIcon)
        deviceIcon.snp.makeConstraints{ make in
            make.centerY.equalToSuperview()
            make.centerX.equalTo(AdaptW(30))
            make.width.equalTo(AdaptW(40))
            make.height.equalTo(AdaptH(40))
        }
        
        deviceTitle = UILabel()
        deviceTitle.text = "设备编号"
        self.deviceBgView.addSubview(deviceTitle)
        deviceTitle.snp.makeConstraints{ make in
            make.centerY.equalToSuperview()
            make.centerX.equalTo(AdaptW(100))
            make.width.equalTo(AdaptW(90))
            make.height.equalTo(AdaptH(45))
        }
        
        deviceNum = UILabel()
        deviceNum.textColor = colorWithRGBA(0, 0, 0, 0.45)
        deviceNum.text = trackerNumber!
        self.deviceBgView.addSubview(deviceNum)
        deviceNum.snp.makeConstraints{ make in
            make.centerY.equalToSuperview()
            make.left.equalTo(AdaptW(250))
            make.width.equalTo(AdaptW(90))
            make.height.equalTo(AdaptH(45))
        }
        
        unbind = UIButton()
        unbind.layer.cornerRadius = 20
        unbind.setTitle("解绑设备", for: .normal)
        unbind.backgroundColor = UIColor.white
        unbind.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        unbind.setTitleColor(colorWithRGBA(255, 159, 103, 1.0), for: .normal)
        self.view.addSubview(unbind)
        unbind.snp.makeConstraints{ make in
            make.centerX.equalTo(kScreenW / 2)
            make.centerY.equalTo(AdaptH(625))
            make.width.equalTo(AdaptW(160))
            make.height.equalTo(AdaptH(40))
        }
        unbind.addTarget(self, action: #selector(unbindDevice), for: .touchUpInside)
    }
    
    @objc func unbindDevice() {
        print("unbindDevice")
        var alert: UIAlertController!
        alert = UIAlertController(title: "是否确认要解绑当前设备?", message: nil, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        let bindAciton = UIAlertAction(title: "解绑", style: .default, handler: {
            action in
            // 解绑设备
            self.unbindDeviceWith(token: self.token!, trackerNumber: self.trackerNumber!)
        })
        alert.addAction(cancelAction)
        alert.addAction(bindAciton)
        self.present(alert,animated: true,completion: nil)
    }
    
    @objc func exit() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func unbindDeviceWith(token: String, trackerNumber: String) {
        let timestamp = Utils.getNowTimeStamp()
        let params = "token=\(token)&timestamp=\(timestamp)&trackerNumber=\(trackerNumber)"
        let sign = DataEncoding.Encode_AES_ECB(strToEncode: params)
        let urlString = "\(kUnbindUrl)token=\(token)&timestamp=\(timestamp)&trackerNumber=\(trackerNumber)&sign=\(sign)"
        let url = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        NetworkTools.shared.request(method: .POST, urlString: url!, parameters: nil) { (responseObject, error) in
            if error != nil {
                print(error!)
                return
            }
            
            if responseObject != nil {
                print(JSON(responseObject as Any))
                let responseBase = ResponseBase(jsonData: JSON(responseObject as Any))
                if responseBase.code! == 400 {
                    self.unbindCallback?.unbindDeviceCallback()
                    // 解绑成功后销毁两个viewController
                    self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
}
