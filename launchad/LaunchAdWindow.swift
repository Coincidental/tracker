//
//  LaunchAdWindow.swift
//  Tracker
//
//  Created by StephenLouis on 2019/1/15.
//  Copyright © 2019 StephenLouis. All rights reserved.
//

import UIKit

extension UIWindow {
    open override func didAddSubview(_ subview: UIView) {
        super.didAddSubview(subview)
        for sub_view in subviews {
            if subview.isKind(of: LaunchAdView.self) {
                bringSubviewToFront(subview)
            }
        }
    }
}
