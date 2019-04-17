//
//  TrackerBatteryView.swift
//  Tracker
//
//  Created by StephenLouis on 2018/11/21.
//  Copyright © 2018 StephenLouis. All rights reserved.
//

import UIKit

class TrackerBatteryView: UIView {
    
    var batteryLevel: Int = 95
    
    var viewWidth: CGFloat = 0
    var viewHeight: CGFloat = 0
    
    var strokeColor: CGColor = UIColor.green.cgColor
    var fillColor: CGColor = UIColor.green.cgColor
    var status = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        viewWidth = self.bounds.size.width
        viewHeight = self.bounds.size.height
        //drawBattery()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(code:) must be implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        drawBattery()
    }
    
    
    func setStatus(status: Int) {
        if status == kBatteryCharging {
            self.status = status
            strokeColor = colorWithRGBA(0x84, 0xce, 0x80, 1.0).cgColor
            fillColor = colorWithRGBA(0x84, 0xce, 0x80, 1.0).cgColor
        } else if status == kBatteryLightSleep {
            self.status = status
            strokeColor = colorWithRGBA(0x80, 0xa5, 0xce, 1.0).cgColor
            fillColor = colorWithRGBA(0x80, 0xa5, 0xce, 1.0).cgColor
        } else if batteryLevel < 20 {
            self.status = kBatteryLowLevel
            strokeColor = colorWithRGBA(0xce, 0x80, 0x80, 1.0).cgColor
            fillColor = colorWithRGBA(0xce, 0x80, 0x80, 1.0).cgColor
        } else {
            self.status = kBatteryNormal
            strokeColor = colorWithRGBA(0x84, 0xce, 0x80, 1.0).cgColor
            fillColor = colorWithRGBA(0x84, 0xce, 0x80, 1.0).cgColor
        }
    }
    
    func drawBattery() {
        let batteryX: CGFloat = 1
        let batteryY: CGFloat = 1
        let batteryHeight = viewHeight - 2
        let batteryWidth = viewWidth - 2
        let lineWidth: CGFloat = 1
        let blankWidth: CGFloat = 2
        let batteryCellWidth: CGFloat = (batteryWidth - 6 * blankWidth - 2) / 5
        let batteryCellHeight: CGFloat = batteryHeight - 2 - 2 * blankWidth
        
        // 重绘时清楚之前绘制的Layer
        let subLayer = self.layer.sublayers
        if subLayer != nil && (subLayer?.count)! > 0 {
            for layer in subLayer! {
                layer.removeFromSuperlayer()
            }
        }
        
        // 画外圈
        let path1 = UIBezierPath.init(roundedRect: CGRect(x: batteryX, y: batteryY, width: batteryWidth, height: batteryHeight), cornerRadius: 2)
        let batteryLayer1 = CAShapeLayer()
        batteryLayer1.lineWidth = lineWidth
        batteryLayer1.strokeColor = strokeColor
        batteryLayer1.fillColor = UIColor.clear.cgColor
        batteryLayer1.path = path1.cgPath
        self.layer.addSublayer(batteryLayer1)
        
        if batteryLevel == 0 {
            // 电量为空
        } else if batteryLevel == 1 || batteryLevel == 2 {
            let path2 = UIBezierPath.init(roundedRect: CGRect(x: batteryX + blankWidth + lineWidth, y: batteryY + blankWidth + lineWidth, width: batteryCellWidth, height: batteryCellHeight), cornerRadius: 1)
            let batterLayer2 = CAShapeLayer()
            batterLayer2.lineWidth = lineWidth
            batterLayer2.strokeColor = UIColor.red.cgColor
            batterLayer2.fillColor = UIColor.red.cgColor
            batterLayer2.path = path2.cgPath
            self.layer.addSublayer(batterLayer2)
        } else {
            for i in 1..<batteryLevel {
                let cellX: CGFloat = batteryX + lineWidth + blankWidth * CGFloat(i) + batteryCellWidth * CGFloat(i-1)
                let cellY: CGFloat = batteryY + blankWidth + lineWidth
                
                let path3 = UIBezierPath.init(roundedRect: CGRect(x: cellX, y: cellY, width: batteryCellWidth, height: batteryCellHeight), cornerRadius: 1)
                let batterLayer3 = CAShapeLayer()
                batterLayer3.lineWidth = lineWidth
                batterLayer3.strokeColor = UIColor.green.cgColor
                batterLayer3.fillColor = UIColor.green.cgColor
                batterLayer3.path = path3.cgPath
                self.layer.addSublayer(batterLayer3)
            }
        }
        
        /**
        // 左半圆
        let leftCircleCenterX: CGFloat = (viewWidth - 3) / 5
        let leftCircleCenterY: CGFloat = viewHeight / 2
        let leftCircleRadius: CGFloat = (viewWidth - 3) / 5 - 3
        
        var path2 = UIBezierPath.init(arcCenter: CGPoint(x: leftCircleCenterX, y: leftCircleCenterY), radius: leftCircleRadius, startAngle: CGFloat(Double.pi / 2), endAngle: CGFloat(3 * Double.pi / 2), clockwise: true)
        let batteryLayer2 = CAShapeLayer()
        batteryLayer2.fillColor = fillColor
        guard level >= 2 else {
            path2 = UIBezierPath.init(arcCenter: CGPoint(x: leftCircleCenterX, y: leftCircleCenterY), radius: leftCircleRadius, startAngle: CGFloat(3 * Double.pi / 4), endAngle: CGFloat(5 * Double.pi / 4), clockwise: true)
            batteryLayer2.path = path2.cgPath
            self.layer.addSublayer(batteryLayer2)
            return
        }
        batteryLayer2.path = path2.cgPath
        self.layer.addSublayer(batteryLayer2)
        
        // 中间矩形
        let middleRectOriginX: CGFloat = (viewWidth - 3) / 5 - 1
        let middleRectOriginY: CGFloat = viewHeight / 2 - (viewWidth - 3) / 5 + 3
        let middleRectWidth: CGFloat = leftCircleRadius * 5 + 3
        let middleRectHeight: CGFloat = leftCircleRadius * 2
        if level > 2 {
            var percent: CGFloat = CGFloat(batteryLevel - 10) / 80.0
            if level > 18 {
                percent = 1
            }
            let path3 = UIBezierPath.init(rect: CGRect(x: middleRectOriginX, y: middleRectOriginY, width: middleRectWidth * percent , height: middleRectHeight))
            let batteryLayer3 = CAShapeLayer()
            batteryLayer3.lineWidth = 0
            batteryLayer3.fillColor = fillColor
            batteryLayer3.path = path3.cgPath
            self.layer.addSublayer(batteryLayer3)
        }
        
        // 右半圆
        let rightCircleCenterX: CGFloat = middleRectOriginX + middleRectWidth - 1
        let rightCircleCenterY: CGFloat = viewHeight / 2
        let rightCircleRadius: CGFloat = leftCircleRadius
        if level > 18 {
            let path4 = UIBezierPath.init(arcCenter: CGPoint(x: rightCircleCenterX, y: rightCircleCenterY), radius: rightCircleRadius, startAngle: CGFloat(3 * Double.pi / 2), endAngle: CGFloat(Double.pi / 2), clockwise: true)
            let batteryLayer4 = CAShapeLayer()
            batteryLayer4.fillColor = fillColor
            batteryLayer4.path = path4.cgPath
            self.layer.addSublayer(batteryLayer4)
        }**/
    }
    
}
