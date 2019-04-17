//
//  ViewController.swift
//  Tracker
//
//  Created by StephenLouis on 2018/10/25.
//  Copyright © 2018 StephenLouis. All rights reserved.
//

import UIKit
import SnapKit
import SwiftyJSON
import MapKit

class ViewController: UIViewController {

    let r = MAUserLocationRepresentation()
    var mapView: MAMapView?
    var device: DeviceInfoModel?
    var token: String?
    var urgentSearch: UIButton?
    var update: UIButton?
    var settings: UIButton?
    var efence: UIButton?
    var warning: UIButton?
    
    var userLocation = MAPointAnnotation()
    var _locationAnnotationView: LocationAnnotationView!
    
    var annotationView: TrackerAnnotationView?
    
    var searchApi: AMapSearchAPI?
    
    var clickNumber = 0
    var delegate: UnbindCallback?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        initNavigationBar()
        
        mapView = MAMapView(frame: self.view.bounds)
        mapView?.delegate = self
        mapView?.isShowsIndoorMap = true // 开启室内地图
        mapView?.showsCompass = false // 显示指南针
        
        self.view.addSubview(mapView!)
        
        mapView?.showsUserLocation = true
        mapView?.userTrackingMode = .follow
        mapView?.customizeUserLocationAccuracyCircleRepresentation = true
    
        mapView?.setZoomLevel(11, animated: true)
        mapView?.scaleOrigin = CGPoint(x: 20, y: kScreenH - 50)
        
        if let latitude = device?.trackerLatitude, let longitude = device?.trackerLongitude {
            let pointAnnotation = MAPointAnnotation()
            pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            mapView?.addAnnotation(pointAnnotation)
            mapView?.centerCoordinate = pointAnnotation.coordinate
        }
        
        //地图缩放到显示中心点（tracker）和用户位置
        var annotations = Array<MAPointAnnotation>()
        annotations.append(userLocation)
        showsAnnotations(annotations, edgePadding: UIEdgeInsets(top: 40, left: 40, bottom: 40, right: 40), andMapView: mapView!)
        
        let mapViewClick = UITapGestureRecognizer(target: self, action: #selector(hiddenAllViews))
        mapViewClick.numberOfTouchesRequired = 1 // 触摸点1个
        mapViewClick.numberOfTapsRequired = 1 // 点击次数1
        mapView?.addGestureRecognizer(mapViewClick)
        
        searchApi = AMapSearchAPI()
        searchApi?.delegate = self
        
        if let latitude = device?.trackerLatitude, let longitude = device?.trackerLongitude {
            var geoSearch: AMapReGeocodeSearchRequest?
            geoSearch = AMapReGeocodeSearchRequest()
            geoSearch!.location = AMapGeoPoint.location(withLatitude: CGFloat(latitude), longitude: CGFloat(longitude))
            geoSearch!.requireExtension = true
            searchApi?.aMapReGoecodeSearch(geoSearch)
            
            var poiSearch: AMapPOIAroundSearchRequest?
            poiSearch = AMapPOIAroundSearchRequest()
            poiSearch!.location = AMapGeoPoint.location(withLatitude: CGFloat(latitude), longitude: CGFloat(longitude))
            poiSearch!.sortrule = 0
            poiSearch!.requireExtension = true
            searchApi?.aMapPOIAroundSearch(poiSearch)
        }
        
        initSubviews()
        
    }
    
    @objc func backToPrevious() {
        self.dismiss(animated: true, completion: nil)
        //self.navigationController!.popViewController(animated: true)
    }
    
    // 初始化透明导航栏
    func initNavigationBar() {
        
        self.navigationItem.title = device?.trackerName
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        /*let backBar = UIImageView(image: UIImage(named: "icon_back04"))
        self.view.addSubview(backBar)
        backBar.snp.makeConstraints{ (make) in
            make.top.equalTo(AdaptH(kStatusHeight+5))
            make.left.equalTo(AdaptW(20))
            make.width.equalTo(AdaptW(20))
            make.height.equalTo(AdaptH(kNavigationBarHeight - 10))
        }
        let backTap = UITapGestureRecognizer(target: self, action: #selector(backToPrevious))
        backTap.numberOfTapsRequired = 1
        backTap.numberOfTouchesRequired = 1
        backBar.addGestureRecognizer(backTap)
        */
        
    }
}

extension ViewController: MAMapViewDelegate {
    
    func mapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation!) -> MAAnnotationView! {
        if annotation.isKind(of: MAUserLocation.self) {
            let userLoactionStyleReuseIndetifier = "userLocationStyleReuseIndentifier"
            
            var annotationView: MAAnnotationView! = mapView?.dequeueReusableAnnotationView(withIdentifier: userLoactionStyleReuseIndetifier)
            
            if annotationView == nil {
                annotationView = LocationAnnotationView(annotation: annotation, reuseIdentifier: userLoactionStyleReuseIndetifier)
                annotationView.canShowCallout = true
            }
            
            _locationAnnotationView = (annotationView as! LocationAnnotationView)
            _locationAnnotationView.updateImage(image: UIImage(named: "direction"))
            
            return annotationView
        }
        
        if annotation.isKind(of: MAPointAnnotation.self) {
            let pointReuseIndetifier = "pointReuseIndetifier"
            annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: pointReuseIndetifier) as? TrackerAnnotationView
            
            if annotationView == nil {
                annotationView = TrackerAnnotationView(annotation: annotation, reuseIdentifier: pointReuseIndetifier)
            }
            annotationView!.canShowCallout = false
            annotationView!.image = UIImage(named: "sign")
            annotationView!.setSelected(true, animated: true)
            annotationView!.delegate = self
            // 设置中心点偏移，似的标注b底部中间点成为经纬度对应点
            annotationView!.centerOffset = CGPoint(x: 0, y: -40)
            return annotationView
        }
        
        return nil
    }
    
    // 计算地图缩放比例，用以显示所有地图标识（带中心点和用户点）
    func showsAnnotations(_ annotations: Array<MAPointAnnotation>, edgePadding insets:UIEdgeInsets, andMapView mapView:MAMapView) {
        var rect: MAMapRect = MAMapRectZero
        
        for annotation in annotations {
            // 相对于中心点的对角线点
            let diagonalPoint = CLLocationCoordinate2DMake(mapView.centerCoordinate.latitude - (annotation.coordinate.latitude - mapView.centerCoordinate.latitude), mapView.centerCoordinate.longitude - (annotation.coordinate.longitude - mapView.centerCoordinate.longitude))
            
            let annotaionMapPoint = MAMapPointForCoordinate(annotation.coordinate)
            let diagonalPointMapPoint = MAMapPointForCoordinate(diagonalPoint)
            
            let annotationRect = MAMapRectMake(min(annotaionMapPoint.x, diagonalPointMapPoint.x), min(annotaionMapPoint.y, diagonalPointMapPoint.y), abs(annotaionMapPoint.x - diagonalPointMapPoint.x), abs(annotaionMapPoint.y - diagonalPointMapPoint.y))
            
            //rect = MAMapRectUnion(rect, annotationRect)
            rect = annotationRect
        }
        
        mapView.setVisibleMapRect(rect, edgePadding: insets, animated: false)
    }
    
    func mapView(_ mapView: MAMapView!, didUpdate userLocation: MAUserLocation!, updatingLocation: Bool) {
        if !updatingLocation && _locationAnnotationView != nil {
            UIView.animate(withDuration: 0.1, animations: {
                self._locationAnnotationView.rotateDegree = CGFloat(userLocation.heading.trueHeading) - mapView!.rotationDegree
            })
        }
    }
    
    func mapView(_ mapView: MAMapView!, rendererFor overlay: MAOverlay!) -> MAOverlayRenderer! {
        // 自定义定位进度对应的MACircleView
    
        return nil
    }
}

extension ViewController {
    
    func initSubviews() {
        
        let backBar = UIButton()
        backBar.setImage(UIImage(named: "icon_back04"), for: .normal)
        backBar.addTarget(self, action: #selector(backToPrevious), for: .touchUpInside)
        self.view.addSubview(backBar)
        backBar.snp.makeConstraints{ (make) in
            make.top.equalTo(AdaptH(kStatusHeight))
            make.left.equalTo(AdaptW(20))
        }
        
        let deviceName = UILabel()
        deviceName.text = device?.trackerName
        deviceName.font = UIFont.boldSystemFont(ofSize: 20)
        deviceName.textColor = UIColor.black
        self.view.addSubview(deviceName)
        deviceName.snp.makeConstraints{ (make) in
            make.top.equalTo(AdaptH(kStatusHeight))
            make.left.equalTo(AdaptW(50))
        }
        
        urgentSearch = UIButton()
        urgentSearch?.set(image: UIImage(named: "urgent"), title: "紧急寻宠", titlePosition: .right, additionalSpacing: 10.0, state: .normal)
        urgentSearch?.set(image: UIImage(named: "exit"), title: "退出紧急寻宠", titlePosition: .right, additionalSpacing: 10.0, state: .selected)
        urgentSearch?.setImage(UIImage(named: "exit"), for: .selected)
        urgentSearch?.layer.cornerRadius = 20
        urgentSearch?.setTitleColor(UIColor.white, for: .normal)
        urgentSearch?.setTitleColor(UIColor.orange, for: .highlighted)
        urgentSearch?.imageView?.contentMode = .scaleAspectFit
        urgentSearch?.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        urgentSearch?.backgroundColor = UIColor.orange
        urgentSearch?.isSelected = false
        urgentSearch?.addTarget(self, action: #selector(urgentFinds), for: .touchUpInside)
        self.view.addSubview(urgentSearch!)
        urgentSearch?.snp.makeConstraints{ (make) in
            make.centerX.equalTo(kScreenW / 2)
            make.centerY.equalTo(AdaptH(625))
            make.width.equalTo(AdaptW(160))
            make.height.equalTo(AdaptH(40))
        }
        
        warning = UIButton()
        warning?.set(image: UIImage(named: "urgent"), title: "当前处于紧急寻宠模式，将实时更新位置信息", titlePosition: .right, additionalSpacing: 10.0, state: .normal)
        warning?.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        warning?.backgroundColor = UIColor.init(red: 255.0, green: 0, blue: 0, alpha: 0.5)
        warning?.isHidden = true
        self.view.addSubview(warning!)
        warning?.snp.makeConstraints{ (make) in
            make.left.equalToSuperview()
            make.top.equalTo(kNavigationBarHeight+kStatusHeight)
            make.width.equalToSuperview()
            make.height.equalTo(AdaptH(20))
        }
        
        update = UIButton()
        update?.setImage(UIImage(named: "refresh"), for: .normal)
        update?.imageView?.contentMode = .scaleAspectFit
        update?.layer.cornerRadius = 20
        self.view.addSubview(update!)
        update?.addTarget(self, action: #selector(updateDevice(_:)), for: .touchUpInside)
        update?.snp.makeConstraints{ (make) in
            make.centerX.equalTo(kScreenW).offset(Adapt(335))
            make.centerY.equalTo(AdaptH(625))
            make.width.equalTo(AdaptW(45))
            make.height.equalTo(AdaptH(40))
        }
        
        settings = UIButton()
        settings?.set(image: UIImage(named: "setting"), title: "设置", titlePosition: .bottom, additionalSpacing: 20.0, state: .normal)
        settings?.setTitleColor(UIColor.black, for: .normal)
        settings?.setTitleColor(UIColor.gray, for: .highlighted)
        settings?.titleLabel?.font = UIFont.systemFont(ofSize: 10)
        settings?.layer.cornerRadius = 10
        settings?.backgroundColor = UIColor.white
        self.view.addSubview(settings!)
        settings?.snp.makeConstraints { (make) in
            make.centerX.equalTo(kScreenW).offset(Adapt(335))
            make.centerY.equalTo(AdaptH(110))
            make.width.equalTo(AdaptW(45))
            make.height.equalTo(AdaptH(40))
        }
        settings?.addTarget(self, action: #selector(selectLocationMethod(_:)), for: .touchUpInside)
        
        efence = UIButton()
        efence?.set(image: UIImage(named: "rail"), title: "围栏", titlePosition: .bottom, additionalSpacing: 20.0, state: .normal)
        efence?.setTitle("电子围栏", for: .normal)
        efence?.setTitleColor(UIColor.black, for: .normal)
        efence?.setTitleColor(UIColor.gray, for: .highlighted)
        efence?.titleLabel?.font = UIFont.systemFont(ofSize: 10)
        efence?.layer.cornerRadius = 10
        efence?.backgroundColor = UIColor.white
        efence?.addTarget(self, action: #selector(selectEnfence(_:)), for: .touchUpInside)
        self.view.addSubview(efence!)
        efence?.snp.makeConstraints { (make) in
            make.centerX.equalTo(kScreenW).offset(Adapt(335))
            make.centerY.equalTo(AdaptH(165))
            make.width.equalTo(AdaptW(45))
            make.height.equalTo(AdaptH(40))
        }
        
    }
    
    @objc func selectLocationMethod(_ sender: UIButton) {
        let currentButtonTitle: String = sender.currentTitle!
        if currentButtonTitle == "智能功耗" {
            let powerAlert = SmartPowerAlertView()
            powerAlert.whiteViewEndFrame = CGRect.init(x: 40, y: 200, width: kScreenW - 80, height: kScreenH - 500)
            powerAlert.addAnimate()
        } else if currentButtonTitle == "设置" {
            print("跳转设备设置")
            let unbindController = UnbindViewController()
            unbindController.token = self.token
            unbindController.trackerNumber = self.device?.trackerNumber
            unbindController.unbindCallback = self
            self.present(unbindController, animated: true, completion: nil)
        }
    }
    
    @objc func selectEnfence(_ sender: UIButton) {
        let currentButtonTitle: String = sender.currentTitle!
        if currentButtonTitle == "电子围栏" {
            let fenceViewController = FenceViewController()
            fenceViewController.centerDot = CLLocationCoordinate2D(latitude: (device?.trackerLatitude)!, longitude: (device?.trackerLongitude)!)
            self.present(fenceViewController, animated: true, completion: nil)
        }
    }
    
    // 更新设备状态
    @objc func updateDevice(_ sender: UIButton) {
        let imageView = sender.imageView
        let rotationAnimation = CABasicAnimation()
        rotationAnimation.keyPath = "transform.rotation.z"
        rotationAnimation.toValue = Double.pi * 2.0
        rotationAnimation.duration = 0.5
        rotationAnimation.isCumulative = true
        rotationAnimation.repeatCount = 2
        if imageView != nil {
            imageView!.layer.add(rotationAnimation, forKey: "rotationAnimation")
        }
        
        if token != nil && device != nil && device?.trackerNumber != nil {
            querySingleDevice(token: self.token!, trackerNumber: (device?.trackerNumber)!)
        }
    }
    
    @objc func hiddenAllViews() {
        print("单击")
        clickNumber = clickNumber + 1
        var isHidden = false
        if clickNumber % 2 == 1 {
            isHidden = true
        } else {
            isHidden = false
        }
        urgentSearch?.isHidden = isHidden
        settings?.isHidden = isHidden
        efence?.isHidden = isHidden
        annotationView?.setSelected(!isHidden, animated: true)
    }
    
    @objc func urgentFinds() {
        let isSelected = urgentSearch?.isSelected
        urgentSearch?.isSelected = !isSelected!
        if (urgentSearch?.isSelected)! {
            settings?.setTitle("智能功耗", for: .normal)
            settings?.setImage(UIImage(named: "positioning"), for: .normal)
            efence?.setTitle("发声寻宠", for: .normal)
            warning?.isHidden = false
        } else {
            settings?.setTitle("设置", for: .normal)
            settings?.setImage(UIImage(named: "setting"), for: .normal)
            efence?.setTitle("电子围栏", for: .normal)
            warning?.isHidden = true
        }
    }
}

// 网络请求模块
extension ViewController {
    
    // 查询单个设备信息
    func querySingleDevice(token: String, trackerNumber: String) {
        let timestamp = Utils.getNowTimeStamp()
        let params = "token=\(token)&timestamp=\(timestamp)&trackerNumber=\(trackerNumber)"
        let sign = DataEncoding.Encode_AES_ECB(strToEncode: params)
        let urlString = "\(kDeviceInfoUrl)token=\(token)&timestamp=\(timestamp)&trackerNumber=\(trackerNumber)&sign=\(sign)"
        let url = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        NetworkTools.shared.request(method: .POST, urlString: url!, parameters: nil) { (responseObject, error) in
            if error != nil {
                print(error!)
                return
            }
            
            if responseObject != nil {
                print(JSON(responseObject as Any))
                let newDevice = SingleDeviceRespone(jsonData: JSON(responseObject as Any))
                if let newLatitude = newDevice.device?.trackerLatitude,
                    let newLongitude = newDevice.device?.trackerLongitude,
                    let newUpdateTime = newDevice.device?.trackerLastUpdate,
                    let latitude = self.device?.trackerLatitude,
                    let longitude = self.device?.trackerLongitude,
                    let updateTime = self.device?.trackerLastUpdate {
                    
                    // 判断位置是否发生变化
                    if newLatitude != latitude || newLongitude != longitude {
                        let pointAnnotation = MAPointAnnotation()
                        pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: newLatitude, longitude: newLongitude)
                        self.mapView?.removeAnnotations(self.mapView?.annotations)
                        self.mapView?.addAnnotation(pointAnnotation)
                        self.mapView?.centerCoordinate = pointAnnotation.coordinate
                        self.device?.trackerLongitude = newLongitude
                        self.device?.trackerLatitude = newLatitude
                    }
                    
                    // 判断设备更新时间是否发生变化
                    if newUpdateTime != updateTime {
                        self.device?.trackerLastUpdate = newUpdateTime
                    }
                }
            }
        }
    }
    
}

// 位置搜索接口
extension ViewController: AMapSearchDelegate {
    
    func onReGeocodeSearchDone(_ request: AMapReGeocodeSearchRequest!, response: AMapReGeocodeSearchResponse!) {
        if response.regeocode != nil {
            //通过AMapReGeocodeSearchResponse对象处理搜索结果
            print(response.regeocode.formattedAddress!)
        }
    }
    
    func onPOISearchDone(_ request: AMapPOISearchBaseRequest!, response: AMapPOISearchResponse!) {
        if response.pois != nil {
            let updateTimeString = Utils.getFormatTime(dateInt: device!.trackerLastUpdate!, format: "MM-dd HH:mm")
            if response.pois.count > 0 {
                annotationView?.setValue(address: response.pois[0].name, updateTime: updateTimeString)
            }
        }
    }
    
}

extension ViewController: TrackerAnnotationDelegate {
    func clickNavButton(latitude: Double, Longitude: Double) {
        createOptionMenu(latitude: latitude, longitude: Longitude)
    }
    
    func createOptionMenu(latitude: Double, longitude: Double) {
        let alertController = UIAlertController(title: "选择导航地图", message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction.init(title: "取消", style: .cancel) { (action) in
            
        }
        
        // 系统自带地图,内核高德地图,无需判断是否安装
        let appleAction = UIAlertAction(title: "自带地图", style: .default) { (action) in
            let currentLocation = MKMapItem.forCurrentLocation()
            let toLoaction = MKMapItem.init(placemark: MKPlacemark.init(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude)))
            MKMapItem.openMaps(with: [currentLocation, toLoaction], launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving,
                                                                                    MKLaunchOptionsShowsTrafficKey:true])
        }
        
        // 百度地图
        if UIApplication.shared.canOpenURL(URL.init(string: "baidumap://")!) {
            let baiduAction = UIAlertAction(title: "百度地图", style: .default) { (action) in
                let toLoaction = Utils.gaodeToBdWith(lat: latitude, lon: longitude)
                let urlString = "baidumap://map/direction?origin={{我的位置}}&destination=latlng:\(toLoaction.latitude),\(toLoaction.longitude)|name=目的地&mode=driving&coord_type=gcj02"
                let escapedString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                UIApplication.shared.open(URL.init(string: escapedString!)!, options: [:], completionHandler: { (success) in
                    
                })
            }
            alertController.addAction(baiduAction)
        }
        
        // 高德地图
        if UIApplication.shared.canOpenURL(URL.init(string: "iosamap://")!) {
            let gaodeAction = UIAlertAction(title: "高德地图", style: .default) { (action) in
                let urlString = "iosamap://navi?sourceApplicatoin=随便写&backScheme=随便写&lat=\(latitude)&lon=\(longitude)&dev=0&style=2"
                let escapedString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                UIApplication.shared.open(URL.init(string: escapedString!)!, options: [:], completionHandler: { (success) in
                    
                })
            }
            alertController.addAction(gaodeAction)
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(appleAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
}

extension ViewController: UnbindDeviceCallback {
    
    // 解绑回调
    func unbindDeviceCallback() {
        print("unbind callback")
        delegate?.unbindCallbackWith(device: device!)
        //self.dismiss(animated: true, completion: nil)
    }
}

protocol UnbindCallback {
    func unbindCallbackWith(device: DeviceInfoModel)
}
