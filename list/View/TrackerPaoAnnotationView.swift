//
//  TrackerPaoAnnotationView.swift
//  Tracker
//
//  Created by StephenLouis on 2018/11/7.
//  Copyright © 2018 StephenLouis. All rights reserved.
//

import Foundation

class TrackerPaoAnnotationView: MAAnnotationView {
    
    var calloutView = TrackerCalloutView()
    let kCalloutWidth: CGFloat = 200.0
    let kCalloutHeight: CGFloat = 70.0
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        
        if self.isSelected == selected {
            return
        }
        
        if (selected) {
            if self.calloutView == nil {
                self.calloutView = TrackerCalloutView(frame: CGRect(x: 0, y: 0, width: kCalloutWidth, height: kCalloutHeight))
                self.calloutView.center = CGPoint(x: self.bounds.width / 2.0 + self.calloutOffset.x, y: self.calloutView.bounds.height / 2.0 + self.calloutOffset.y)
            }
            let title = UILabel(frame: CGRect(x: 10, y: 8, width: kCalloutWidth - 10, height: 20))
            title.backgroundColor = UIColor.clear
            title.text =
            
        } else {
            
        }
        
        
    }
    
}
