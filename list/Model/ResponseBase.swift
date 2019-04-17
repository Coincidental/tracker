//
//  BindResponse.swift
//  Tracker
//
//  Created by StephenLouis on 2018/11/1.
//  Copyright © 2018 StephenLouis. All rights reserved.
//

import SwiftyJSON

class ResponseBase {
    var code: Int?
    var message: String?
    
    init(jsonData: JSON) {
        code = jsonData["code"].intValue
        message = jsonData["message"].stringValue
    }
}
