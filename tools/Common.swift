//
//  Common.swift
//  Tracker
//
//  Created by StephenLouis on 2018/10/26.
//  Copyright © 2018 StephenLouis. All rights reserved.
//

import UIKit
import SnapKit

var kScreenW = UIScreen.main.bounds.size.width
var kScreenH = UIScreen.main.bounds.size.height

// 判断是不是 iPhone X
let isIphoneX = kScreenH >= 812 ? true : false
// 状态栏高度
let kStatusHeight: CGFloat = isIphoneX ? 44 : 20
// 导航栏高度
let kNavigationBarHeight: CGFloat = 44
// TabBar高度
let kTabBarHeight: CGFloat = isIphoneX ? 49 + 34 : 49

// 隐藏导航栏
let kNavBarHidden: [String: String] = ["isHidden": "true"]
// 显示导航栏
let kNavBarNotHidden: [String: String] = ["isHidden": "false"]

// 宽度比
let kWidthRatio = kScreenW / 375.0
// 高度比
let kHeightRatio = kScreenH / 667.0

// 基本Url
let kBaseUrl = "http://125.254.153.166/"
// 登录Url
let kLoginUrl = "\(kBaseUrl)tracker/user/demo/login"
// 绑定设备Url
let kBindUrl = "\(kBaseUrl)tracker/bind?"
// 查询单个设备
let kDeviceInfoUrl = "\(kBaseUrl)tracker/showBind?"
// 查询全部设备
let kDeviceListUrl = "\(kBaseUrl)tracker/showAllBind?"
// 运营位
let kOperatorUrl = "\(kBaseUrl)tracker/ad/show"
// 图片下载
let kImageDownloadUrl = "\(kBaseUrl)upload/ad/"
// 解绑单个设备
let kUnbindUrl = "\(kBaseUrl)tracker/unBind?"

// 魔镜账号接口
let kBaseMagicUrl = "http://222.190.139.10:7070/magicRest"
// 获取验证码
let kMagicSmsCode = "\(kBaseMagicUrl)/accountRest/getSmsCode"
// 注册账号
let kMagicRegister = "\(kBaseMagicUrl)/accountRest/registerMagic"
// 登录账号
let kMagicLogin = "\(kBaseMagicUrl)/accountRest/loginMagic"
// 查询账号
let kMagicfindAccount = "\(kBaseMagicUrl)/accountRest/findAccount"
// 查询账号详情
let kMagicAccountDetail = "\(kBaseMagicUrl)/accountRest/findAccountDetail"
// 修改账号
let kMagicAccountUpdate = "\(kBaseMagicUrl)/accountRest/updateAccount"
// 找回密码
let kMagicFindPassword = "\(kBaseMagicUrl)/accountRest/findPassword"
// 注销账号
let kMagicDelAccount = "\(kBaseMagicUrl)/accountRest/delAccount"

// 电池状态
let kBatteryNormal = 0   // 正常
let kBatteryLightSleep = 1 // 浅睡
let kBatteryDeepSleep = 2 // 深睡
let kBatteryLowLevel = 3 // 离线

let kBatteryCharging = 1

// 个人中心cell参数
// 功能图片到左边界的距离
let kFuncImgToLeftGap: CGFloat = 15
// 功能名称字体
let kFuncLabelFont: CGFloat = 14.0
// 功能名称到功能图片的距离，当功能图片funcImg不存在时，等于到左边界的距离
let kFuncLabelToFuncImgGap: CGFloat = 15
// 指示箭头或开关到右边界的距离
let kIndicatorToRightGap: CGFloat = 15
// 详情文字字体
let kDetailLabelFont: CGFloat = 12.0
// 详情到指示箭头或开关的距离
let kDetailViewToIndicatorGap: CGFloat = 13

// 自适应
func Adapt(_ value: CGFloat) -> CGFloat {
    return AdaptW(value)
}

// 自适应宽度
func AdaptW(_ value: CGFloat) -> CGFloat {
    return ceil(value) * kWidthRatio
}

// 自适应高度
func AdaptH(_ value: CGFloat) -> CGFloat {
    return ceil(value) * kHeightRatio
}

extension UIButton {
    @objc func set(image anImage: UIImage?, title: String, titlePosition: UIView.ContentMode, additionalSpacing: CGFloat, state: UIControl.State) {
        
        self.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.center
        self.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
        
        self.setImage(anImage, for: state)
        self.setTitle(title, for: state)
        positionLabelRespectToImage(title,position: titlePosition, spacing: additionalSpacing)
        
    }
    
    private func positionLabelRespectToImage(_ title: String, position: UIView.ContentMode, spacing: CGFloat) {
        let imageSize = self.imageView?.intrinsicContentSize
        let imageWidth = imageSize?.width
        let imageHeight = imageSize?.height
        
        let labelSize = self.titleLabel?.intrinsicContentSize
        let labelWidth = labelSize?.width
        let labelHeight = labelSize?.height
        
        var titleTop: CGFloat
        var titleLeft: CGFloat
        var titleBottom: CGFloat
        var titleRight: CGFloat
        
        var imageTop: CGFloat
        var imageLeft: CGFloat
        var imageBottom: CGFloat
        var imageRight: CGFloat
        
        switch position {
        case .top:
            // 文字在上，图片在下
            imageLeft = (imageWidth! + labelWidth!) / 2.0 - imageWidth! / 2.0
            imageRight = -labelWidth!/2.0
            imageBottom = -(labelHeight!/2.0 + spacing/2.0)
            imageTop = labelHeight!/2.0 + spacing/2.0
            
            titleTop = -(imageHeight!/2.0 + spacing/2.0)
            titleBottom = imageHeight!/2.0 + spacing/2.0
            titleLeft = -imageWidth!/2.0
            titleRight = imageWidth!/2.0
        case .bottom:
            // 文字在下，图片在上
            imageTop = -(labelHeight!/2.0 + spacing/2.0)
            imageBottom = 0
            imageLeft = labelWidth!/2.0 - 7
            imageRight = 0
            
            titleLeft = -imageWidth!/2.0 - 10
            titleRight = 0
            titleTop = imageHeight!/2.0 + spacing/2.0
            titleBottom = 0
        case .left:
            // 文字在左，图片在右
            imageTop = 0
            imageBottom = 0
            imageRight = -(labelWidth! + spacing/2.0)
            imageLeft = labelWidth! + spacing/2.0
            
            titleTop = 0
            titleBottom = 0
            titleLeft = -(labelWidth! + spacing/2.0)
            titleRight = labelWidth! + spacing/2.0
            
        case .right:
            // 文字在右，图片在左
            imageTop = 0
            imageBottom = 0
            imageLeft = -spacing/2.0
            imageRight = 0
            
            titleTop = 0
            titleBottom = 0
            titleLeft = spacing/2.0
            titleRight = 0
        default:
            // 原始
            titleTop = 0
            titleLeft = 0
            titleBottom = 0
            titleRight = 0
            
            imageTop = 0
            imageLeft = 0
            imageBottom = 0
            imageRight = 0
        }
        
        self.titleEdgeInsets = UIEdgeInsets(top: titleTop, left: titleLeft, bottom: titleBottom, right: titleRight)
        self.imageEdgeInsets = UIEdgeInsets(top: imageTop, left: imageLeft, bottom: imageBottom, right: imageRight)
    }
}
