//
//  LoginViewController.swift
//  Tracker
//
//  Created by StephenLouis on 2019/1/21.
//  Copyright © 2019 StephenLouis. All rights reserved.
//

import UIKit
import SnapKit
import SwiftyJSON

class LoginViewController: UIViewController {
    
    var keyboardNeedLayout: Bool = true
    
    var phoneNumberText: UITextField?
    var passwordText: UITextField?
    var loginButton: UIButton?
    var register: UIButton?
    var retrievePwd: UIButton?
    
    override func viewDidLoad() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        setupUI()
    }
    
    private func setupUI() {
        self.view.backgroundColor = UIColor.black
        
        phoneNumberText = UITextField()
        phoneNumberText?.keyboardType = UIKeyboardType.phonePad
        phoneNumberText?.backgroundColor = UIColor.white
        phoneNumberText?.layer.masksToBounds = true
        phoneNumberText?.layer.cornerRadius = 12.0  //圆角半径
        phoneNumberText?.layer.borderWidth = 1.0  //边框粗细
        phoneNumberText?.layer.borderColor = UIColor.gray.cgColor
        phoneNumberText?.placeholder = "  输入你的手机号码"
        self.view.addSubview(phoneNumberText!)
        phoneNumberText?.snp.makeConstraints{ make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(AdaptH(280))
            make.width.equalTo(AdaptW(220))
            make.height.equalTo(AdaptH(25))
        }
        
        passwordText = UITextField()
        passwordText?.keyboardType = UIKeyboardType.default
        passwordText?.backgroundColor = UIColor.white
        passwordText?.layer.masksToBounds = true
        passwordText?.layer.cornerRadius = 12.0  //圆角半径
        passwordText?.layer.borderWidth = 1.0  //边框粗细
        passwordText?.layer.borderColor = UIColor.gray.cgColor
        passwordText?.placeholder = "  输入6至20位登录密码"
        passwordText?.isSecureTextEntry = true
        self.view.addSubview(passwordText!)
        passwordText?.snp.makeConstraints{ make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(AdaptH(320))
            make.width.equalTo(AdaptW(220))
            make.height.equalTo(AdaptH(25))
        }
        
        loginButton = UIButton()
        loginButton?.setTitle("登录", for: .normal)
        loginButton?.backgroundColor = UIColor.blue
        loginButton?.layer.masksToBounds = true
        loginButton?.layer.cornerRadius = 14.0
        loginButton?.addTarget(self, action: #selector(login(_:)), for: .touchUpInside)
        self.view.addSubview(loginButton!)
        loginButton?.snp.makeConstraints{ make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(AdaptH(355))
            make.width.equalTo(AdaptW(220))
            make.height.equalTo(AdaptH(25))
        }
        
        register = UIButton()
        register?.setTitle("注册账号", for: .normal)
        register?.setTitleColor(UIColor.white, for: .normal)
        register?.addTarget(self, action: #selector(goToRegister(_:)), for: .touchUpInside)
        self.view.addSubview(register!)
        register?.snp.makeConstraints{ make in
            make.centerX.equalTo(130)
            make.centerY.equalTo(AdaptH(390))
            make.width.equalTo(AdaptW(80))
            make.height.equalTo(20)
        }
        
        retrievePwd = UIButton()
        retrievePwd?.setTitle("找回密码", for: .normal)
        retrievePwd?.setTitleColor(UIColor.white, for: .normal)
        self.view.addSubview(retrievePwd!)
        retrievePwd?.snp.makeConstraints{ make in
            make.centerX.equalTo(280)
            make.centerY.equalTo(AdaptH(390))
            make.width.equalTo(AdaptW(80))
            make.height.equalTo(20)
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
    
    // 跳转注册界面
    @objc func goToRegister(_ sender: UIButton) {
        let registerController: RegisterViewController = RegisterViewController()
        //self.present(registerController, animated: true, completion: nil)
        self.navigationController?.pushViewController(registerController, animated: true)
    }
    
    @objc func login(_ sender: UIButton) {
        if let number = phoneNumberText?.text,
            let password = passwordText?.text {
            if !Validate.phoneNum(number).isRight {
                print("非法手机号码")
                return
            }
            if !Validate.password(password).isRight {
                print("非法密码")
                return
            }
            loginAccount(number: number, password: password)
        }
    }
    
    func loginSuccess() {
        let homeController = NewHomeViewController()
        self.present(homeController, animated: true, completion: nil)
    }
    
}

extension LoginViewController {
    
    // 登录
    func loginAccount(number: String, password: String) {
        let params: NSMutableDictionary = NSMutableDictionary()
        params["number"] = number
        params["loginInfo"] = "tracker"
        params["password"] = password
        NetworkTools.shared.request(method: .POST, urlString: kMagicLogin.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!, parameters: params) {
            (responseObject, error) in
            if error != nil {
                print(error!)
                return
            }
            
            if responseObject != nil {
                print(JSON(responseObject as Any))
                let response = LoginResponse(jsonData: JSON(responseObject as Any))
                if response.resCode == "000" {
                    // 成功
                    self.loginSuccess()
                } else if response.resCode == "111" {
                    // 失败
                    print("登录失败")
                } else if response.resCode == "333" {
                    // 用户名或密码错误
                    print("用户名或密码错误")
                }
            }
        }
    }
}
