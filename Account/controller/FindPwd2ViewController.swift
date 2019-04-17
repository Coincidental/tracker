//
//  FindPwd2ViewController.swift
//  Tracker
//
//  Created by StephenLouis on 2019/1/22.
//  Copyright © 2019 StephenLouis. All rights reserved.
//

import Foundation
import SwiftyJSON

class FindPwd2ViewController: UIViewController {
    
    var smsCodeAlertLable: UILabel?
    var smsCodeText: UITextField?
    var smsCodeButton: UIButton?
    var passwordText: UITextField?
    var finshButton: UIButton?
    
    var number: String = "15156039033"
    var countdownTimer: Timer?
    
    var remainingSeconds: Int = 0 {
        willSet {
            smsCodeButton?.setTitle("重发\(newValue)s", for: .normal)
            
            if newValue <= 0 {
                smsCodeButton?.setTitle("获取验证码", for: .normal)
                isCounting = false
            }
        }
    }
    
    var isCounting = false {
        willSet {
            if newValue {
                countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime(_:)), userInfo: nil, repeats: true)
                remainingSeconds = 60
                
                smsCodeButton?.backgroundColor = UIColor.gray
            } else {
                countdownTimer?.invalidate()
                countdownTimer = nil
                
                smsCodeButton?.backgroundColor = UIColor.blue
            }
            
            smsCodeButton?.isEnabled = !newValue
        }
    }
    
    override func viewDidLoad() {
        self.view.backgroundColor = UIColor.black
        
        smsCodeAlertLable = UILabel()
        smsCodeAlertLable?.text = ""
        smsCodeAlertLable?.font = UIFont.systemFont(ofSize: 13.0)
        smsCodeAlertLable?.textColor = UIColor.white
        self.view.addSubview(smsCodeAlertLable!)
        smsCodeAlertLable?.snp.makeConstraints{ make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(AdaptH(250))
            make.width.equalTo(AdaptW(200))
            make.height.equalTo(AdaptH(25))
        }
        
        smsCodeText = UITextField()
        smsCodeText?.backgroundColor = UIColor.white
        smsCodeText?.placeholder = "输入短信验证码"
        smsCodeText?.layer.masksToBounds = true
        smsCodeText?.layer.cornerRadius = 12.0
        smsCodeText?.layer.borderWidth = 2.0
        smsCodeText?.layer.borderColor = UIColor.gray.cgColor
        smsCodeText?.keyboardType = UIKeyboardType.numberPad
        self.view.addSubview(smsCodeText!)
        smsCodeText?.snp.makeConstraints{ make in
            make.centerX.equalTo(AdaptW(145))
            make.centerY.equalTo(AdaptH(280))
            make.width.equalTo(AdaptW(135))
            make.height.equalTo(AdaptH(25))
        }
        
        smsCodeButton = UIButton()
        smsCodeButton?.setTitle("获取验证码", for: .normal)
        smsCodeButton?.titleLabel?.font = UIFont.systemFont(ofSize: 10)
        smsCodeButton?.backgroundColor = UIColor.blue
        smsCodeButton?.layer.masksToBounds = true
        smsCodeButton?.layer.cornerRadius = 14.0
        smsCodeButton?.addTarget(self, action: #selector(getVerificationCode(_:)), for: .touchUpInside)
        self.view.addSubview(smsCodeButton!)
        smsCodeButton?.snp.makeConstraints{ make in
            make.centerX.equalTo(AdaptW(260))
            make.centerY.equalTo(AdaptH(280))
            make.width.equalTo(AdaptW(75))
            make.height.equalTo(AdaptH(25))
        }
        
        passwordText = UITextField()
        passwordText?.placeholder = "输入6至20位登录密码"
        passwordText?.backgroundColor = UIColor.white
        passwordText?.layer.masksToBounds = true
        passwordText?.layer.cornerRadius = 12.0
        passwordText?.layer.borderWidth = 2.0
        passwordText?.layer.borderColor = UIColor.gray.cgColor
        passwordText?.isSecureTextEntry = true
        self.view.addSubview(passwordText!)
        passwordText?.snp.makeConstraints{ make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(AdaptH(310))
            make.width.equalTo(AdaptW(220))
            make.height.equalTo(AdaptH(25))
        }
        
        finshButton = UIButton()
        finshButton?.setTitle("完成", for: .normal)
        finshButton?.setTitleColor(UIColor.white, for: .normal)
        finshButton?.backgroundColor = UIColor.blue
        finshButton?.layer.masksToBounds = true
        finshButton?.layer.cornerRadius = 14.0
        finshButton?.addTarget(self, action: #selector(findMyPassword(_:)), for: .touchUpInside)
        self.view.addSubview(finshButton!)
        finshButton?.snp.makeConstraints{ make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(AdaptH(340))
            make.width.equalTo(AdaptW(220))
            make.height.equalTo(AdaptH(25))
        }
        
    }
    
    @objc func getVerificationCode(_ sender: UIButton) {
        if Validate.phoneNum(number).isRight {
            getSmsCode(phoneNum: number, smsType: 2)
        } else {
            print("非法手机号码 \(number)")
            return
        }
    }
    
    @objc func findMyPassword(_ sender: UIButton) {
        
        if let password = passwordText?.text,
            let smsCode = smsCodeText?.text {
            if !Validate.password(password).isRight {
                return
            }
            findPassword(number: number, password: password, smsCode: smsCode)
        }
    }
    
    @objc func updateTime(_ timer: Timer) {
        remainingSeconds -= 1
    }
    
    // 获取验证码
    func getSmsCode(phoneNum: String, smsType: Int) {
        let params: NSMutableDictionary = NSMutableDictionary()
        params["number"] = phoneNum     // 手机号码
        params["smsType"] = smsType     // 短信类型
        NetworkTools.shared.request(method: .POST, urlString: kMagicSmsCode.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!, parameters: params) { (responseObject, error) in
            if error != nil {
                print(error!)
                return
            }
            
            if responseObject != nil {
                print(JSON(responseObject as Any))
                let response = LoginResponse(jsonData: JSON(responseObject as Any))
                if response.resCode == "000" {
                    self.isCounting = true
                }
            }
        }
    }
    
    func findPassword(number: String, password: String, smsCode: String) {
        let params: NSMutableDictionary = NSMutableDictionary()
        params["smsType"] = 2
        params["number"] = number
        params["password"] = password
        params["smsCode"] = smsCode
        NetworkTools.shared.request(method: .POST, urlString: kMagicFindPassword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!, parameters: params) { (responseObject, error) in
                if error != nil {
                    print(error!)
                    return
                }
                
                if responseObject != nil {
                    print(JSON(responseObject as Any))
                }
        }
    }
    
}
