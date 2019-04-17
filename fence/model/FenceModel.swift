//
//  FenceModel.swift
//  Tracker
//
//  Created by StephenLouis on 2018/12/3.
//  Copyright © 2018 StephenLouis. All rights reserved.
//

import UIKit

class FenceModel {
    // 设备token
    var token: String?
    // 围栏名
    var fenceName: String?
    // 电子围栏上的点
    var coordinates: [CLLocationCoordinate2D] = [CLLocationCoordinate2D]()
    
    init(token: String?, fenceName: String?, coordinates: [CLLocationCoordinate2D]) {
        self.token = token
        self.fenceName = fenceName
        self.coordinates = coordinates
    }
}
