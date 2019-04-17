//
//  LaunchAdCache.swift
//  Tracker
//
//  Created by StephenLouis on 2019/1/15.
//  Copyright © 2019 StephenLouis. All rights reserved.
//

import UIKit

// MARK: - 清楚缓存
func LaunchAdClearDiskCache() {
    DispatchQueue.global().async {
        do {
            try FileManager.default.removeItem(atPath: cacheImagePath())
            checkDirectory(cacheImagePath())
        } catch {
            print(error)
        }
    }
}

// MARK: - 清除指定url缓存
func LaunchAdClearDiskCacheWithImageUrlArray(_ urlArray: Array<String>) {
    if urlArray.count == 0 { return }
    DispatchQueue.global().async {
        for url in urlArray {
            let path = "\(cacheImagePath())/\(MD5(url))"
            if FileManager.default.fileExists(atPath: MD5(path)) {
                do{
                    try FileManager.default.removeItem(atPath: MD5(path))
                } catch {
                    print(error)
                }
            }
        }
    }
}

/// 缓存图片
func saveImage(_ data: Data, url: URL, completion: ((Bool)->())?) {
    DispatchQueue.global().async {
        let path = "\(cacheImagePath())/\(MD5(url.absoluteString))"
        let isOk = FileManager.default.createFile(atPath: path, contents: data, attributes: nil)
        DispatchQueue.main.async {
            if completion != nil { completion!(isOk) }
        }
    }
}

/// 获取图片缓存
func getCacheImageWithURL(_ url: URL) -> Data? {
    let path = "\(cacheImagePath())/\(MD5(url.absoluteString))"
    do {
        let data = try NSData(contentsOfFile: path) as Data
        return data
    } catch {
        print(error)
        return nil
    }
}

// MARK: - 目录
func cacheImagePath() -> String {
    let path = (NSHomeDirectory() as NSString).appendingPathComponent("Library/LaunchAdCache")
    checkDirectory(path)
    return path
}

// MARK: - 目标创建文件
func createBaseDirectoryAtPath(_ path: String) {
    do {
        try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
        let url = URL(fileURLWithPath: path) as NSURL
        try url.setResourceValue(NSNumber(value: true), forKey: .isExcludedFromBackupKey)
        print("LaunchAd cache directory = \(path)")
    } catch {
        print("create cache directory failed, error = \(error)")
    }
}

// MARK: - 检查目录
func checkDirectory(_ path: String) {
    var isDir: ObjCBool = false
    if !FileManager.default.fileExists(atPath: path, isDirectory: &isDir) {
        createBaseDirectoryAtPath(path)
    } else {
        if !isDir.boolValue {
            do {
                try FileManager.default.removeItem(atPath: path)
                createBaseDirectoryAtPath(path)
            } catch {
                print(error)
            }
        }
    }
}
