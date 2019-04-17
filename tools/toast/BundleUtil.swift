//
//  BundleUtil.swift
//  Tracker
//
//  Created by StephenLouis on 2019/2/18.
//  Copyright © 2019 StephenLouis. All rights reserved.
//

import UIKit

class BundleUtil {
    
    static func getCurrentBundle() -> Bundle {
        let podBundle = Bundle(for: MyToast.self)
        let bundleURL = podBundle.url(forResource: "MyToast", withExtension: "bundle")
        if bundleURL != nil {
            let bundle = Bundle(url: bundleURL!)!
            return bundle
        } else {
            return Bundle.main
        }
    }
    
}
