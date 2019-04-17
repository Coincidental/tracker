//
//  RegisterViewController.swift
//  Tracker
//
//  Created by StephenLouis on 2019/1/21.
//  Copyright © 2019 StephenLouis. All rights reserved.
//

import UIKit
import SwiftyJSON

class RegisterViewController: UIViewController {
    var keyboardNeedLayout: Bool = false
    var phoneTextField: UITextField?
    var verificationCodeText: UITextField?
    var verificationCodeButton: UIButton?
    var passwordTextField: UITextField?
    var protocolCheckBox: UIButton?
    var readProtocolText: UILabel?
    var protocolName: UIButton?
    var registerButton: UIButton?
    
    var countdownTimer: Timer?
    var checkSelected: Bool = false
    
    var remainingSeconds: Int = 0 {
        willSet {
            verificationCodeButton?.setTitle("重发\(newValue)s", for: .normal)
            
            if newValue <= 0 {
                verificationCodeButton?.setTitle("获取验证码", for: .normal)
                isCounting = false
            }
        }
    }
    
    var isCounting = false {
        willSet {
            if newValue {
                countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime(_:)), userInfo: nil, repeats: true)
                remainingSeconds = 60
                
                verificationCodeButton?.backgroundColor = UIColor.gray
            } else {
                countdownTimer?.invalidate()
                countdownTimer = nil
                
                verificationCodeButton?.backgroundColor = UIColor.blue
            }
            
            verificationCodeButton?.isEnabled = !newValue
        }
    }
    
    override func viewDidLoad() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        setupUI()
    }
    
    private func setupUI() {
        self.view.backgroundColor = UIColor.black
        
        phoneTextField = UITextField()
        phoneTextField?.backgroundColor = UIColor.white
        phoneTextField?.placeholder = "输入你的手机号码"
        phoneTextField?.layer.masksToBounds = true
        phoneTextField?.layer.cornerRadius = 12.0
        phoneTextField?.layer.borderWidth = 2.0
        phoneTextField?.layer.borderColor = UIColor.gray.cgColor
        phoneTextField?.keyboardType = UIKeyboardType.namePhonePad
        self.view.addSubview(phoneTextField!)
        phoneTextField?.snp.makeConstraints{ make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(AdaptH(260))
            make.width.equalTo(AdaptW(220))
            make.height.equalTo(AdaptH(25))
        }
        
        verificationCodeText = UITextField()
        verificationCodeText?.backgroundColor = UIColor.white
        verificationCodeText?.placeholder = "输入短信验证码"
        verificationCodeText?.layer.masksToBounds = true
        verificationCodeText?.layer.cornerRadius = 12.0
        verificationCodeText?.layer.borderWidth = 2.0
        verificationCodeText?.layer.borderColor = UIColor.gray.cgColor
        verificationCodeText?.keyboardType = UIKeyboardType.numberPad
        self.view.addSubview(verificationCodeText!)
        verificationCodeText?.snp.makeConstraints{ make in
            make.centerX.equalTo(AdaptW(145))
            make.centerY.equalTo(AdaptH(290))
            make.width.equalTo(AdaptW(135))
            make.height.equalTo(AdaptH(25))
        }
        
        verificationCodeButton = UIButton()
        verificationCodeButton?.setTitle("获取验证码", for: .normal)
        verificationCodeButton?.titleLabel?.font = UIFont.systemFont(ofSize: 10)
        verificationCodeButton?.backgroundColor = UIColor.blue
        verificationCodeButton?.layer.masksToBounds = true
        verificationCodeButton?.layer.cornerRadius = 14.0
        verificationCodeButton?.addTarget(self, action: #selector(getVerificationCode(_:)), for: .touchUpInside)
        self.view.addSubview(verificationCodeButton!)
        verificationCodeButton?.snp.makeConstraints{ make in
            make.centerX.equalTo(AdaptW(260))
            make.centerY.equalTo(AdaptH(290))
            make.width.equalTo(AdaptW(75))
            make.height.equalTo(AdaptH(25))
        }
        
        passwordTextField = UITextField()
        passwordTextField?.placeholder = "输入6至20位登录密码"
        passwordTextField?.backgroundColor = UIColor.white
        passwordTextField?.layer.masksToBounds = true
        passwordTextField?.layer.cornerRadius = 12.0
        passwordTextField?.layer.borderWidth = 2.0
        passwordTextField?.layer.borderColor = UIColor.gray.cgColor
        passwordTextField?.isSecureTextEntry = true
        self.view.addSubview(passwordTextField!)
        passwordTextField?.snp.makeConstraints{ make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(AdaptH(320))
            make.width.equalTo(AdaptW(220))
            make.height.equalTo(AdaptH(25))
        }
        
        protocolCheckBox = UIButton()
        protocolCheckBox?.isSelected = false
        protocolCheckBox?.backgroundColor = UIColor.white
        protocolCheckBox?.setImage(UIImage(named: "checkbox"), for: .selected)
        protocolCheckBox?.addTarget(self, action: #selector(protocolCheck(_:)), for: .touchUpInside)
        protocolCheckBox?.layer.masksToBounds = true
        protocolCheckBox?.layer.cornerRadius = 5.0
        self.view.addSubview(protocolCheckBox!)
        protocolCheckBox?.snp.makeConstraints{ make in
            make.centerX.equalTo(AdaptW(90))
            make.centerY.equalTo(AdaptH(350))
            make.width.equalTo(AdaptW(15))
            make.height.equalTo(AdaptH(12))
        }
        
        readProtocolText = UILabel()
        readProtocolText?.text = "我已阅读并接受"
        readProtocolText?.backgroundColor = UIColor.clear
        readProtocolText?.font = UIFont.systemFont(ofSize: 11)
        readProtocolText?.textColor = UIColor.white
        self.view.addSubview(readProtocolText!)
        readProtocolText?.snp.makeConstraints{ make in
            make.centerX.equalTo(AdaptW(147))
            make.centerY.equalTo(AdaptH(346))
            make.width.equalTo(AdaptW(86))
            make.height.equalTo(AdaptH(15))
        }
        
        protocolName = UIButton()
        protocolName?.backgroundColor = UIColor.clear
        protocolName?.setTitle("《国美通讯追踪器服务协议》", for: .normal)
        protocolName?.setTitleColor(UIColor.blue, for: .normal)
        protocolName?.titleLabel?.font = UIFont.systemFont(ofSize: 10)
        self.view.addSubview(protocolName!)
        protocolName?.snp.makeConstraints{ make in
            make.left.equalTo((readProtocolText?.snp.right)!).offset(AdaptW(-8))
            make.centerY.equalTo(AdaptH(348))
            make.width.equalTo(AdaptW(125))
            make.height.equalTo(AdaptH(15))
        }
        
        registerButton = UIButton()
        registerButton?.setTitle("注册", for: .normal)
        registerButton?.setTitleColor(UIColor.white, for: .normal)
        registerButton?.backgroundColor = UIColor.blue
        registerButton?.layer.masksToBounds = true
        registerButton?.layer.cornerRadius = 14.0
        registerButton?.addTarget(self, action: #selector(registerAccount(_:)), for: .touchUpInside)
        self.view.addSubview(registerButton!)
        registerButton?.snp.makeConstraints{ make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(AdaptH(375))
            make.width.equalTo(AdaptW(220))
            make.height.equalTo(AdaptH(25))
        }
    }
    
    @objc func protocolCheck(_ sender: UIButton) {
        protocolCheckBox?.isSelected = !(protocolCheckBox?.isSelected)!
        checkSelected = (protocolCheckBox?.isSelected)!
    }
    
    @objc func getVerificationCode(_ sender: UIButton) {
        
        if let number = phoneTextField?.text {
            if Validate.phoneNum(number).isRight {
                getSmsCode(phoneNum: number, smsType: 1)
            } else {
                print("非法手机号码 \(number)")
                return
            }
        } else {
            print("手机号码为空")
            return
        }
    }
    
    @objc func updateTime(_ timer: Timer) {
        remainingSeconds -= 1
    }
    
    @objc func registerAccount(_ sender: UIButton) {
        if let number = phoneTextField?.text,
            let smsCode = verificationCodeText?.text,
            let passwd = passwordTextField?.text {
            if !Validate.phoneNum(number).isRight {
                print("非法手机号码")
                return
            }
            if !Validate.password(passwd).isRight {
                print("非法密码")
                return
            }
            if !checkSelected {
                print("协议未被选中")
                return
            }
            if smsCode == "" {
                print("验证码为空")
            }
            register(number: number, password: passwd, smsCode: smsCode)
        }
    }
    
    // 输入法显示
    @objc func keyboardWillShow(_ notification: Notification) {
        print("show")
        if let userInfo = notification.userInfo,
            let value = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
            let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
            let curve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt {
            let frame = value.cgRectValue
            let intersection = self.view.frame.intersection(frame)
            
            let deltaY = intersection.height / 4
            if keyboardNeedLayout {
                UIView.animate(withDuration: duration, delay: 0.0, options: UIView.AnimationOptions(rawValue: curve), animations: {
                    self.view.frame = CGRect(x: 0, y: -deltaY, width: self.view.bounds.width, height: self.view.bounds.height)
                    self.keyboardNeedLayout = false
                    self.view.layoutIfNeeded()
                }, completion: nil)
            }
        }
    }
    
    // 输入法消失
    @objc func keyboardWillHide(_ notification: Notification) {
        print("hide")
        if let userInfo = notification.userInfo,
            let value = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
            let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
            let curve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt {
            let frame = value.cgRectValue
            let intersection = self.view.frame.intersection(frame)
            
            let deltaY = intersection.height / 4
            UIView.animate(withDuration: duration, delay: 0.0, options: UIView.AnimationOptions(rawValue: curve), animations: {
                self.view.frame = CGRect(x: 0, y: deltaY, width: self.view.bounds.width, height: self.view.bounds.height)
                self.keyboardNeedLayout = true
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
    @objc func pwdTextSwith(_ sender: UIButton) {
        // 切花按钮状态
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected { // 选中状态就是明文
            let tempPwdStr = self.passwordTextField?.text
            self.passwordTextField?.text = "" // 可以防止切换的时候光标偏移
            self.passwordTextField?.isSecureTextEntry = false
            self.passwordTextField?.text = tempPwdStr
        } else { // 暗文
            let tempPwdStr = self.passwordTextField?.text
            self.passwordTextField?.text = ""
            self.passwordTextField?.isSecureTextEntry = true
            self.passwordTextField?.text = tempPwdStr
        }
    }
}

extension RegisterViewController {
    
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
                self.isCounting = true
            }
        }
    }
    
    // 注册账号
    func register(number: String, password: String, smsCode: String) {
        let params: NSMutableDictionary = NSMutableDictionary()
        params["number"] = number      // 手机号码
        params["smsType"] = 1          // 短信类型
        params["password"] = password  // 密码
        params["smsCode"] = smsCode    // 短信验证码
        NetworkTools.shared.request(method: .POST, urlString: kMagicRegister.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!, parameters: params) {
            (responseObject, error) in
            if error != nil {
                print(error!)
                return
            }
            
            if responseObject != nil {
                print(JSON(responseObject as Any))
            }
        }
    }
    
    // 查询账号
    func findAccount(phoneNum: String) {
        let params: NSMutableDictionary = NSMutableDictionary()
        params["number"] = phoneNum   // 手机号码
        NetworkTools.shared.request(method: .POST, urlString: kMagicfindAccount.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!, parameters: params) { (responseObject, error) in
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
