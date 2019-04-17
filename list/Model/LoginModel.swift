//
//  LoginModel.swift
//  Tracker
//
//  Created by StephenLouis on 2018/10/30.
//  Copyright © 2018 StephenLouis. All rights reserved.
//

import SwiftyJSON

struct LoginInfoModel {
    var code: String?
    var message: String?
    var loginData: LoginDataModel
    
    init(jsonData: JSON) {
        code = jsonData["code"].stringValue
        message = jsonData["message"].stringValue
        loginData = LoginDataModel(jsonData: jsonData["data"])
    }
}

struct LoginDataModel {
    var displayName: String
    var token: String!
    
    init(jsonData: JSON) {
        displayName = jsonData["displayname"].stringValue
        token = jsonData["token"].stringValue
    }
}
