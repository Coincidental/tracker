//
//  PowerRadioButton.swift
//  Tracker
//
//  Created by StephenLouis on 2018/11/23.
//  Copyright © 2018 StephenLouis. All rights reserved.
//

import Foundation

class PowerRadioButton: UIButton {
    var circleLayer = CAShapeLayer()
    var fillCircleLayer = CAShapeLayer()
    
    let circleColor1 = colorWithRGBA(255.0, 145.0, 101.0, 1.0)
    let ovalColor = colorWithRGBA(136.0, 136.0, 136.0, 1.0)
    
    override var isSelected: Bool {
        didSet {
            toggleButton()
        }
    }
    
    var circleColor: UIColor = UIColor.red {
        didSet {
            circleLayer.strokeColor = strokeColor.cgColor
            self.toggleButton()
        }
    }
    
    var strokeColor: UIColor = UIColor.gray {
        didSet {
            circleLayer.strokeColor = strokeColor.cgColor
            self.toggleButton()
        }
    }
    
    var circleRadius: CGFloat = 11.0
    
    func circleFrame() -> CGRect {
        var circleFrame = CGRect(x: 0, y: 0, width: 2 * circleRadius, height: 2 * circleRadius)
        circleFrame.origin.x = 0 + circleLayer.lineWidth
        circleFrame.origin.y = bounds.height/2 - circleFrame.height/2
        return circleFrame
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initialize() {
        circleColor = circleColor1
        strokeColor = ovalColor
        circleLayer.frame = bounds
        circleLayer.lineWidth = 2
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.strokeColor = strokeColor.cgColor
        layer.addSublayer(circleLayer)
        fillCircleLayer.frame = bounds
        fillCircleLayer.lineWidth = 2
        fillCircleLayer.fillColor = UIColor.clear.cgColor
        fillCircleLayer.strokeColor = UIColor.clear.cgColor
        layer.addSublayer(fillCircleLayer)
        self.toggleButton()
    }
    
    func toggleButton() {
        if self.isSelected {
            fillCircleLayer.fillColor = circleColor.cgColor
            circleLayer.strokeColor = circleColor.cgColor
        } else {
            fillCircleLayer.fillColor = UIColor.clear.cgColor
            circleLayer.strokeColor = strokeColor.cgColor
        }
    }
    
    func circlePath() -> UIBezierPath {
        return UIBezierPath(ovalIn: circleFrame())
    }
    
    func fillCirclePath() -> UIBezierPath {
        return UIBezierPath(ovalIn: circleFrame().insetBy(dx: 4, dy: 4))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        circleLayer.frame = bounds
        circleLayer.path = circlePath().cgPath
        fillCircleLayer.frame = bounds
        fillCircleLayer.path = fillCirclePath().cgPath
    }
    
    override func prepareForInterfaceBuilder() {
        initialize()
    }
}
