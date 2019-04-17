//
//  TrackerCalloutView.swift
//  Tracker
//
//  Created by StephenLouis on 2018/11/8.
//  Copyright © 2018 StephenLouis. All rights reserved.
//

import UIKit

class TrackerCalloutView: UIView {
    
    let kArrorHeight = CGFloat(10)
    
    let kPortraitMargin = CGFloat(5)
    let kPortraitWidth = CGFloat(70)
    let kPortraitHeight = CGFloat(60)
    
    let kTitleWidth = CGFloat(120)
    let kTitleHeight = CGFloat(20)
    let kBackgroundColor = UIColor.white
    
    var portraitView: UIButton?
    var titleLabel: UILabel?
    var subtitleLabel: UILabel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUp() {
        self.backgroundColor = UIColor.clear
        
        portraitView = UIButton.init(frame: CGRect(x: 2 * kPortraitMargin + kTitleWidth, y: 0, width: kPortraitWidth, height: kPortraitHeight))
        let maskPath = UIBezierPath(roundedRect: portraitView!.bounds, byRoundingCorners: UIRectCorner(rawValue: UIRectCorner.topRight.rawValue | UIRectCorner.bottomRight.rawValue), cornerRadii: CGSize(width: 6, height: 6))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = (portraitView?.bounds)!
        maskLayer.path = maskPath.cgPath
        portraitView?.layer.mask = maskLayer
        portraitView!.backgroundColor = UIColor.orange
        portraitView!.contentMode = .center
        self.addSubview(portraitView!)
        
        titleLabel = UILabel.init(frame: CGRect(x: kPortraitMargin, y: kPortraitMargin, width: kTitleWidth, height: kTitleHeight))
        titleLabel!.font = UIFont.boldSystemFont(ofSize: 14)
        titleLabel!.textColor = UIColor.black
        titleLabel!.text = "上海市陆家嘴商业中心"
        self.addSubview(titleLabel!)
        
        subtitleLabel = UILabel.init(frame: CGRect(x: kPortraitMargin, y: kPortraitMargin * 2 + kTitleHeight, width: kTitleWidth, height: kTitleHeight))
        subtitleLabel!.font = UIFont.systemFont(ofSize: 12)
        subtitleLabel!.textColor = UIColor.lightGray
        subtitleLabel!.text = "今天 00:00"
        self.addSubview(subtitleLabel!)
    }
    
    override func draw(_ rect: CGRect) {
        self.draw(context: UIGraphicsGetCurrentContext()!)
        self.layer.shadowColor = UIColor.gray.cgColor
        self.layer.shadowOpacity = 1.0
        self.layer.shadowOffset = CGSize(width: CGFloat(0.0), height: CGFloat(0.0))
    }
    
    func draw(context: CGContext) {
        context.setLineWidth(CGFloat(2.0))
        context.setFillColor(kBackgroundColor.cgColor)
        self.getDrawPath(context: context)
        context.fillPath()
    }
    
    func getDrawPath(context: CGContext) {
        let rrect: CGRect = self.bounds
        let radius: CGFloat = 6.0
        let minx: CGFloat = rrect.minX
        let midx: CGFloat = rrect.midX
        let maxx: CGFloat = rrect.maxX
        let miny: CGFloat = rrect.minY
        let maxy: CGFloat = rrect.maxY - kArrorHeight
        context.move(to: CGPoint(x: CGFloat(midx + kArrorHeight), y: maxy))
        context.addLine(to: CGPoint(x: midx, y: CGFloat(maxy + kArrorHeight)))
        context.addLine(to: CGPoint(x: CGFloat(midx - kArrorHeight), y: maxy))
        context.addArc(tangent1End: CGPoint(x: minx, y: maxy), tangent2End: CGPoint(x: minx, y: miny), radius: radius)
        context.addArc(tangent1End: CGPoint(x: minx, y: minx), tangent2End: CGPoint(x: maxx, y: miny), radius: radius)
        context.addArc(tangent1End: CGPoint(x: maxx, y: miny), tangent2End: CGPoint(x: maxx, y: maxx), radius: radius)
        context.addArc(tangent1End: CGPoint(x: maxx, y: maxy), tangent2End: CGPoint(x: midx, y: maxy), radius: radius)
        context.closePath()
    }
    
    func setTitle(title: String) {
        titleLabel!.text = title
    }
    
    func setSubtitle(subtitle: String) {
        subtitleLabel!.text = subtitle
    }
    
    func setImage(image: UIImage) {
        portraitView!.setImage(image, for: .normal)
    }
}
