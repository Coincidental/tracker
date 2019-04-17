//
//  DeviceInfoModel.swift
//  Tracker
//
//  Created by StephenLouis on 2018/11/1.
//  Copyright © 2018 StephenLouis. All rights reserved.
//

import SwiftyJSON

struct DeviceInfoModel {
    var trackerId: Int?
    var trackerName: String?
    var trackerNumber: String?
    var trackerLastUpdate: Int?
    var trackerBattery: Int?
    var trackerOnline: Int?
    var trackerType: Int?
    var trackerPhone: String?
    var trackerLatitude: Double?
    var trackerLongitude: Double?
    var locationStyleStatus: Int?
    var trackerVersion: String?
    var trackerBTStatus: Int?
    var fenceStatus: Int?
    var locationStyle: Int?
    var isLoading: Bool?
    var trackerChangeState: Int?
    var trackerHeartRate: Int?
    var sleep: Int?
    var authorization: String?
    var latLng: [CLLocationCoordinate2D]?
    var fence1: String?
    var fence2: String?
    var fence3: String?
    var fence4: String?
    
    init() {
    }
    
    init(jsonData: JSON) {
        trackerName = jsonData["trackerName"].stringValue
        trackerLastUpdate = jsonData["trackerLastuptime"].intValue
        trackerBattery = jsonData["trackerBattery"].intValue
        trackerOnline = jsonData["trackerOnline"].intValue
        trackerLatitude = jsonData["trackerLatitude"].doubleValue
        trackerLongitude = jsonData["trackerLongitude"].doubleValue
        locationStyle = jsonData["locationStyle"].intValue
        locationStyleStatus = jsonData["locationStyleStatus"].intValue
        fenceStatus = jsonData["fenceStatus"].intValue
        trackerVersion = jsonData["trackerVersion"].stringValue
        trackerType = jsonData["trackerType"].intValue
        trackerPhone = jsonData["trackerPhone"].stringValue
        trackerNumber = jsonData["trackerNumber"].stringValue
        trackerBTStatus = jsonData["trackerBlueStatus"].intValue
        trackerChangeState = jsonData["trackerChangeState"].intValue
        trackerHeartRate = jsonData["trackerHeartRate"].intValue
    }
}

struct SingleDeviceRespone {
    var code: Int?
    var message: String?
    var device: DeviceInfoModel?
    
    init(jsonData: JSON) {
        code = jsonData["code"].intValue
        message = jsonData["message"].stringValue
        device = DeviceInfoModel(jsonData: jsonData["data"])
    }
}

struct DeviceResponse {
    var code: Int?
    var message: String?
    var devices = [DeviceInfoModel]()
    
    init(jsonData: JSON) {
        code = jsonData["code"].intValue
        message = jsonData["message"].stringValue
        let device_array = jsonData["data"]
        for i in 0..<device_array.count {
            let device = DeviceInfoModel(jsonData: device_array[i])
            devices.append(device)
        }
    }
}

