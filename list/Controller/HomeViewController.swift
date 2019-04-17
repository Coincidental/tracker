//
//  HomeViewController.swift
//  Tracker
//
//  Created by StephenLouis on 2018/10/25.
//  Copyright © 2018 StephenLouis. All rights reserved.
//

import UIKit
import SnapKit
import ZHRefresh
import SwiftyJSON

class HomeViewController: UIViewController {

    let cell_identifier: String = "HomeViewController"
    var deviceTableView = UITableView()
    var navTitleLable = UILabel()
    var bindNewDevice = UIButton()
    var loginModel: LoginInfoModel?
    
    var isFirstLogin = true
    
    var devices = [DeviceInfoModel]()
    
    var locationManager: AMapLocationManager?
    var userLocation = MAPointAnnotation()
    var token: String!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.createViewUI()
        login()
        initLocationManager()
        
    }
    
    
    func createViewUI() {
        
        navTitleLable.text = "智能定位器"
        navTitleLable.font = UIFont.boldSystemFont(ofSize: 20)
        self.view.addSubview(navTitleLable)
        navTitleLable.snp.makeConstraints{ (make) in
            make.top.equalToSuperview().offset(Adapt(kStatusHeight))
            make.left.equalToSuperview().offset(Adapt(5))
            make.width.equalTo(Adapt(100))
            make.height.equalTo(Adapt(30))
        }
        
        bindNewDevice.set(image: UIImage(named: "card_refresh"), title: "绑定设备", titlePosition: .right, additionalSpacing: 10.0, state: .normal)
        bindNewDevice.setTitleColor(UIColor.black, for: .normal)
        bindNewDevice.setTitleColor(UIColor.orange, for: .highlighted)
        bindNewDevice.imageView?.contentMode = .scaleAspectFit
        bindNewDevice.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        bindNewDevice.addTarget(self, action: #selector(addNewDevice(_:)), for: .touchUpInside)
        self.view.addSubview(bindNewDevice)
        bindNewDevice.snp.makeConstraints{ (make) in
            make.top.equalToSuperview().offset(Adapt(kStatusHeight))
            make.right.equalToSuperview().offset(Adapt(-5))
            make.width.equalTo(Adapt(120))
            make.height.equalTo(Adapt(30))
        }
        
        deviceTableView.tableFooterView = UIView.init()
        deviceTableView.delegate = self
        deviceTableView.dataSource = self
        deviceTableView.register(MapTableViewCell.self, forCellReuseIdentifier: cell_identifier)
        self.view.addSubview(self.deviceTableView)
        deviceTableView.snp.makeConstraints{ (make) in
            make.top.equalTo(navTitleLable.snp.bottom).offset(Adapt(20))
            make.left.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalToSuperview()
        }
        
        deviceTableView.register(MapTableViewCell.classForCoder(), forCellReuseIdentifier: cell_identifier)
        
        if let header = ZHRefreshNormalHeader.headerWithRefresing(target: self, action: #selector(updateMaps)) as? ZHRefreshNormalHeader {
            header.lastUpdatedTimeLable.isHidden = true
            // 设置文字
            header.set(title: "刷新完成...", for: .idle)
            header.set(title: "释放刷新...", for: .pulling)
            header.set(title: "加载中...", for: .refreshing)
            // 设置字体
            header.stateLable.font = UIFont.systemFont(ofSize: 15)
            // 设置颜色
            header.stateLable.textColor = UIColor.brown
            
            deviceTableView.header = header
        }
    }
    
    @objc func updateMaps() {
        queryAllDevice(token: self.token)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            /// 刷新tableView
            self.deviceTableView.reloadData()
            /// 结束刷新
            self.deviceTableView.header?.endRefreshing()
        }
    }
    
    @objc func addNewDevice(_ sender: UIButton) {
        var alert: UIAlertController!
        alert = UIAlertController(title: "绑定设备", message: nil, preferredStyle: .alert)
        alert.addTextField{
            (textField: UITextField!) -> Void in
            textField.placeholder = "设备名"
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        let bindAciton = UIAlertAction(title: "绑定", style: .default, handler: {
            action in
            // 绑定设备
            let deviceName = alert.textFields!.first!
            print("绑定设备名: \(deviceName.text!)")
            self.bindDevices(token: self.token!, trackerNumber: deviceName.text!)
        })
        alert.addAction(cancelAction)
        alert.addAction(bindAciton)
        self.present(alert,animated: true,completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
}

extension HomeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let viewController = ViewController()
        //self.present(viewController, animated: true, completion: nil)
        viewController.device = devices[indexPath.row]
        viewController.userLocation = self.userLocation
        
        self.navigationController?.pushViewController(viewController, animated: true)
        print("\(indexPath.row) 行被点击或选中")
    }
    
}

extension HomeViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return devices.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 220
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let deviceCell = tableView.dequeueReusableCell(withIdentifier: cell_identifier, for: indexPath) as! MapTableViewCell
        deviceCell.setValueForCell(device: devices[indexPath.row])
        
        return deviceCell
    }
    
}

extension HomeViewController {
    
    // 登录
    func requestForTrackers() {
        
        let urlString = "http://techain.free.idcfengye.com/tracker/user/demo/login"
        let url = urlString.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        NetworkTools.shared.request(method: .POST, urlString: url!, parameters: nil) { (responseObject, error) in
            if error != nil {
                print(error!)
                return
            }
            
            if responseObject != nil {
                print(JSON(responseObject as Any))
                self.loginModel = LoginInfoModel(jsonData: JSON(responseObject as Any))
                self.token = self.loginModel!.loginData.token
                CoreDataManager.shared.saveUserWith(token: self.token)
            }
        }
    }
    
    // 绑定设备
    func bindDevices(token: String, trackerNumber: String) {
        let timestamp = Utils.getNowTimeStamp()
        let params = "token=\(token)&timestamp=\(timestamp)&trackerNumber=\(trackerNumber)"
        let sign = DataEncoding.Encode_AES_ECB(strToEncode: params)
        let urlString = "http://techain.free.idcfengye.com/tracker/user/demo/bind?token=\(token)&timestamp=\(timestamp)&trackerNumber=\(trackerNumber)&sign=\(sign)"
        let url = urlString.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        NetworkTools.shared.request(method: .POST, urlString: url!, parameters: nil) { (responseObject, error) in
            if error != nil {
                print(error!)
                return
            }
            
            /*guard (responseObject as [String: AnyObject]?) != nil else {
             return
             }*/
            if responseObject != nil {
                print(JSON(responseObject!))
            }
            //let responseDevices = DeviceResponse(jsonData: JSON(responseObject))
            //print(responseDevices.devices.count)
            //self.devices = responseDevices.devices
            //self.deviceTableView.reloadData()
        }
    }
    
    // 查询单个设备demo
    func querySingleDevice(token: String, trackerNumber: String, timestamp: String, sign: String) {
        NetworkTools.shared.post("http://192.168.20.148:8080//user/demo/showAllBind?token=20181025175720814969eb93f94b6abac2a4cb6d6e40fd&timestamp=20181102175720&sign=81A02F157651729F0D30D45AA1C01C9A",
                                 parameters: nil,
                                 progress: nil,
                                 success: { (task, responseObject) in
                                    if responseObject != nil {
                                
                                    }
        },
                                 failure: { (task, error) in
                                    print("error")
        })
    }
    
    // 获取所有绑定设备信息
    func queryAllDevice(token: String) {
        let timestamp = Utils.getNowTimeStamp()
        let params = "token=\(token)&timestamp=\(timestamp)"
        let sign = DataEncoding.Encode_AES_ECB(strToEncode: params)
        NetworkTools.shared.request(method: .POST, urlString: "http://techain.free.idcfengye.com/tracker/user/demo/showAllBind?token=\(token)&timestamp=\(timestamp)&sign=\(sign)", parameters: nil) { (responseObject, error) in
            if error != nil {
                print(error!)
                return
            }
            
            /*guard (responseObject as [String: AnyObject]?) != nil else {
                return
            }*/
            if responseObject != nil {
                print(JSON(responseObject!))
            }
            let responseDevices = DeviceResponse(jsonData: JSON(responseObject as Any))
            print(responseDevices.devices.count)
            self.devices = responseDevices.devices
            self.deviceTableView.reloadData()
        }
    }

}

extension HomeViewController: AMapLocationManagerDelegate{
    
    // 单次定位，userlocation
    func initLocationManager() {
        locationManager = AMapLocationManager()
        locationManager?.delegate = self
        
        locationManager?.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager?.locationTimeout = 2
        locationManager?.reGeocodeTimeout = 2
        
        locationManager?.requestLocation(withReGeocode: false, completionBlock: { [weak self] (location: CLLocation?, reGeocode: AMapLocationReGeocode?, error: Error?) in
            if let error = error {
                let error = error as NSError
                
                if error.code == AMapLocationErrorCode.locateFailed.rawValue {
                    // 定位错误: 此时location和regeocode没有返回值, 不进行annotation的添加
                    return
                }
                else if error.code == AMapLocationErrorCode.reGeocodeFailed.rawValue
                    || error.code == AMapLocationErrorCode.timeOut.rawValue
                    || error.code == AMapLocationErrorCode.cannotFindHost.rawValue
                    || error.code == AMapLocationErrorCode.badURL.rawValue
                    || error.code == AMapLocationErrorCode.notConnectedToInternet.rawValue
                    || error.code == AMapLocationErrorCode.cannotConnectToHost.rawValue {
                    // 逆地址错误: 在带逆地理的单次定位中，逆地理过程可能发生错误, 此时location有返回值，regeocode无返回值, 进行annotation的添加
                    
                }
                else {
                    // 没有错误: location有返回值，regeocode是否有返回值取决于是否进行逆地理操作, 进行annotation的添加
                }
            }
            
            if let location = location {
                print("location success")
                self?.userLocation.coordinate = location.coordinate
            }
            
            if reGeocode != nil {
                
            }
        })
    }
}

extension HomeViewController {
    
    func login() {
        let users = CoreDataManager.shared.getAllUser()
        if users.count > 0 {
            self.isFirstLogin = false
            for user in users {
                token = user.token!
            }
            print("isFirstLogin: false")
        } else {
            requestForTrackers()
            self.isFirstLogin = false
            print("isFirstLogin: true")
        }
        if !isFirstLogin { queryAllDevice(token: token!) }
    }
    
}
