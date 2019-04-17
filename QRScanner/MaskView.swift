//
//  MaskView.swift
//  Tracker
//
//  Created by StephenLouis on 2019/1/16.
//  Copyright © 2019 StephenLouis. All rights reserved.
//

import UIKit

class MaskView: UIView {
    var lineLayer: CALayer? = nil
    
    override func draw(_ rect: CGRect) {
        let width: CGFloat = rect.size.width
        let height: CGFloat = rect.size.height
        let pickingFieldWidth: CGFloat = 300
        let pickingFieldHeight: CGFloat = 300
        let contextRef = UIGraphicsGetCurrentContext()
        contextRef!.saveGState()
        // 蒙版
        contextRef?.setFillColor(red: 0, green: 0, blue: 0, alpha: 0.35)
        contextRef?.setLineWidth(3)
        let pickingFieldRect = CGRect(x: (width - pickingFieldWidth) / 2, y: (height - pickingFieldHeight) / 2, width: pickingFieldWidth, height: pickingFieldHeight)
        let pickingFieldPath = UIBezierPath(rect: pickingFieldRect)
        let bezierPathRect = UIBezierPath(rect: rect)
        // 填充使用奇偶法则
        bezierPathRect.usesEvenOddFillRule = true
        bezierPathRect.fill()
        contextRef?.setLineWidth(2)
        // 框框
        contextRef?.setStrokeColor(red: 27/255.0, green: 181/255.0, blue: 254/255.0, alpha: 1)
        pickingFieldPath.stroke()
        contextRef?.restoreGState()
        self.layer.contentsGravity = CALayerContentsGravity.center
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        self.lineLayer = CALayer(layer: layer)
        self.lineLayer?.contents = UIImage(named: "line")?.cgImage
        self.layer.addSublayer(self.lineLayer!)
        self.resumeAnimation()
        
        NotificationCenter.default.addObserver(self, selector: #selector(resumeAnimation), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(stopAnimation), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.setNeedsDisplay()
        self.lineLayer?.frame = CGRect(x: (self.frame.size.width - 300) / 2, y: (self.frame.size.height - 300) / 2, width: 300, height: 2)
    }
    
    @objc func stopAnimation() {
        self.lineLayer?.removeAnimation(forKey: "translationY")
    }
    
    @objc func resumeAnimation() {
        let basic = CABasicAnimation(keyPath: "transform.translation.y")
        basic.fromValue = (0)
        basic.toValue = (300)
        basic.duration = 1.5
        basic.repeatCount = Float(NSIntegerMax)
        self.lineLayer?.add(basic, forKey: "translationY")
    }
    
}
