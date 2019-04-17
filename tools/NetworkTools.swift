//
//  NetworkTools.swift
//  Tracker
//
//  Created by StephenLouis on 2018/10/30.
//  Copyright © 2018 StephenLouis. All rights reserved.
//

import UIKit

enum HTTPRequestMethod: String {
    case GET = "get"
    case POST = "post"
}

class NetworkTools: AFHTTPSessionManager {
    
    // 单例
    static let shared: NetworkTools = {
        let instance = NetworkTools()
        instance.requestSerializer.stringEncoding = String.Encoding.utf8.rawValue
        instance.responseSerializer = AFJSONResponseSerializer()
        instance.responseSerializer.acceptableContentTypes?.insert("text/html")
        instance.responseSerializer.acceptableContentTypes?.insert("text/plain")
        return instance
    }()
    
}

extension NetworkTools {
    
    func request(method: HTTPRequestMethod, urlString: String, parameters: AnyObject?, resultBlock: @escaping([String: Any]?, Error?) -> ()) {
        
        if method == .GET {
            self.get(urlString, parameters: parameters, progress: nil, success: { (task, responseObject) in
                resultBlock(responseObject as? [String: Any], nil)
            }, failure: { (task, error) in
                resultBlock(nil, error)
            })
        }
        
        if method == .POST {
            self.post(urlString, parameters: parameters, progress: nil, success: { (task, responseObject) in
                resultBlock(responseObject as? [String: Any], nil)
            }, failure: { (task, error) in
                resultBlock(nil, error)
            })
        }
    }
    
}
