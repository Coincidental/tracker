//
//  FindPwd1ViewController.swift
//  Tracker
//
//  Created by StephenLouis on 2019/1/22.
//  Copyright © 2019 StephenLouis. All rights reserved.
//

import UIKit
import SwiftyJSON

class FindPwd1ViewController: UIViewController {
    
    var phoneNumberText: UITextField?
    var nextButton: UIButton?
    var isRegister: Bool = false
    
    override func viewDidLoad() {
        setupUI()
    }
    
    func setupUI() {
        self.view.backgroundColor = UIColor.black
        
        phoneNumberText = UITextField()
        phoneNumberText?.layer.masksToBounds = true
        phoneNumberText?.layer.cornerRadius = 12.0
        phoneNumberText?.layer.borderWidth = 2.0
        phoneNumberText?.layer.borderColor = UIColor.gray.cgColor
        phoneNumberText?.placeholder = "  输入你的手机号码"
        phoneNumberText?.backgroundColor = UIColor.white
        self.view.addSubview(phoneNumberText!)
        phoneNumberText?.snp.makeConstraints{ make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(AdaptH(300))
            make.width.equalTo(AdaptW(200))
            make.height.equalTo(AdaptH(25))
        }
        
        nextButton = UIButton()
        nextButton?.setTitle("下一步", for: .normal)
        nextButton?.layer.masksToBounds = true
        nextButton?.layer.cornerRadius = 14.0
        nextButton?.backgroundColor = UIColor.blue
        nextButton?.titleLabel?.font = UIFont.systemFont(ofSize: 13.0)
        nextButton?.addTarget(self, action: #selector(goToNext(_:)), for: .touchUpInside)
        self.view.addSubview(nextButton!)
        nextButton?.snp.makeConstraints{ make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(AdaptH(330))
            make.width.equalTo(AdaptW(200))
            make.height.equalTo(AdaptH(25))
        }
    }
    
    @objc func goToNext(_ sender: UIButton) {
        if let number = phoneNumberText?.text { queryAccount(number: number) }
    }
    
}

extension FindPwd1ViewController {
    
    func queryAccount(number: String) {
        let params: NSMutableDictionary = NSMutableDictionary()
        params["number"] = number
        NetworkTools.shared.request(method: .POST, urlString: kMagicfindAccount, parameters: params) { (responseObject, error) in
            if error != nil {
                print(error!)
                self.isRegister = false
                return
            }
            
            if responseObject != nil {
                self.isRegister = true
                let findPwdViewController = FindPwd2ViewController()
                findPwdViewController.number = (self.phoneNumberText?.text)!
                self.navigationController?.pushViewController(findPwdViewController, animated: true)
                print(JSON(responseObject as Any))
            }
        }
    }
    
}
