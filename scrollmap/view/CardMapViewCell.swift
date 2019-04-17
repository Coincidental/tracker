//
//  CardMapViewCell.swift
//  Tracker
//
//  Created by StephenLouis on 2018/11/16.
//  Copyright © 2018 StephenLouis. All rights reserved.
//

import UIKit

class CardMapViewCell: UICollectionViewCell {
    var mapView: MAMapView?
    var timeBackground: GradientBG?
    var lastUpdateTime: UILabel?
    var updateIcon: UIImageView?
    var deviceName: UILabel?
    var bannerBackground: GradientBG?
    var batteryView: TrackerBatteryView?
    var batteryLevelLabel: UILabel?
    var updateBackground: UIView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 16
        
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        // 地图视图MapView
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
            make.left.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalToSuperview()
        }
        
        // 最后更新时间背景
        timeBackground = GradientBG(frame: CGRect(), direction: 0)
        timeBackground?.layer.masksToBounds = true
        timeBackground?.layer.cornerRadius = 10
        self.contentView.addSubview(timeBackground!)
        self.timeBackground?.snp.makeConstraints{ (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.width.equalTo(AdaptW(160))
            make.height.equalTo(AdaptH(30))
        }
        
        // 最后刷新时间
        lastUpdateTime = UILabel()
        lastUpdateTime?.font = UIFont.systemFont(ofSize: 15)
        lastUpdateTime?.textColor = UIColor.black
        self.timeBackground?.addSubview(lastUpdateTime!)
        self.lastUpdateTime?.snp.makeConstraints{ (make) in
            make.top.width.height.equalToSuperview()
            make.left.equalTo(Adapt(10))
        }
        
        // 刷新图标背景全透明
        updateBackground = UIView()
        updateBackground?.backgroundColor = UIColor.clear
        self.contentView.addSubview(updateBackground!)
        self.updateBackground?.snp.makeConstraints{ (make) in
            make.top.equalToSuperview().offset(AdaptH(10))
            make.right.equalToSuperview().offset(AdaptW(-10))
            make.width.equalTo(AdaptW(35))
            make.height.equalTo(AdaptH(30))
        }
        
        // 刷新图标
        updateIcon = UIImageView(image: UIImage(named: "refresh"))
        self.updateBackground?.addSubview(updateIcon!)
        self.updateIcon?.snp.makeConstraints{ (make) in
            make.top.left.width.height.equalToSuperview()
        }
        
        // 底部背景
        bannerBackground = GradientBG(frame: CGRect(), direction: 1)
        self.contentView.addSubview(bannerBackground!)
        bannerBackground?.snp.makeConstraints{ (make) in
            make.left.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(AdaptH(35))
        }
        
        deviceName = UILabel()
        deviceName?.text = "腿不短的柯基Happy"
        deviceName?.textColor = UIColor.black
        deviceName?.font = UIFont.boldSystemFont(ofSize: 18)
        self.bannerBackground?.addSubview(deviceName!)
        deviceName?.snp.makeConstraints{ (make) in
            make.left.equalToSuperview().offset(AdaptW(15))
            make.centerY.equalToSuperview()
        }
        
        batteryView = TrackerBatteryView(frame: CGRect(x: 0, y: 0, width: Adapt(40), height: Adapt(15)))
        self.bannerBackground?.addSubview(batteryView!)
        batteryView?.snp.makeConstraints{ (make) in
            make.right.equalTo(Adapt(-80))
            make.top.equalTo(Adapt(15))
        }
        
        batteryLevelLabel = UILabel()
        batteryLevelLabel?.text = ""
        batteryLevelLabel?.font = UIFont.systemFont(ofSize: 14)
        self.bannerBackground?.addSubview(batteryLevelLabel!)
        batteryLevelLabel?.snp.makeConstraints{ (make) in
            make.right.equalTo(Adapt(-10))
            make.top.equalTo(Adapt(15))
        }
    }
    
    func setStatus(status: Int, batteryLevel: Int) {
        if status == kBatteryCharging {
            batteryLevelLabel?.textColor = colorWithRGBA(0x84, 0xce, 0x80, 1.0)
        } else if status == kBatteryCharging {
            batteryLevelLabel?.textColor = colorWithRGBA(0x80, 0xa5, 0xce, 1.0)
        } else if batteryLevel < 20 {
            batteryLevelLabel?.textColor = colorWithRGBA(0xce, 0x80, 0x80, 1.0)
        } else {
            batteryLevelLabel?.textColor = colorWithRGBA(0x84, 0xce, 0x80, 1.0)
        }
    }
    
}

extension CardMapViewCell: MAMapViewDelegate {
    
    func mapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation!) -> MAAnnotationView! {
        
        if annotation.isKind(of: MAPointAnnotation.self) {
            let pointReuseIndetifier = "pointReuseIndetifier"
            var annotationView: MAAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: pointReuseIndetifier)
            
            if annotationView == nil {
                annotationView = MAAnnotationView(annotation: annotation, reuseIdentifier: pointReuseIndetifier)
            }
            
            annotationView!.image = UIImage(named: "normal")
            // 设置中心点偏移，标注的底部中间点为经纬度对应点
            annotationView!.centerOffset = CGPoint(x: 0, y: -20)
            return annotationView!
        }
        
        return nil
    }
    
}

