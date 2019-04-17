//
//  AdImageModel.swift
//  Tracker
//
//  Created by StephenLouis on 2018/12/10.
//  Copyright © 2018 StephenLouis. All rights reserved.
//

import Foundation
import SwiftyJSON

struct AdImageModel {
    
    var imageId: Int?
    var imageFileName: String?
    var imageLink: String?
    var imageTitle: String?
    var imageWeight: Int?
    
    init(jsonData: JSON) {
        imageId = jsonData["id"].intValue
        imageFileName = jsonData["img_file_name"].stringValue
        imageLink = jsonData["link"].stringValue
        imageTitle = jsonData["title"].stringValue
        imageWeight = jsonData["weight"].intValue
    }
}

struct AdResponseModel {
    var code: Int?
    var message: String?
    var adimages = [AdImageModel]()
    
    init(jsonData: JSON) {
        code = jsonData["code"].intValue
        message = jsonData["message"].stringValue
        let image_array = jsonData["data"]
        for i in 0..<image_array.count {
            let imageModel = AdImageModel(jsonData: image_array[i])
            adimages.append(imageModel)
        }
    }
}
