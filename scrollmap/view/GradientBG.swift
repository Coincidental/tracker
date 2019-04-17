//
//  GradientBGLable.swift
//  Tracker
//
//  Created by StephenLouis on 2018/11/20.
//  Copyright © 2018 StephenLouis. All rights reserved.
//

import UIKit

class GradientBG: UIView {
    
    var direction = 0
    
    init(frame: CGRect, direction: Int) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        self.direction = direction
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        // 获取绘图上下文
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        
        context.saveGState()
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        let startColor = colorWithRGBA(255.0, 255.0, 255.0, 1.0)
        var endColor = colorWithRGBA(255.0, 255.0, 255.0, 0.5)
        
        var startPoint = CGPoint(x: 0, y: 0)
        var endPoint = CGPoint(x: 0, y: self.bounds.height)
        
        if direction == 1 {
            startPoint = CGPoint(x: 0, y: self.bounds.height)
            endPoint = CGPoint(x: 0, y: 0)
            endColor = colorWithRGBA(255.0, 255.0, 255.0, 0.3)
        }
        
        guard let startColorComponents = startColor.cgColor.components else {
            return
        }
        guard let endColorComponents = endColor.cgColor.components else {
            return
        }
        
        let colorComponents: [CGFloat] = [startColorComponents[0], startColorComponents[1], startColorComponents[2], startColorComponents[3], endColorComponents[0], endColorComponents[1], endColorComponents[2], endColorComponents[3]]
        
        let loactions: [CGFloat] = [0.0, 1.0]
        
        guard let gradient = CGGradient(colorSpace: colorSpace, colorComponents: colorComponents, locations: loactions, count: 2) else {
            return
        }
        
        context.drawLinearGradient(gradient, start: startPoint, end: endPoint, options: CGGradientDrawingOptions(rawValue: UInt32(0)))
        
        context.restoreGState()
    }
    
}
