//
//  LaunchAdMD5.swift
//  Tracker
//
//  Created by StephenLouis on 2019/1/15.
//  Copyright © 2019 StephenLouis. All rights reserved.
//

import UIKit

import CommonCrypto

/// MD5
func MD5(_ str: String) -> String {
    let cStr = str.cString(using: String.Encoding.utf8)
    let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: 16)
    CC_MD5(cStr!, (CC_LONG)(strlen(cStr!)), buffer)
    let md5String = NSMutableString()
    for i in 0 ..< 16 {
        md5String.appendFormat("%02x", buffer[i])
    }
    free(buffer)
    return md5String as String
}
