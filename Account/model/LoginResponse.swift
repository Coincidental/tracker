//
//  LoginResponse.swift
//  Tracker
//
//  Created by StephenLouis on 2019/1/22.
//  Copyright © 2019 StephenLouis. All rights reserved.
//

import SwiftyJSON

struct LoginResponse {
    var resCode: String
    var resMsg: String
    
    init(jsonData: JSON) {
        resCode = jsonData["resCode"].stringValue
        resMsg = jsonData["resMsg"].stringValue
    }
}
