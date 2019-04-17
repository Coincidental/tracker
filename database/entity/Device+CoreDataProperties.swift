//
//  Device+CoreDataProperties.swift
//  Tracker
//
//  Created by StephenLouis on 2019/1/7.
//  Copyright © 2019 StephenLouis. All rights reserved.
//
//

import Foundation
import CoreData


extension Device {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Device> {
        return NSFetchRequest<Device>(entityName: "Device")
    }

    @NSManaged public var authorization: String?
    @NSManaged public var fence1: String?
    @NSManaged public var fence2: String?
    @NSManaged public var fence3: String?
    @NSManaged public var fence4: String?
    @NSManaged public var fenceStatus: Int16
    @NSManaged public var sleep: Int16
    @NSManaged public var trackerBattery: Int16
    @NSManaged public var trackerChargeState: Int16
    @NSManaged public var trackerHeartRate: Int16
    @NSManaged public var trackerId: Int16
    @NSManaged public var trackerLastuptime: Int16
    @NSManaged public var trackerLatitude: Double
    @NSManaged public var trackerLongitude: Double
    @NSManaged public var trackerName: String?
    @NSManaged public var trackerNumber: String?
    @NSManaged public var trackerOnline: Int16
    @NSManaged public var trackerType: Double
    @NSManaged public var trackerVersion: String?

}
