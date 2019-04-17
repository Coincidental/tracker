//
//  MyToast.swift
//  Tracker
//
//  Created by StephenLouis on 2019/2/15.
//  Copyright © 2019 StephenLouis. All rights reserved.
//

import UIKit

public enum MyToastPosition {
    case top
    case middle
    case bottom
}

public class MyToast: NSObject {
    // 默认纯文本，展示在window上，2秒消失，中间位置
    // onView: 可以指定显示在指定的view上
    // success=nil, 展示纯文本, success=false展示错误的图片，success=true展示成功的图片
    // position: 展示的位置
    public static func my_show(msg: String, onView: UIView? = nil, success: Bool? = nil, duration: CGFloat? = nil, position: MyToastPosition? = .middle) {
        _ = MyToastUtils.init(msg: msg, onView: onView, success: success, duration: duration, position: position)
    }
}
