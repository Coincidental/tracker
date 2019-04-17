//
//  FenceViewController.swift
//  Tracker
//
//  Created by StephenLouis on 2018/11/28.
//  Copyright © 2018 StephenLouis. All rights reserved.
//

import UIKit

class FenceViewController: UIViewController, AMapGeoFenceManagerDelegate, MAMapViewDelegate {
    
    var mapView: MAMapView?
    var fence_num: Int = 0
    // 多边形地理围栏
    var geoFencePolygonRegion: AMapGeoFencePolygonRegion?
    var isDraw: Bool = false
    var lastX: CGFloat = 0
    var lastY: CGFloat = 0
    var centerDot: CLLocationCoordinate2D?
    var count: Int = 0
    var coordinates: [CLLocationCoordinate2D] = [CLLocationCoordinate2D]()
    var geoFenceManager: AMapGeoFenceManager?
    var polyLines: [MAPolyline] = [MAPolyline]()
    var gesture: UIPanGestureRecognizer?
    
    var exitButton: UIButton?
    var titleLable: UILabel?
    var fence1: UIButton?
    var fence2: UIButton?
    var fence3: UIButton?
    var fence4: UIButton?
    
    var deleteButton: UIButton?
    var reDrawButton: UIButton?
    var confirmButton: UIButton?
    
    var fences: [FenceModel] = [FenceModel]()
    var selected_fence = 0
    var newFence: FenceModel?
    var polygonOverlay: MAPolygon?
    var polygons: [MAPolygon] = [MAPolygon]()
    var drawComplete: Bool = false
    var fenceSelected: Bool = false
    var last_selected_fence = 0
    var fenceUnSelected: Bool = false
    
    var popview = PopoverView()
    
    override func viewDidLoad() {
        initMapView()
        initSubviews()
        updateFenceButton()
    }

    // 初始化mapView
    func initMapView() {
        mapView = MAMapView(frame: self.view.bounds)
        self.view.addSubview(mapView!)
        mapView?.delegate = self
        mapView?.showsCompass = false
        
        mapView?.setZoomLevel(14.0, animated: true)
        if centerDot != nil {
            mapView?.centerCoordinate = centerDot!
        }
        
        gesture = UIPanGestureRecognizer(target: self, action: #selector(gestureMove(_:)))
        
        geoFenceManager = AMapGeoFenceManager()
        geoFenceManager?.delegate = self
        geoFenceManager?.activeAction = [AMapGeoFenceActiveAction.inside, AMapGeoFenceActiveAction.outside, AMapGeoFenceActiveAction.stayed]
        geoFenceManager?.allowsBackgroundLocationUpdates = true
    }
    
    // 初始化控件
    func initSubviews() {
        exitButton = UIButton()
        exitButton?.setImage(UIImage(named: "shut"), for: .normal)
        self.view.addSubview(exitButton!)
        exitButton?.snp.makeConstraints{ (make) in
            make.left.equalTo(AdaptW(20))
            make.top.equalTo(kStatusHeight + Adapt(5))
        }
        exitButton?.addTarget(self, action: #selector(exit), for: .touchUpInside)
        
        titleLable = UILabel()
        titleLable?.text = "围栏设定"
        titleLable?.font = UIFont.boldSystemFont(ofSize: 18)
        self.view.addSubview(titleLable!)
        titleLable?.snp.makeConstraints{ (make) in
            make.left.equalTo(AdaptW(45))
            make.top.equalTo(kStatusHeight + Adapt(6))
        }
        
        fence1 = UIButton()
        fence1?.setTitle("围栏一", for: .normal)
        fence1?.setTitleColor(UIColor.black, for: .normal)
        fence1?.backgroundColor = UIColor.white
        self.view.addSubview(fence1!)
        fence1?.snp.makeConstraints{ (make) in
            make.left.equalTo(AdaptW(45))
            make.top.equalTo(kStatusHeight + kNavigationBarHeight)
            make.width.equalTo(Adapt(60))
        }
        fence1?.addTarget(self, action: #selector(addNewFence(_:)), for: .touchUpInside)
        
        fence2 = UIButton()
        fence2?.setTitle("围栏二", for: .normal)
        fence2?.setTitleColor(UIColor.black, for: .normal)
        fence2?.backgroundColor = UIColor.white
        self.view.addSubview(fence2!)
        fence2?.snp.makeConstraints{ (make) in
            make.left.equalTo(AdaptW(110))
            make.top.equalTo(kStatusHeight + kNavigationBarHeight)
            make.width.equalTo(Adapt(60))
        }
        fence2?.addTarget(self, action: #selector(addNewFence(_:)), for: .touchUpInside)
        
        fence3 = UIButton()
        fence3?.setTitle("围栏三", for: .normal)
        fence3?.setTitleColor(UIColor.black, for: .normal)
        fence3?.backgroundColor = UIColor.white
        self.view.addSubview(fence3!)
        fence3?.snp.makeConstraints{ (make) in
            make.left.equalTo(AdaptW(175))
            make.top.equalTo(kStatusHeight + kNavigationBarHeight)
            make.width.equalTo(Adapt(60))
        }
        fence3?.addTarget(self, action: #selector(addNewFence(_:)), for: .touchUpInside)
        
        fence4 = UIButton()
        fence4?.setTitle("围栏四", for: .normal)
        fence4?.setTitleColor(UIColor.black, for: .normal)
        fence4?.backgroundColor = UIColor.white
        self.view.addSubview(fence4!)
        fence4?.snp.makeConstraints{ (make) in
            make.left.equalTo(AdaptW(240))
            make.top.equalTo(kStatusHeight + kNavigationBarHeight)
            make.width.equalTo(Adapt(60))
        }
        fence4?.addTarget(self, action: #selector(addNewFence(_:)), for: .touchUpInside)
        
        deleteButton = UIButton()
        deleteButton?.setImage(UIImage(named: "shut"), for: .normal)
        deleteButton?.backgroundColor = UIColor.clear
        deleteButton?.contentMode = .scaleAspectFit
        self.view.addSubview(deleteButton!)
        deleteButton?.snp.makeConstraints{ (make) in
            make.right.equalToSuperview().offset(AdaptW(-40))
            make.bottom.equalToSuperview().offset(AdaptH(-40))
            make.width.equalTo(AdaptW(40))
            make.height.equalTo(AdaptH(45))
        }
        deleteButton?.addTarget(self, action: #selector(deleteFence), for: .touchUpInside)
        
        reDrawButton = UIButton()
        reDrawButton?.setImage(UIImage(named: "refresh"), for: .normal)
        reDrawButton?.backgroundColor = UIColor.clear
        reDrawButton?.contentMode = .scaleAspectFit
        self.view.addSubview(reDrawButton!)
        reDrawButton?.snp.makeConstraints{ (make) in
            make.right.equalToSuperview().offset(AdaptW(-40))
            make.bottom.equalToSuperview().offset(AdaptH(-40))
            make.width.equalTo(AdaptW(45))
            make.height.equalTo(AdaptH(40))
        }
        reDrawButton?.addTarget(self, action: #selector(reDrawFence), for: .touchUpInside)
        
        confirmButton = UIButton()
        confirmButton?.setImage(UIImage(named: "checkBox_on"), for: .normal)
        confirmButton?.backgroundColor = UIColor.clear
        confirmButton?.contentMode = .scaleToFill
        self.view.addSubview(confirmButton!)
        confirmButton?.snp.makeConstraints{ (make) in
            make.right.equalToSuperview().offset(AdaptW(-100))
            make.bottom.equalToSuperview().offset(AdaptH(-40))
            make.width.equalTo(AdaptW(45))
            make.height.equalTo(AdaptH(40))
        }
        confirmButton?.addTarget(self, action: #selector(addOneFence), for: .touchUpInside)
    }
    
    func updateFenceButton() {
        fence1?.isHidden = true
        fence2?.isHidden = true
        fence3?.isHidden = true
        fence4?.isHidden = true
        fence1?.setTitleColor(UIColor.black, for: .normal)
        fence1?.backgroundColor = UIColor.white
        fence2?.setTitleColor(UIColor.black, for: .normal)
        fence2?.backgroundColor = UIColor.white
        fence3?.setTitleColor(UIColor.black, for: .normal)
        fence3?.backgroundColor = UIColor.white
        fence4?.setTitleColor(UIColor.black, for: .normal)
        fence4?.backgroundColor = UIColor.white
        deleteButton?.isHidden = true
        reDrawButton?.isHidden = true
        confirmButton?.isHidden = true

        switch fences.count {
        case 0:
            fence1?.isHidden = false
            fence1?.setTitle("新增", for: .normal)
            break
        case 1:
            fence1?.isHidden = false
            fence2?.isHidden = false
            fence1?.setTitle("围栏一", for: .normal)
            fence2?.setTitle("新增", for: .normal)
            break
        case 2:
            fence1?.isHidden = false
            fence2?.isHidden = false
            fence3?.isHidden = false
            fence1?.setTitle("围栏一", for: .normal)
            fence2?.setTitle("围栏二", for: .normal)
            fence3?.setTitle("新增", for: .normal)
            break
        case 3:
            fence1?.isHidden = false
            fence2?.isHidden = false
            fence3?.isHidden = false
            fence4?.isHidden = false
            fence1?.setTitle("围栏一", for: .normal)
            fence2?.setTitle("围栏二", for: .normal)
            fence3?.setTitle("围栏三", for: .normal)
            fence4?.setTitle("新增", for: .normal)
            break
        case 4:
            fence1?.isHidden = false
            fence2?.isHidden = false
            fence3?.isHidden = false
            fence4?.isHidden = false
            fence1?.setTitle("围栏一", for: .normal)
            fence2?.setTitle("围栏二", for: .normal)
            fence3?.setTitle("围栏三", for: .normal)
            fence4?.setTitle("围栏四", for: .normal)
        default:
            break
        }
        
        switch selected_fence {
        case 1:
            fence1?.setTitleColor(UIColor.white, for: .normal)
            fence1?.backgroundColor = UIColor.black
            fence2?.setTitleColor(UIColor.black, for: .normal)
            fence2?.backgroundColor = UIColor.white
            fence3?.setTitleColor(UIColor.black, for: .normal)
            fence3?.backgroundColor = UIColor.white
            fence4?.setTitleColor(UIColor.black, for: .normal)
            fence4?.backgroundColor = UIColor.white
            break
        case 2:
            fence1?.setTitleColor(UIColor.black, for: .normal)
            fence1?.backgroundColor = UIColor.white
            fence2?.setTitleColor(UIColor.white, for: .normal)
            fence2?.backgroundColor = UIColor.black
            fence3?.setTitleColor(UIColor.black, for: .normal)
            fence3?.backgroundColor = UIColor.white
            fence4?.setTitleColor(UIColor.black, for: .normal)
            fence4?.backgroundColor = UIColor.white
            break
        case 3:
            fence1?.setTitleColor(UIColor.black, for: .normal)
            fence1?.backgroundColor = UIColor.white
            fence2?.setTitleColor(UIColor.black, for: .normal)
            fence2?.backgroundColor = UIColor.white
            fence3?.setTitleColor(UIColor.white, for: .normal)
            fence3?.backgroundColor = UIColor.black
            fence4?.setTitleColor(UIColor.black, for: .normal)
            fence4?.backgroundColor = UIColor.white
            break
        case 4:
            fence1?.setTitleColor(UIColor.black, for: .normal)
            fence1?.backgroundColor = UIColor.white
            fence2?.setTitleColor(UIColor.black, for: .normal)
            fence2?.backgroundColor = UIColor.white
            fence3?.setTitleColor(UIColor.black, for: .normal)
            fence3?.backgroundColor = UIColor.white
            fence4?.setTitleColor(UIColor.white, for: .normal)
            fence4?.backgroundColor = UIColor.black
            break
        default:
            break
        }
        
        if selected_fence > 0 { deleteButton?.isHidden = false }
        
        if isDraw {
            fence1?.isHidden = true
            fence2?.isHidden = true
            fence3?.isHidden = true
            fence4?.isHidden = true
            deleteButton?.isHidden = true
            reDrawButton?.isHidden = false
            confirmButton?.isHidden = false
        }
    }
    
    // 退出围栏设定
    @objc func exit() {
        if isDraw {
            drawComplete = false
            setDrawFence(draw: false)
            updateFenceButton()
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    // 选中围栏
    @objc func onFenceSelected(index: Int) {
        last_selected_fence = selected_fence
        selected_fence = index
        if last_selected_fence == selected_fence { return } // 选择同一个围栏
        drawSelectedFence(withIndex: index - 1)
        updateFenceButton()
    }
    
    // 设置绘制状态
    func setDrawFence(draw: Bool) {
        isDraw = draw
        if isDraw {
            let zoomLevel = mapView!.zoomLevel
            if zoomLevel < CGFloat(10) {
                print("请放大地图后再新增围栏")
            } else {
                titleLable?.text = "请用手指圈画围栏区域"
                mapView?.isZoomEnabled = false
                mapView?.isScrollEnabled = false
                mapView?.isRotateEnabled = false
                mapView?.isRotateCameraEnabled = false
                mapView?.addGestureRecognizer(gesture!)
            }
        } else {
            titleLable?.text = "围栏设定"
            mapView?.isZoomEnabled = true
            mapView?.isScrollEnabled = true
            mapView?.isRotateEnabled = true
            mapView?.isRotateCameraEnabled = true
            mapView?.removeGestureRecognizer(gesture!)
            fence1?.isHidden = false
        }
    }
    
    // 手势
    @objc func gestureMove(_ sender: UIPanGestureRecognizer) {
        let point: CGPoint = sender.location(in: mapView)
        count = count + 1
        if isDraw && !drawComplete {
            if sender.state == .began {
                lastX = point.x
                lastY = point.y
                let coordinate = mapView?.convert(point, toCoordinateFrom: mapView!)
                if coordinate != nil {
                    coordinates.append(coordinate!)
                }
            } else if sender.state == .changed {
                addPolyLine(start: CGPoint(x: lastX, y: lastY), end: point)
                if abs(point.x - lastX) > 2.0 || abs(point.y - lastY) > 2 {
                    lastX = point.x
                    lastY = point.y
                    let coordinate = mapView?.convert(point, toCoordinateFrom: mapView!)
                    if coordinate != nil {
                        coordinates.append(coordinate!)
                    }
                    
                }
            } else if sender.state == .ended {
                print("\(count)")
                count = 0
                for polyline in polyLines {
                    mapView?.remove(polyline)
                }
                let coordinate = mapView?.convert(point, toCoordinateFrom: mapView!)
                if coordinate != nil {
                    coordinates.append(coordinate!)
                }
                if coordinates.count > 3 {
                    geoFenceManager?.addPolygonRegionForMonitoring(withCoordinates: &coordinates, count: coordinates.count, customID: "drawing")
                    newFence = FenceModel(token: "", fenceName: "", coordinates: coordinates)
                    drawComplete = true
                }
                coordinates.removeAll()
            }
        }
        
    }
    
    // 绘制点点之间的直线
    func addPolyLine(start: CGPoint, end: CGPoint) {
        let startCoordinate = mapView?.convert(start, toCoordinateFrom: mapView!)
        let endCoordinate = mapView?.convert(end, toCoordinateFrom: mapView!)
        var lineCoordinates: [CLLocationCoordinate2D] = [startCoordinate!, endCoordinate!]
        let polyline: MAPolyline = MAPolyline(coordinates: &lineCoordinates, count: UInt(lineCoordinates.count))
        polyLines.append(polyline)
        mapView?.add(polyline)
    }
    
    func amapGeoFenceManager(_ manager: AMapGeoFenceManager!, didAddRegionForMonitoringFinished regions: [AMapGeoFenceRegion]!, customID: String!, error: Error!) {
        if customID == "drawing" {
            if error == nil {
                let polygonRegion: AMapGeoFencePolygonRegion = regions.first as! AMapGeoFencePolygonRegion
                polygonOverlay = MAPolygon(coordinates: polygonRegion.coordinates, count: UInt(polygonRegion.count))
                mapView?.add(polygonOverlay!)
                //mapView?.setVisibleMapRect((polygonOverlay?.boundingMapRect)!, animated: true)
            }
        }
        if customID == "drew" {
            if error == nil {
                let polygonRegion: AMapGeoFencePolygonRegion = regions.first as! AMapGeoFencePolygonRegion
                polygonOverlay = MAPolygon(coordinates: polygonRegion.coordinates, count: UInt(polygonRegion.count))
                polygons.append(polygonOverlay!)
                mapView?.add(polygonOverlay!)
                //mapView?.setVisibleMapRect((polygonOverlay?.boundingMapRect)!, animated: true)
            }
        }
        if customID == "selected" {
            if error == nil {
                let polygonRegion: AMapGeoFencePolygonRegion = regions.first as! AMapGeoFencePolygonRegion
                polygonOverlay = MAPolygon(coordinates: polygonRegion.coordinates, count: UInt(polygonRegion.count))
                polygons.insert(polygonOverlay!, at: selected_fence - 1)
                mapView?.add(polygonOverlay!)
                if last_selected_fence != 0 {
                    drawSelectedFence(withIndex: last_selected_fence - 1)
                }
                mapView?.setVisibleMapRect((polygonOverlay?.boundingMapRect)!, animated: true)
            }
        }
        if customID == "redraw" {
            if error == nil {
                let polygonRegion: AMapGeoFencePolygonRegion = regions.first as! AMapGeoFencePolygonRegion
                polygonOverlay = MAPolygon(coordinates: polygonRegion.coordinates, count: UInt(polygonRegion.count))
                polygons.insert(polygonOverlay!, at: last_selected_fence - 1)
                mapView?.add(polygonOverlay!)
            }
        }
        if customID == "unselected" {
            if error == nil {
                let polygonRegion: AMapGeoFencePolygonRegion = regions.first as! AMapGeoFencePolygonRegion
                polygonOverlay = MAPolygon(coordinates: polygonRegion.coordinates, count: UInt(polygonRegion.count))
                polygons.insert(polygonOverlay!, at: selected_fence - 1)
                selected_fence = 0
                last_selected_fence = 0
                mapView?.add(polygonOverlay!)
                polygonOverlay = nil
            }
        }
    }
    
    func amapGeoFenceManager(_ manager: AMapGeoFenceManager!, didGeoFencesStatusChangedFor region: AMapGeoFenceRegion!, customID: String!, error: Error!) {
        if error == nil {
            print("status changed")
        } else {
            print("status changed error")
        }
    }
    
    func mapView(_ mapView: MAMapView!, rendererFor overlay: MAOverlay!) -> MAOverlayRenderer! {
        
        if overlay.isKind(of: MAPolygon.self) {
            let polylineRenderer: MAPolygonRenderer = MAPolygonRenderer(polygon: (overlay as! MAPolygon))
            if !isDraw {
                polylineRenderer.lineWidth = 3
                polylineRenderer.strokeColor = UIColor.gray
                polylineRenderer.fillColor = UIColor.yellow
                if fenceSelected {
                    polylineRenderer.fillColor = UIColor.green
                    fenceSelected = false
                }
                
            } else {
                if fenceUnSelected {
                    polylineRenderer.strokeColor = UIColor.gray
                    polylineRenderer.fillColor = UIColor.yellow
                    fenceUnSelected = false
                } else {
                    polylineRenderer.strokeColor = UIColor.orange
                }
                polylineRenderer.lineWidth = 3
            }
            print("rendererFor")
            return polylineRenderer
        }
        
        if overlay.isKind(of: MAPolyline.self) {
            let renderer: MAPolylineRenderer = MAPolylineRenderer(overlay: overlay)
            renderer.lineWidth = 3
            renderer.strokeColor = UIColor.orange
            
            return renderer
        }
        return nil
    }
    
}

extension FenceViewController {
    
    // 围栏按钮点击事件
    @objc func addNewFence(_ sender: UIButton) {
        if sender.currentTitle == "新增" {
            let dis = self.distance(p1: CGPoint(x: 0, y: 0), p2: CGPoint(x: kScreenW, y: 0))
            // 横向展示区域大于20km
            if dis > 20000 {
                let aView = UILabel(frame: CGRect(x: 0, y: 0, width: 150, height: 30))
                aView.text = "请放大地图后再新增围栏"
                aView.font = UIFont.systemFont(ofSize: 13)
                popview.show(aView, point: CGPoint(x: sender.frame.width / 2, y: sender.frame.height + 10), inView: sender)
                return
            }
            drawUnSelectedFence(withIndex: selected_fence - 1)
            if !isDraw {
                setDrawFence(draw: true)
                updateFenceButton()
            }
        } else if sender.currentTitle == "围栏一" {
            onFenceSelected(index: 1)
        } else if sender.currentTitle == "围栏二" {
            onFenceSelected(index: 2)
        } else if sender.currentTitle == "围栏三" {
            onFenceSelected(index: 3)
        } else if sender.currentTitle == "围栏四" {
            onFenceSelected(index: 4)
        }
    }
    
    // 删除栅栏
    @objc func deleteFence() {
        if let polygon: MAPolygon = polygons[selected_fence - 1] {
            mapView?.remove(polygon)
            fences.remove(at: selected_fence - 1)
            polygons.remove(at: selected_fence - 1)
            selected_fence = 0
            last_selected_fence = 0
            updateFenceButton()
        }
    }
    
    // 确定添加电子围栏
    @objc func addOneFence() {
        isDraw = false
        drawComplete = false
        if newFence != nil {
            fences.append(newFence!)
            newFence = nil
        }
        mapView?.remove(polygonOverlay)
        drawAllFence()
        setDrawFence(draw: false)
        updateFenceButton()
    }
    
    // 重绘
    @objc func reDrawFence() {
        if polygonOverlay != nil {
            drawComplete = false
            
            mapView?.remove(polygonOverlay!)
            geoFenceManager?.removeAllGeoFenceRegions()
        }
    }
    
    // 移除所有围栏
    func removeAllPolygon() {
        if polygons.count > 0 {
            for polygon in polygons {
                mapView?.remove(polygon)
            }
        }
    }
    
    // 重绘选中围栏
    func drawSelectedFence(withIndex: Int) {
        mapView?.remove(polygons[withIndex])
        polygons.remove(at: withIndex)
        let fence = fences[withIndex]
        if withIndex == selected_fence - 1 {
            fenceSelected = true
            geoFenceManager?.addPolygonRegionForMonitoring(withCoordinates: &fence.coordinates, count: fence.coordinates.count, customID: "selected")
        } else {
            fenceSelected = false
            geoFenceManager?.addPolygonRegionForMonitoring(withCoordinates: &fence.coordinates, count: fence.coordinates.count, customID: "redraw")
        }
    }
    
    func drawUnSelectedFence(withIndex: Int) {
        if selected_fence != 0 {
            mapView?.remove(polygons[withIndex])
            polygons.remove(at: withIndex)
            let fence = fences[withIndex]
            if withIndex == selected_fence - 1 {
                fenceUnSelected = true
                geoFenceManager?.addPolygonRegionForMonitoring(withCoordinates: &fence.coordinates, count: fence.coordinates.count, customID: "unselected")
            }
        }
    }
    
    // 重绘所有围栏
    func drawAllFence() {
        removeAllPolygon()
        polygons.removeAll()
        var i: Int = 0
        while i < fences.count {
            let fence = fences[i]
            geoFenceManager?.addPolygonRegionForMonitoring(withCoordinates: &fence.coordinates, count: fence.coordinates.count, customID: "drew")
            i = i + 1
        }
    }
    
    // 测量屏幕两点的直线距离
    func distance(p1: CGPoint, p2: CGPoint) -> CLLocationDistance {
        if mapView != nil {
            let startPoint = mapView!.convert(p1, toCoordinateFrom: mapView!)
            let endPoint = mapView!.convert(p2, toCoordinateFrom: mapView!)
            
            let point1 = MAMapPointForCoordinate(startPoint)
            let point2 = MAMapPointForCoordinate(endPoint)
            
            let distance = MAMetersBetweenMapPoints(point1, point2)
            print(distance)
            return distance
        }
        return 0
    }
}
