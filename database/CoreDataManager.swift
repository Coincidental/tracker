//
//  CoreDataManager.swift
//  Tracker
//
//  Created by StephenLouis on 2018/11/12.
//  Copyright © 2018 StephenLouis. All rights reserved.
//

import Foundation
import CoreData

class CoreDataManager: NSObject {
    // 单例
    static let shared = CoreDataManager()
    
    // 拿到AppDelegate中创建好的NSManagedObjectContext
    lazy var context: NSManagedObjectContext = {
        let context = ((UIApplication.shared.delegate) as! AppDelegate).context
        return context
    }()
    
    // 更新数据
    private func saveContext() {
        do {
            try context.save()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
    // 添加数据
    func saveUserWith(token: String) {
        let user = NSEntityDescription.insertNewObject(forEntityName: "User", into: context) as! User
        user.token = token
        print("token: \(token)")
        saveContext()
    }
    
    // 获取所有数据
    func getAllUser() -> [User] {
        let fetchRequest: NSFetchRequest = User.fetchRequest()
        do {
            let result = try context.fetch(fetchRequest)
            return result
        } catch {
            fatalError()
        }
    }
    
    // 根据token获取数据
    func getUserWith(token: String) -> [User] {
        let fetchRequest: NSFetchRequest = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "token == %@", token)
        do {
            let result: [User] = try context.fetch(fetchRequest)
            return result
        } catch {
            fatalError()
        }
    }
    
    // 根据token修改姓名和电话号码
    func changeUserWith(token: String, newName: String, newPhoneNum: String) {
        let fetchRequest: NSFetchRequest = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "token == %@", token)
        do {
            // 拿到符合条件的所有数据
            let result = try context.fetch(fetchRequest)
            for user in result {
                // 循环修改
                user.user_name = newName
                user.phone_num = newPhoneNum
            }
        } catch {
            fatalError()
        }
        saveContext()
    }
    
    // 根据token删除数据
    func deleteWith(token: String) {
        let fetchRequest: NSFetchRequest = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "token == %@", token)
        do {
            let result = try context.fetch(fetchRequest)
            for user in result {
                context.delete(user)
            }
        } catch {
            fatalError()
        }
        saveContext()
    }
    
    // 删除所有数据
    func deleteAllUser() {
        // 这里直接调用上面获取所有数据的方法
        let result = getAllUser()
        for user in result {
            context.delete(user)
        }
        saveContext()
    }
}

// Devices数据库操作
extension CoreDataManager {
    
    // 增
    func saveDeviceWith(device: DeviceInfoModel) {
        let newDevice = NSEntityDescription.insertNewObject(forEntityName: "Deivce", into: context) as! Device
        //newDevice.trackerId = device.trackerId
        //newDevice.fenceStatus = Int16(device.fenceStatus!)
        newDevice.trackerName = device.trackerName
        newDevice.trackerNumber = device.trackerNumber
        newDevice.trackerLastuptime = Int16(device.trackerLastUpdate!)
        newDevice.trackerBattery = Int16(device.trackerBattery!)
        newDevice.trackerLatitude = device.trackerLatitude!
        newDevice.trackerLongitude = device.trackerLongitude!
        newDevice.trackerChargeState = Int16(device.trackerChangeState!)
        newDevice.trackerHeartRate = Int16(device.trackerHeartRate!)
        newDevice.fence1 = device.fence1
        newDevice.fence2 = device.fence2
        newDevice.fence3 = device.fence3
        newDevice.fence4 = device.fence4
        saveContext()
    }
    
    // 删
    func deleteDeviceWith(trackerNumber: Int) {
        let fetchRequest: NSFetchRequest = Device.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "tackerNumber == %@", trackerNumber)
        do {
            let result = try context.fetch(fetchRequest)
            for device in result {
                context.delete(device)
            }
        } catch {
            fatalError()
        }
        saveContext()
    }
    
    func deleteAllDevice() {
        let result = getAllDevice()
        for device in result {
            context.delete(device)
        }
        saveContext()
    }
    
    // 改
    // 根据设备编号，修改设备经纬度，充电状态，电量信息，更新时间，心跳
    func updateDeviceWith(trackerNumber: Int, latitude: Double, longitude: Double, trackerChargeState: Int, trackerBattery: Int, trackerLastuptime: Int, trackerHeartRate: Int) {
        let fetchRequest: NSFetchRequest = Device.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "trackerNumber == %@", Int16(trackerNumber))
        do {
            // 拿到符合条件的所有数据
            let result = try context.fetch(fetchRequest)
            for device in result {
                // 循环修改
                device.trackerLatitude = latitude
                device.trackerLongitude = longitude
                device.trackerChargeState = Int16(trackerChargeState)
                device.trackerBattery = Int16(trackerBattery)
                device.trackerLastuptime = Int16(trackerLastuptime)
                device.trackerHeartRate = Int16(trackerHeartRate)
            }
        } catch {
            fatalError()
        }
        saveContext()
    }
    
    // 根据设备编号修改 电子围栏
    func updateDeviceWith(trackerNumber: Int, fences: [String]) {
        let fetchRequest: NSFetchRequest = Device.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "trackerNumber == %@", Int16(trackerNumber))
        do {
            // 拿到符合条件的所有数据
            let result = try context.fetch(fetchRequest)
            let fenceCount = fences.count
            for device in result {
                switch fenceCount {
                case 0:
                    device.fence1 = ""
                    device.fence2 = ""
                    device.fence3 = ""
                    device.fence4 = ""
                case 1:
                    device.fence1 = fences[0]
                    device.fence2 = ""
                    device.fence3 = ""
                    device.fence4 = ""
                case 2:
                    device.fence1 = fences[0]
                    device.fence2 = fences[1]
                    device.fence3 = ""
                    device.fence4 = ""
                case 3:
                    device.fence1 = fences[0]
                    device.fence2 = fences[1]
                    device.fence3 = fences[2]
                    device.fence4 = ""
                case 4:
                    device.fence1 = fences[0]
                    device.fence2 = fences[1]
                    device.fence3 = fences[2]
                    device.fence4 = fences[3]
                default:
                    break
                }
            }
        } catch {
            fatalError()
        }
        saveContext()
    }
    
    
    // 查
    func getAllDevice() -> [Device] {
        let fetchRequest: NSFetchRequest = Device.fetchRequest()
        do {
            let result = try context.fetch(fetchRequest)
            return result
        } catch {
            fatalError()
        }
    }
    
    
    
}
