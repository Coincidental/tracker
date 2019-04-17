//
//  TrackerAnnotationView.swift
//  Tracker
//
//  Created by StephenLouis on 2018/11/8.
//  Copyright © 2018 StephenLouis. All rights reserved.
//

import UIKit
import MapKit




class TrackerAnnotationView: MAAnnotationView {
    
    let kCalloutWidth = CGFloat(200)
    let kCalloutHeight = CGFloat(70)
    
    var mapView: MAMapView?
    var address: String?
    var updateTime: String?
    
    var trackerCalloutView: TrackerCalloutView?
    
    var delegate: TrackerAnnotationDelegate?
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        
        if selected {
            if trackerCalloutView == nil {
                trackerCalloutView = TrackerCalloutView(frame: CGRect(x: 0, y: 0, width: kCalloutWidth, height: kCalloutHeight))
                trackerCalloutView?.center = CGPoint(x: self.bounds.width / 2.0 + self.calloutOffset.x, y: -trackerCalloutView!.bounds.height / 2.0 + self.calloutOffset.y)
            }
            
            trackerCalloutView!.setImage(image: UIImage(named: "navigation")!)
            if let address = address, let updateTime = updateTime {
                trackerCalloutView!.setTitle(title: address)
                trackerCalloutView!.setSubtitle(subtitle: updateTime)
            } else {
                trackerCalloutView!.setTitle(title: "世纪大道8号国际金融中心国金中心商场LG1层LG1-36")
                trackerCalloutView!.setSubtitle(subtitle: "今日 00:02")
            }
            trackerCalloutView!.portraitView!.addTarget(self, action: #selector(navItemClick), for: .touchUpInside)
            
            self.addSubview(trackerCalloutView!)
        } else {
            trackerCalloutView?.removeFromSuperview()
            trackerCalloutView = nil
        }
        
        super.setSelected(selected, animated: animated)
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        var view = super.hitTest(point, with: event)
        if view == nil {
            let temPoint = self.trackerCalloutView?.portraitView?.convert(point, from: self)
            if temPoint != nil {
                if (self.trackerCalloutView?.portraitView?.bounds.contains(temPoint!))! {
                    view = self.trackerCalloutView?.portraitView
                }
            }
        }
        
        return view
    }
    
    func setValue(address: String, updateTime: String) {
        self.address = address
        self.updateTime = updateTime
        trackerCalloutView?.setTitle(title: address)
        trackerCalloutView?.setSubtitle(subtitle: updateTime)
    }
}

extension TrackerAnnotationView {
    
    @objc func navItemClick() {
        print("click")
        delegate?.clickNavButton(latitude: self.annotation.coordinate.latitude, Longitude: self.annotation.coordinate.longitude)
    }
    
}

protocol TrackerAnnotationDelegate: NSObjectProtocol {
    func clickNavButton(latitude: Double, Longitude: Double)
}
