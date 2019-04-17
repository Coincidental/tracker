//
//  MapTableViewCell.swift
//  Tracker
//
//  Created by StephenLouis on 2018/10/25.
//  Copyright © 2018 StephenLouis. All rights reserved.
//

import UIKit

class MapTableViewCell: UITableViewCell,MAMapViewDelegate,AMapLocationManagerDelegate {
    
    var mapView: MAMapView?
    var lastUpdateTime: UILabel?
    var updateIcon: UIImageView?
    var deviceName: UILabel?
    var details: UIImageView?
    var detailDescription: UILabel?
    
    var locationManager: AMapLocationManager?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = UITableViewCell.SelectionStyle.none
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager = AMapLocationManager.init()
            
            locationManager?.delegate = self
            locationManager?.allowsBackgroundLocationUpdates = true
            locationManager?.pausesLocationUpdatesAutomatically = false
            locationManager?.distanceFilter = 20
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
            
            locationManager?.startUpdatingLocation()
        }
        
        self.createCellUI()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func createCellUI() {
        
        // 地图
        mapView = MAMapView()
        mapView?.delegate = self
        self.contentView.addSubview(mapView!)
        //mapView?.showsUserLocation = true
        mapView?.showsCompass = false
        //self.mapView?.userTrackingMode = .follow
        self.mapView?.isZoomEnabled = false
        self.mapView?.setZoomLevel(15, animated: true)
        self.mapView?.isScrollEnabled = false
        self.mapView?.isRotateEnabled = false
        self.mapView?.isRotateCameraEnabled = false
        self.mapView?.showsScale = false
        self.mapView?.snp.makeConstraints{ (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(Adapt(5))
            make.width.equalTo(AdaptW(365))
            make.height.equalTo(AdaptH(140))
        }
        
        // 最后更新时间
        lastUpdateTime = UILabel()
        lastUpdateTime?.backgroundColor = UIColor.gray
        lastUpdateTime?.text = "最后更新时间: 10-25 18:00"
        lastUpdateTime?.font = UIFont.systemFont(ofSize: 15)
        self.contentView.addSubview(lastUpdateTime!)
        self.lastUpdateTime?.snp.makeConstraints{ (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(Adapt(5))
            make.width.equalTo(AdaptW(180))
            make.height.equalTo(AdaptH(30))
        }
        
        // 刷新图标
        updateIcon = UIImageView()
        self.contentView.addSubview(updateIcon!)
        updateIcon?.image = UIImage(named: "card_refresh")
        self.updateIcon?.snp.makeConstraints{ (make) in
            make.top.equalToSuperview().offset(AdaptH(5))
            make.right.equalToSuperview().offset(AdaptW(-5))
            make.width.equalTo(AdaptW(35))
            make.height.equalTo(AdaptH(30))
        }
        
        // 设备名
        deviceName = UILabel()
        deviceName?.text = "设备名xxx"
        deviceName?.font = UIFont.systemFont(ofSize: 17)
        self.contentView.addSubview(deviceName!)
        self.deviceName?.snp.makeConstraints{ (make) in
            make.top.equalTo(AdaptH(140))
            make.left.equalToSuperview().offset(Adapt(5))
            make.width.equalTo(AdaptW(100))
            make.height.equalTo(AdaptH(20))
        }
        
        // 电量或在线状态图标
        details = UIImageView()
        self.contentView.addSubview(details!)
        details?.image = UIImage(named: "home_cateHeader_hot")
        self.details?.snp.makeConstraints{ (make) in
            make.top.equalTo(AdaptH(145))
            make.right.equalToSuperview().offset(AdaptW(-50))
            make.width.equalTo(AdaptW(35))
            make.height.equalTo(AdaptH(12))
        }
        
        // 电量或在线状态
        detailDescription = UILabel()
        detailDescription?.text = "87%"
        detailDescription?.font = UIFont.systemFont(ofSize: 17)
        self.contentView.addSubview(detailDescription!)
        self.detailDescription?.snp.makeConstraints{ (make) in
            make.top.equalTo(AdaptH(143))
            make.right.equalToSuperview().offset(AdaptW(-10))
            make.width.equalTo(AdaptW(35))
            make.height.equalTo(AdaptH(15))
        }
    }
    
    func setValueForCell(device: DeviceInfoModel) {
        // 设置定位器定位信息
        let pointAnnotation = MAPointAnnotation()
        if let latitude = device.trackerLatitude, let longitude = device.trackerLongitude {
            pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            self.mapView?.centerCoordinate = pointAnnotation.coordinate
            self.mapView?.addAnnotation(pointAnnotation)
        }
        
        // 设置最后更新时间
        let dformatter = DateFormatter()
        dformatter.dateFormat = "最后更新: MM-dd hh:mm"
        let date = Date(timeIntervalSince1970: TimeInterval(exactly: device.trackerLastUpdate!)!)
        self.lastUpdateTime?.text = dformatter.string(from: date)
        
        // 设置设备名
        self.deviceName?.text = device.trackerName
        
        // 设置设备电量
        self.detailDescription?.text = "\(device.trackerBattery!)%"
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}

extension MapTableViewCell {
    
    func mapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation!) -> MAAnnotationView! {
        if annotation.isKind(of: MAPointAnnotation.self) {
            let pointReuseIndetifier = "pointReuseIndetifier"
            var annotationView: MAAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: pointReuseIndetifier)
            
            if annotationView == nil {
                annotationView = MAAnnotationView(annotation: annotation, reuseIdentifier: pointReuseIndetifier)
            }
            
            annotationView!.image = UIImage(named: "wateRedBlank")
            // 设置中心点偏移，似的标注b底部中间点成为经纬度对应点
            annotationView!.centerOffset = CGPoint(x: 0, y: -16)
            return annotationView!
        }
        
        return nil
    }
    
}
