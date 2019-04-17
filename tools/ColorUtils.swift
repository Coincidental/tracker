//
//  ColorUtils.swift
//  Tracker
//
//  Created by StephenLouis on 2018/11/19.
//  Copyright © 2018 StephenLouis. All rights reserved.
//

import UIKit

let kWhite        = UIColor.white
let kRed          = UIColor.red
let kOrange       = UIColor.orange
let kBlack        = UIColor.black
let kGreen        = UIColor.green
let kPurple       = UIColor.purple
let kBlue         = UIColor.blue

// 主题色 MainOrange

// 更新时间渐变色数组
let timeStartColor = colorWithRGBA(255, 255, 255, 1.0)
let timeEndColor = colorWithRGBA(255, 255, 255, 0.5)
let kGradientTimeColors: [CGColor] = [timeStartColor.cgColor, timeEndColor.cgColor]

func colorValue(_ value: CGFloat) -> CGFloat {
    return value / 255.0
}

/// UIColor, 通过 RGBA数值设置颜色
///
/// - Parameters:
///    - red:   红色值
///    - green: 绿色值
///    - blue:  蓝色值
///    - alpha: 透明度
func colorWithRGBA(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat, _ alpha: CGFloat) -> UIColor {
    return UIColor(red: colorValue(red), green: colorValue(green), blue: colorValue(blue), alpha: alpha)
}

func setGradualChangColor(frame: CGRect, gradientColors: [Any]?) -> CAGradientLayer {
    let gradientLayer = CAGradientLayer()
    gradientLayer.frame = frame
    gradientLayer.colors = gradientColors
    gradientLayer.startPoint = CGPoint(x: 0, y: 0)
    gradientLayer.endPoint = CGPoint(x: 0, y: 1)
    gradientLayer.locations = [0,1]
    return gradientLayer
}
