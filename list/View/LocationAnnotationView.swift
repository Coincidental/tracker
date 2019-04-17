//
//  LocationAnnotationView.swift
//  Tracker
//
//  Created by StephenLouis on 2018/11/7.
//  Copyright © 2018 StephenLouis. All rights reserved.
//

import UIKit

class LocationAnnotationView: MAAnnotationView {
    var contentImageView: UIImageView!
    
    var rotateDegree: CGFloat {
        set {
            self.contentImageView.transform = CGAffineTransform(rotationAngle: newValue * CGFloat(Double.pi) / 180.0)
        }
        get {
            return self.rotateDegree
        }
    }
    
    override init!(annotation: MAAnnotation!, reuseIdentifier: String!) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        self.contentImageView = UIImageView()
        self.addSubview(self.contentImageView)
        self.rotateDegree = 0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateImage(image: UIImage!) {
        self.bounds = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        self.contentImageView.image = image
        self.contentImageView.sizeToFit()
    }
}
