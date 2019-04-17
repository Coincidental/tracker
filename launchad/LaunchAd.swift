//
//  LaunchAd.swift
//  Tracker
//
//  Created by StephenLouis on 2019/1/15.
//  Copyright © 2019 StephenLouis. All rights reserved.
//

import UIKit

@objc public class LaunchAd: NSObject {
    
    /// 创建广告view --- 进入前台时显示
    ///
    /// - Parameters:
    ///   - waitTime: 加载广告等待的时间，默认3s
    ///   - showEnterForeground: 是否进入前台时显示，默认’false‘
    ///   - timeForWillEnterForeground: 控制进入后台到前台显示的时间
    ///   - adNetRequest: 广告网络请求。如果需要每次进入前台是显示不同的广告图片，网络请求写在此闭包中
    /// - Returns: LaunchAdView
    @discardableResult
    @objc public class func create(waitTime: Int = 3,
                                   showEnterForeground: Bool = false,
                                   timeForWillEnterForeground: Double = 10,
                                   adNetRequest: ((LaunchAdView)->())? = nil) -> LaunchAdView
    {
        let launchAdView: LaunchAdView
        if showEnterForeground {
            launchAdView = LaunchAdView.default
            launchAdView.appear(showEnterForeground: showEnterForeground, timeForWillEnterForeground: timeForWillEnterForeground)
        } else {
            launchAdView = LaunchAdView()
            launchAdView.appear(showEnterForeground: false, timeForWillEnterForeground: timeForWillEnterForeground)
        }
        launchAdView.adRequest = adNetRequest
        launchAdView.waitTime = waitTime
        UIApplication.shared.keyWindow?.addSubview(launchAdView)
        return launchAdView
    }
    
    /// 创建广告view --- 自定义通知控制出现
    ///
    /// - Parameters:
    ///   - waitTime: 加载广告等待的时间，默认3s
    ///   - customNotificationName: 自定义通知名称
    ///   - adNetRequest: 广告网络请求。如果需要每次进入前台时显示不同的网络图片，网络请求卸载此闭包中
    /// - Returns: LaunchAdView
    @discardableResult
    @objc public class func create(waitTime: Int = 3,
                                   customNotificationName: String?,
                                   adNetRequst: ((LaunchAdView)->())? = nil) -> LaunchAdView
    {
        let launchAdView: LaunchAdView = LaunchAdView.default
        launchAdView.appear(showEnterForeground: false, customNotificationName: customNotificationName)
        launchAdView.adRequest = adNetRequst
        launchAdView.waitTime = waitTime
        UIApplication.shared.keyWindow?.addSubview(launchAdView)
        return launchAdView
    }
    
    // MARK: - 清楚缓存
    /// 清楚全部缓存
    @objc public class func clearDiskCache() {
        LaunchAdClearDiskCache()
    }
    
    /// 清楚指定url缓存
    ///
    /// - Parameter urlArray: url数组
    @objc public class func clearDiskCacheWithImageUrlArray(_ urlArray: Array<String>) {
        LaunchAdClearDiskCacheWithImageUrlArray(urlArray)
    }
}
