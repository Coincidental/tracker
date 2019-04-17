//
//  SettingItemModel.swift
//  Tracker
//
//  Created by StephenLouis on 2019/1/23.
//  Copyright © 2019 StephenLouis. All rights reserved.
//

import Foundation

enum SettingAccessoryType {
    case settingAccessoryTypeNone
    case settingAccessoryTypeDisclosureIndicator
    case settingAccessoryTypeSwitch
}

class SettingItemModel: NSObject {
    
    var funcName: String?                       // 功能名称
    var img: UIImage?                           // 功能图片
    var detailText: String?                     // 更多信息-提示文字
    var detailImage: UIImage?                   // 更多信息-提示图片
    var accessoryType: SettingAccessoryType?

}
