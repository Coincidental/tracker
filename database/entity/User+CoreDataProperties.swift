//
//  User+CoreDataProperties.swift
//  Tracker
//
//  Created by StephenLouis on 2018/11/12.
//  Copyright © 2018 StephenLouis. All rights reserved.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var birthday: String?
    @NSManaged public var uid: Int16
    @NSManaged public var account: String?
    @NSManaged public var password: String?
    @NSManaged public var authentication: String?
    @NSManaged public var user_name: String?
    @NSManaged public var phone_num: String?
    @NSManaged public var email: String?
    @NSManaged public var sex: Int16
    @NSManaged public var area: String?
    @NSManaged public var token: String?

}
