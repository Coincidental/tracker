//
//  NewHomeViewController.swift
//  Tracker
//
//  Created by StephenLouis on 2018/11/16.
//  Copyright © 2018 StephenLouis. All rights reserved.
//

import UIKit
import SwiftyJSON
import Kingfisher

class NewHomeViewController: UIViewController {
    
    var collectionView: UICollectionView?
    var layout: CardMapLayout?
    var adView: AdScrollView?
    var navImage: UIImageView?
    var navTitleLable: UILabel?
    var bindNewDevice: UIButton?
    var imgArr: [String] = [String]()
    
    var selectedIndex = 0
    var selected = 0
    var selectedIndexPath: IndexPath?
    var isFirstLogin = true
    
    var loginModel: LoginInfoModel?
    var token: String = ""
    var devices = [DeviceInfoModel]()
    var userLocation = MAPointAnnotation()
    let popover = PopoverView()
    
    var locationManager: AMapLocationManager?
    
    var contentOffset: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        Login()
        initLocationManager()
        initAdCollectionView()
        
    }
    
    func setupUI() {
        // 导航栏图标
        navImage = UIImageView(image: UIImage(named: "image"))
        self.view.addSubview(navImage!)
        navImage?.snp.makeConstraints{ (make) in
            make.top.equalToSuperview().offset(Adapt(kStatusHeight))
            make.left.equalToSuperview().offset(Adapt(20))
            make.width.equalTo(Adapt(40))
            make.height.equalTo(Adapt(40))
        }
        
        // 标题
        navTitleLable = UILabel()
        navTitleLable?.text = "GOME智能定位器"
        navTitleLable?.textColor = UIColor.white
        navTitleLable?.font = UIFont.boldSystemFont(ofSize: 20)
        self.view.addSubview(navTitleLable!)
        navTitleLable?.snp.makeConstraints{ (make) in
            make.top.equalToSuperview().offset(Adapt(kStatusHeight+5))
            make.left.equalToSuperview().offset(Adapt(65))
            make.width.equalTo(Adapt(200))
            make.height.equalTo(Adapt(30))
        }
        
        // 绑定设备
        bindNewDevice = UIButton()
        bindNewDevice?.set(image: UIImage(named: "add"), title: "绑定设备", titlePosition: .right, additionalSpacing: 10.0, state: .normal)
        bindNewDevice?.setTitleColor(UIColor.white, for: .normal)
        bindNewDevice?.setTitleColor(UIColor.black, for: .highlighted)
        bindNewDevice?.imageView?.contentMode = .scaleAspectFit
        bindNewDevice?.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        bindNewDevice?.addTarget(self, action: #selector(addNewDevice(_:)), for: .touchUpInside)
        self.view.addSubview(bindNewDevice!)
        bindNewDevice?.snp.makeConstraints{ (make) in
            make.top.equalToSuperview().offset(Adapt(kStatusHeight+5))
            make.right.equalToSuperview().offset(Adapt(-5))
            make.width.equalTo(Adapt(120))
            make.height.equalTo(Adapt(30))
        }
        
        // 地图卡片视图
        self.view.backgroundColor = UIColor.orange
        
        layout = CardMapLayout()
        layout?.itemSize = CGSize(width: kScreenW-80, height: AdaptH(360))
        
        let rect = CGRect(x: 0, y: kStatusHeight + kNavigationBarHeight, width: kScreenW, height: AdaptH(400))
        collectionView = UICollectionView(frame: rect, collectionViewLayout: layout!)
        collectionView?.delegate = self
        collectionView?.dataSource = self
        view.addSubview(collectionView!)
        collectionView?.register(CardMapViewCell.self, forCellWithReuseIdentifier: "identifier")
        collectionView?.register(CardNoDeviceViewCell.self, forCellWithReuseIdentifier: "emptyIdentifier")
        collectionView?.backgroundColor = UIColor.clear
        collectionView?.showsHorizontalScrollIndicator = false
        
    }
    
    func initAdCollectionView() {
        queryAdInfo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
}

extension NewHomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if devices.count == 0 {
            return 1
        } else {
            return devices.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if devices.count > 0 {
            let device = devices[indexPath.item]
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "identifier", for: indexPath) as! CardMapViewCell
            let mapView = cell.mapView
            let pointAnnotation = MAPointAnnotation()
            if let latitude = device.trackerLatitude, let longitude = device.trackerLongitude {
                pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                mapView?.centerCoordinate = pointAnnotation.coordinate
                mapView?.removeAnnotations(mapView?.annotations)
                mapView?.addAnnotation(pointAnnotation)
            }
            
            let updateIcon = cell.updateIcon
            let updateClick = UITapGestureRecognizer(target: self, action: #selector(updateIconClick(_:)))
            updateIcon?.isUserInteractionEnabled = true
            updateClick.numberOfTapsRequired = 1
            updateClick.numberOfTouchesRequired = 1
            updateIcon?.addGestureRecognizer(updateClick)
            
            let mapViewClick = UITapGestureRecognizer(target: self, action: #selector(goToDetail))
            mapViewClick.numberOfTapsRequired = 1
            mapViewClick.numberOfTouchesRequired = 1
            mapView?.addGestureRecognizer(mapViewClick)
            
            let batteryView = cell.batteryView
            batteryView?.batteryLevel = device.trackerBattery!
            batteryView?.setStatus(status: device.trackerOnline!)
            batteryView?.setNeedsLayout()
            
            cell.setStatus(status: device.trackerOnline!, batteryLevel: device.trackerBattery!)
            //let batteryLabel = cell.batteryLevelLabel
            //batteryLabel?.text = "\(device.trackerBattery!)%"
            
            let updateTime = cell.lastUpdateTime
            let updateTimeString = Utils.getFormatTime(dateInt: device.trackerLastUpdate!, format: "MM-dd HH:mm")
            updateTime?.text = "最后更新: \(updateTimeString)"
            
            let deviceName = cell.deviceName
            deviceName?.text = "\(device.trackerName!)"
            
            return cell
        } else {
            let emptyCell = collectionView.dequeueReusableCell(withReuseIdentifier: "emptyIdentifier", for: indexPath) as! CardNoDeviceViewCell
            
            let bindButton = emptyCell.bindButton
            bindButton?.addTarget(self, action: #selector(addNewDevice(_:)), for: .touchUpInside)
            return emptyCell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("selected in \(indexPath.row)")
        selectedIndex = indexPath.row
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        contentOffset = scrollView.contentOffset.x
    }
    
    // 当前显示的collectionCell
    func showCell(collectionView: UICollectionView) -> CardMapViewCell? {
        var visibleCells = collectionView.visibleCells
        if visibleCells.count > 0 {
            if visibleCells.count == 1 {
                // 只有一页
                let cell1 = visibleCells.first as! CardMapViewCell
                return cell1
            } else if visibleCells.count == 2 {
                // 只有两个设备
                if devices.count == 2 {
                    if contentOffset == 0.0 {
                        return (visibleCells[1] as! CardMapViewCell)
                    } else {
                        return (visibleCells[0] as! CardMapViewCell)
                    }
                }
                // 多于两个设备
                if visibleCells[0].convert(visibleCells[0].center, to: self.view).x < 300 {
                    return (visibleCells[1] as! CardMapViewCell)
                }
                for cell in visibleCells {
                    if cell.convert(cell.center, to: self.view).x < 300 {
                        // 第一页
                        return (cell as! CardMapViewCell)
                    }
                }
                // 最后一页
                return (visibleCells[0] as! CardMapViewCell)
            } else if visibleCells.count == 3 {
                visibleCells.sort(by: { $0.convert($0.center, to: self.view).x < $1.convert($1.center, to: self.view).x })
                // 中间页
                return (visibleCells[1] as! CardMapViewCell)
            }
        }
        return nil
    }

}

extension NewHomeViewController {
    // 绑定设备
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
            self.bindDevice(token: self.token, trackerNumber: deviceName.text!)
        })
        alert.addAction(cancelAction)
        alert.addAction(bindAciton)
        self.present(alert,animated: true,completion: nil)
    }
    
    // 刷新按钮
    @objc func updateIconClick(_ sender: UITapGestureRecognizer) {
        print("update Click")
        let imageView = sender.view as! UIImageView
        let rotationAnimation = CABasicAnimation()
        rotationAnimation.keyPath = "transform.rotation.z"
        rotationAnimation.toValue = Double.pi * 2.0
        rotationAnimation.duration = 0.5
        rotationAnimation.isCumulative = true
        rotationAnimation.repeatCount = 2
        imageView.layer.add(rotationAnimation, forKey: "rotationAnimation")
        
        let show = showCell(collectionView: collectionView!)
        selected = (collectionView?.indexPath(for: show!)!.row)!
        selectedIndexPath = collectionView?.indexPath(for: show!)!
        querySingleDevice(token: self.token, trackerNumber: devices[selected].trackerNumber!)
        if let show = show {
            let aView = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
            aView.text = "预计需30秒"
            aView.contentMode = .center
            popover.show(aView, point: CGPoint(x: 302, y: 52), inView: show)
        }
    
        // 刷新单个cell
        //collectionView?.reloadItems(at: <#T##[IndexPath]#>)
    }
    
    // 跳转到详细界面
    @objc func goToDetail() {
        let viewController = ViewController()
        viewController.token = self.token
        viewController.device = devices[selectedIndex]
        viewController.userLocation = self.userLocation
        viewController.delegate = self
        self.present(viewController, animated: true, completion: nil)
        print("进入设备 \(selectedIndex+1)")
    }
}

/// 网络请求
extension NewHomeViewController {
    
    // 登录
    func loginForUser() {
        let url = kLoginUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
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
    func bindDevice(token: String, trackerNumber: String) {
        let timestamp = Utils.getNowTimeStamp()
        let params = "token=\(token)&timestamp=\(timestamp)&trackerNumber=\(trackerNumber)"
        let sign = DataEncoding.Encode_AES_ECB(strToEncode: params)
        let urlString = "\(kBindUrl)token=\(token)&timestamp=\(timestamp)&trackerNumber=\(trackerNumber)&sign=\(sign)"
        let url = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        NetworkTools.shared.request(method: .POST, urlString: url!, parameters: nil) { (responseObject, error) in
            if error != nil {
                print(error!)
                return
            }
            
            if responseObject != nil {
                print(JSON(responseObject as Any))
                let response = ResponseBase(jsonData: JSON(responseObject as Any))
                if response.code == 400 { // 绑定成功
                    MyToast.my_show(msg: "设备绑定成功", onView: nil, success: nil, duration: 2.0, position: MyToastPosition.bottom)
                    self.queryAllDevice(token: token)
                } else if response.code == 505 {
                    MyToast.my_show(msg: "设备已绑定", onView: nil, success: nil, duration: 2.0, position: MyToastPosition.bottom)
                } else { // 绑定失败
                    MyToast.my_show(msg: "设备绑定失败", onView: nil, success: nil, duration: 2.0, position: MyToastPosition.bottom)
                }
            }
        }
    }
    
    // 查询单个设备
    func querySingleDevice(token: String, trackerNumber: String) {
        let timestamp = Utils.getNowTimeStamp()
        let params = "token=\(token)&timestamp=\(timestamp)&trackerNumber=\(trackerNumber)"
        let sign = DataEncoding.Encode_AES_ECB(strToEncode: params)
        let urlString = "\(kDeviceInfoUrl)token=\(token)&timestamp=\(timestamp)&trackerNumber=\(trackerNumber)&sign=\(sign)"
        print(urlString)
        let url = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        NetworkTools.shared.request(method: .POST, urlString: url!, parameters: nil) { (responseObject, error) in
            if error != nil {
                print(error!)
                return
            }
            
            if responseObject != nil {
                self.popover.dismiss()
                print(JSON(responseObject as Any))
                let updateDevice = SingleDeviceRespone(jsonData: JSON(responseObject as Any))
                self.devices[self.selected] = updateDevice.device!
                if let selectedIndexPath = self.selectedIndexPath {
                    self.collectionView?.reloadItems(at: [selectedIndexPath])
                }
            }
        }
    }
    
    // 查询所有绑定设备信息
    func queryAllDevice(token: String) {
        let timestamp = Utils.getNowTimeStamp()
        let params = "token=\(token)&timestamp=\(timestamp)"
        let sign = DataEncoding.Encode_AES_ECB(strToEncode: params)
        let urlString = "\(kDeviceListUrl)token=\(token)&timestamp=\(timestamp)&sign=\(sign)"
        let url = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        NetworkTools.shared.request(method: .POST, urlString: url!, parameters: nil) { (responseObject, error) in
            if error != nil {
                print(error!)
                return
            }
                
            if responseObject != nil {
                print(JSON(responseObject as Any))
            }
            let responseDevices = DeviceResponse(jsonData: JSON(responseObject as Any))
            print(responseDevices.devices.count)
            self.devices = responseDevices.devices
            self.collectionView?.reloadData()
        }
    }
    
    // 查询服务器广告列表
    func queryAdInfo() {
        NetworkTools.shared.request(method: .GET, urlString: kOperatorUrl, parameters: nil) { (responseObject, error) in
            if error != nil {
                print(error!)
                return
            }
                
            if responseObject != nil {
                let response = AdResponseModel(jsonData: JSON(responseObject as Any))
                for ad in response.adimages {
                    let imgUrl = "\(kImageDownloadUrl)\(ad.imageFileName!)"
                    print(imgUrl)
                    self.imgArr.append(imgUrl)
                }
                // 广告视图
                self.adView = AdScrollView.init(frame: CGRect(x: 0, y: kStatusHeight + kNavigationBarHeight + AdaptH(400), width: kScreenW, height: AdaptH(130)), pictrues: self.imgArr)
                self.adView?.direction = .left
                self.adView?.pageControlStyle = .center
                self.adView?.placeholderImage = UIImage(named: "banner")
                self.adView?.didTapAtIndexHandler = { index in
                    print("点击了第\(index + 1) 张图片")
                }
                self.view.addSubview(self.adView!)
            }
        }
    }
    
}

extension NewHomeViewController: AMapLocationManagerDelegate {
    
    func Login() {
        let users = CoreDataManager.shared.getAllUser()
        if users.count > 0 {
            self.isFirstLogin = false
            for user in users {
                token = user.token!
            }
            print("isFirstLogin: false")
        } else {
            loginForUser()
            self.isFirstLogin = false
            print("isFirstLogin: true")
        }
        print("token: \(self.token)")
        if !isFirstLogin { queryAllDevice(token: token) }
    }
    
    // 单次定位, userLoaction
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
                    // 定位错误: 此时location和regeocode没有返回值,不进行annotation的添加
                    return
                }
                else if error.code == AMapLocationErrorCode.reGeocodeFailed.rawValue
                    || error.code == AMapLocationErrorCode.timeOut.rawValue
                    || error.code == AMapLocationErrorCode.cannotFindHost.rawValue
                    || error.code == AMapLocationErrorCode.badURL.rawValue
                    || error.code == AMapLocationErrorCode.notConnectedToInternet.rawValue
                    || error.code == AMapLocationErrorCode.cannotConnectToHost.rawValue {
                    // 逆地址错误: 在带逆地理的单次定位中, 逆地理过程可能发生错误, 此时location有返回值, regeocode无返回值, 进行annotaion的添加
                }
                else {
                    // 没有错误： location有返回值，regeocode是否有返回值取决于是否进行逆地理操作, 进行annotaion的添加
                }
            }
                
            if let location = location {
                print("location success")
                self?.userLocation.coordinate = location.coordinate
            }
            
        })
    }
    
}

extension NewHomeViewController: UnbindCallback {
    
    func unbindCallbackWith(device: DeviceInfoModel) {
        for (index, deviceModel) in devices.enumerated() {
            if deviceModel.trackerNumber! == device.trackerNumber! {
                devices.remove(at: index)
                collectionView?.reloadData()
            }
        }
    }
}
