//
//  ScreenTools.swift
//  Tracker
//
//  Created by StephenLouis on 2019/2/15.
//  Copyright © 2019 StephenLouis. All rights reserved.
//

import UIKit

typealias ScreenToolsClouse = (UIDeviceOrientation)->()

var kScreenHeight = UIScreen.main.bounds.height
var kScreenWidth = UIScreen.main.bounds.width

class ScreenTools: NSObject {
    static let share = ScreenTools()
    
    var screenClosure: ScreenToolsClouse?
    
    override init() {
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(receiverNotification), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    @objc func receiverNotification() {
        let orient = UIDevice.current.orientation
        
        switch orient {
        case .portrait: // 屏幕正常竖向
            kScreenWidth = UIScreen.main.bounds.width
            kScreenHeight = UIScreen.main.bounds.height
            if self.screenClosure != nil {
                self.screenClosure!(.portrait)
            }
        case .portraitUpsideDown: // 屏幕倒立
            kScreenWidth = UIScreen.main.bounds.width
            kScreenHeight = UIScreen.main.bounds.height
            if self.screenClosure != nil {
                self.screenClosure!(.portraitUpsideDown)
            }
        case .landscapeLeft: // 屏幕左旋转
            kScreenWidth = UIScreen.main.bounds.width
            kScreenHeight = UIScreen.main.bounds.height
            if self.screenClosure != nil {
                self.screenClosure!(.landscapeLeft)
            }
        case .landscapeRight: // 屏幕右旋转
            kScreenWidth = UIScreen.main.bounds.width
            kScreenHeight = UIScreen.main.bounds.height
            if self.screenClosure != nil {
                self.screenClosure!(.landscapeRight)
            }
        default:
            break
        }
    }
}
