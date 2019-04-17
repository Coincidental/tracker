//
//  DataEncoding.swift
//  Tracker
//
//  Created by StephenLouis on 2018/11/8.
//  Copyright © 2018 StephenLouis. All rights reserved.
//

import CryptoSwift

class DataEncoding: NSObject {
    
    // MARK: AES-ECB128 加密
    static func Encode_AES_ECB(strToEncode: String) -> String {
        let ps = strToEncode.data(using: String.Encoding.utf8)
        
        var encrypted: [UInt8] = []
        let key = "357AESMD5techain"
        let iv = "357AESMD5techain"
        do {
            encrypted = try AES(key: key.bytes, blockMode: CBC(iv: iv.bytes), padding: .pkcs5).encrypt(ps!.bytes)
        } catch AES.Error.dataPaddingRequired {
            print("AES.Error.dataPaddingRequired")
        } catch {
            print("Error")
        }
        
        let encoded = NSData.init(bytes: encrypted, length: encrypted.count)
        /// 加密结果要用Base64转码
        var result = encoded.base64EncodedString(options: NSData.Base64EncodingOptions.lineLength64Characters)
        result = result.replacingOccurrences(of: "+", with: "-")
        result = result.replacingOccurrences(of: "/", with: "_")
        result = result.replacingOccurrences(of: "\r\n", with: "")
        return result
    }
    
    // MAKR: AES-ECB128解密
    static func Decode_AES_ECB(strToDecode: String) -> String {
        //decode base64
        let data = NSData(base64Encoded: strToDecode, options: NSData.Base64DecodingOptions.init(rawValue: 0))
        
        // byte 数组
        var encrypted: [UInt8] = []
        for i in 0..<16 {
            var temp: UInt8 = 0
            data?.getBytes(&temp, range: NSRange(location: i, length: 1))
            encrypted.append(temp)
        }
        // decode AES
        return ""
    }
}
