//
//  Utils.swift
//  Tracker
//
//  Created by StephenLouis on 2018/11/12.
//  Copyright © 2018 StephenLouis. All rights reserved.
//

import Foundation

class Utils{
    
    static func getNowTimeStamp() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.dateFormat = "YYYYMMddHHmmss"
        
        let dateNow = Date()
        
        return formatter.string(from: dateNow)
    }
    
    static func getFormatTime(dateInt: Int, format: String) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(abbreviation: "CCT")
        formatter.dateFormat = format
        let date = Date(timeIntervalSince1970: TimeInterval(dateInt/1000))
        return formatter.string(from: date)
    }
    
    // 通过经纬度围成的多边形面积
    static func getArea(points: [CLLocationCoordinate2D]) -> Double {
        let sJ: Double = 6378137
        let Hq: Double = 0.017453292519943295
        let c: Double = sJ * Hq
        var d: Double = 0
        
        if points.count < 3 { return 0 }
        
        let i: Int = 0
        while  i < points.count - 1 {
            let h: CLLocationCoordinate2D = points[i]
            let k: CLLocationCoordinate2D = points[i + 1]
            let u: Double = h.longitude * c * cos(h.latitude * Hq)
            
            let hhh: Double = h.latitude * c
            let v: Double = k.longitude * c * cos(k.latitude * Hq)
            d = d + (u * k.latitude * c - v * hhh)
        }
        
        let g1: CLLocationCoordinate2D = points[points.count - 1]
        let point: CLLocationCoordinate2D = points[0]
        let eee: Double = g1.longitude * c * cos(g1.latitude * Hq)
        let g2: Double = g1.latitude * c
        
        let k: Double = point.longitude * c * cos(point.latitude * Hq)
        d += eee * point.latitude * c - k * g2
        return 0.5 * abs(d)
    }
    
    static func deviceToModel(_ device: Device) -> DeviceInfoModel {
        var model = DeviceInfoModel()
        model.trackerName = device.trackerName
        model.trackerNumber = device.trackerNumber
        model.trackerBattery = Int(device.trackerBattery)
        model.trackerChangeState = Int(device.trackerChargeState)
        model.trackerHeartRate = Int(device.trackerHeartRate)
        model.trackerLatitude = device.trackerLatitude
        model.trackerLongitude = device.trackerLongitude
        model.trackerLastUpdate = Int(device.trackerLastuptime)
        model.trackerOnline = Int(device.trackerOnline)
        model.fence1 = device.fence1
        model.fence2 = device.fence2
        model.fence3 = device.fence3
        model.fence4 = device.fence4
        return model
    }
    
    static func gaodeToBdWith(lat: Double, lon: Double) -> CLLocationCoordinate2D {
        let x_pi = 3.14159265358979324 * 3000.0 / 180.0
        let x = lon - 0.0065
        let y = lat - 0.006
        let z = sqrt(x * x + y * y) - 0.00002 * sin(y * x_pi)
        let theta = atan2(y, x) - 0.000003 * cos(x * x_pi)
        return CLLocationCoordinate2D(latitude: z * sin(theta), longitude: z * cos(theta))
    }
    
}

// 邮箱网址手机号码等正则判断
enum Validate {
    case email(_: String)
    case phoneNum(_: String)
    case username(_: String)
    case password(_: String)
    
    var isRight: Bool {
        var predicateStr: String!
        var currObject: String!
        switch self {
        case let .email(str):
            predicateStr = "^([a-z0-9_\\.-]+)@([\\da-z\\.-]+)\\.([a-z\\.]{2,6})$"
            currObject = str
        case let .phoneNum(str):
            predicateStr = "^1((3[0-9]|4[57]|5[0-35-9]|7[0678]|8[0-9])\\d{8}$)"
            currObject = str
        case let .username(str):
            predicateStr = "^[A-Za-z0-9]{6,20}+$"
            currObject = str
        case let .password(str):
            predicateStr = "^[a-zA-Z0-9]{6,20}+$"
            currObject = str
        }
        
        let predicate = NSPredicate(format: "SELF MATCHES %@", predicateStr)
        return predicate.evaluate(with: currObject)
    }
}
