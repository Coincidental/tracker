//
//  MyToastManager.swift
//  Tracker
//
//  Created by StephenLouis on 2019/2/18.
//  Copyright © 2019 StephenLouis. All rights reserved.
//

import UIKit

public class MyToastManager {
    public static let shared = MyToastManager()
    
    public var succcessImage = UIImage(named: "ic_toast_success", in: BundleUtil.getCurrentBundle(), compatibleWith: nil)
    public var failImage = UIImage(named: "icon_sign", in: BundleUtil.getCurrentBundle(), compatibleWith: nil)
    public var bgColor = UIColor.black
    public var textColor = UIColor.white
    public var textFont = UIFont.systemFont(ofSize: 16)
    public var cornerRadius: CGFloat = 5
    public var supportQueue: Bool = true
    
    private let queue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    public func my_resetDefaultProps() {
        self.common()
    }
    
    @available(*, deprecated, message: "Use 'my_reset' instead.")
    public func reset() {
        self.common()
    }
    
    func common() {
        self.bgColor = UIColor.black
        self.textColor = UIColor.white
        self.textFont = UIFont.systemFont(ofSize: 16)
        self.cornerRadius = 5
        self.succcessImage = UIImage(named: "ic_toast_success", in: BundleUtil.getCurrentBundle(), compatibleWith: nil)
        self.failImage = UIImage(named: "icon_sign", in: BundleUtil.getCurrentBundle(), compatibleWith: nil)
        self.supportQueue = true
    }
    
    func add(_ toast: MyToastUtils) {
        self.queue.addOperation(toast)
    }
    
    public func cancelAll() {
        self.queue.cancelAllOperations()
    }
}
