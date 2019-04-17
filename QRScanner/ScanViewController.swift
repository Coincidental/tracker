//
//  ScanViewController.swift
//  Tracker
//
//  Created by StephenLouis on 2019/1/16.
//  Copyright © 2019 StephenLouis. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class ScanViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var flashOpen: Bool? = nil
    private lazy var session: AVCaptureSession = {
        // 获取摄像设备
        let device: AVCaptureDevice = AVCaptureDevice.default(for: AVMediaType.video)!
        // 创建输入流
        var input: AVCaptureDeviceInput?
        do {
            let myinput: AVCaptureDeviceInput = try AVCaptureDeviceInput(device: device)
            input = myinput
        } catch let error as NSError {
            print(error)
        }
        // 创建输出流
        let output: AVCaptureMetadataOutput = AVCaptureMetadataOutput()
        
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        // 设置扫描区域的比例
        let width = 300 / self.view.bounds.height
        let height = 300 / self.view.bounds.width
        output.rectOfInterest = CGRect(x: (1 - width)/2, y: (1 - height)/2, width: width, height: height)
        let session1 = AVCaptureSession()
        // 高质量采集率
        session1.canSetSessionPreset(AVCaptureSession.Preset.high)
        session1.addInput(input!)
        session1.addOutput(output)
        
        //设置扫码支持的编码格式（这里设置条形码和二维码兼容）
        output.metadataObjectTypes = [AVMetadataObject.ObjectType.qr, AVMetadataObject.ObjectType.ean13,AVMetadataObject.ObjectType.ean8,AVMetadataObject.ObjectType.code128]
        return session1
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "打开闪光灯", style: .plain, target: self, action: #selector(rightBarButtonDidClick))
        let layer: AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
        layer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        layer.frame = self.view.layer.bounds
        self.view.layer.insertSublayer(layer, at: 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.session.startRunning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.session.startRunning()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if metadataObjects.count > 0 {
            self.session.stopRunning()
            let metadataObject: AVMetadataMachineReadableCodeObject = metadataObjects.first as! AVMetadataMachineReadableCodeObject
            self.showAlert(title: "扫描结果", message: metadataObject.stringValue!, handler: { (ht) in
                self.session.startRunning()
            })
        }
    }
    
}

// 打开闪光灯
extension ScanViewController {
    @objc func rightBarButtonDidClick() {
        self.flashOpen = !self.flashOpen!
        let device: AVCaptureDevice = AVCaptureDevice.default(for: AVMediaType.audio)!
        if device.hasTorch && device.hasFlash {
            if self.flashOpen! {
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "关闭闪光灯", style: .plain, target: self, action: #selector(rightBarButtonDidClick))
            }
            device.torchMode = AVCaptureDevice.TorchMode.on
            //device.flashMode = AVCaptureDevice.FlashMode.on
        } else {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "打开闪光灯", style: .plain, target: self, action: #selector(rightBarButtonDidClick))
            device.torchMode = AVCaptureDevice.TorchMode.off
            //device.flashMode = AVCaptureDevice.FlashMode.off
        }
    }
}

extension UIViewController {
    func showAlert(title: String, message: String, handler: @escaping((UIAlertAction)->Void)) {
        let alert: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action: UIAlertAction = UIAlertAction(title: "确定", style: .default, handler: handler)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
}
