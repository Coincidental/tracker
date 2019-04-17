//
//  SmartPowerAlertView.swift
//  Tracker
//
//  Created by StephenLouis on 2018/11/23.
//  Copyright © 2018 StephenLouis. All rights reserved.
//

import UIKit

class SmartPowerAlertView: UIView, PowerRadioButtonGroupDelegate {
    
    func didSelectButton(selectedButton: UIButton?) {
        
    }
    
    
    // 白色view用来装一些控件
    var whiteView: UIView = UIView()
    var whiteViewStratFrame: CGRect = CGRect.init(x: kScreenW / 2 - 10, y: kScreenH / 2 - 10, width: 20, height: 20)
    var whiteViewEndFrame: CGRect = CGRect.init(x: 40, y: 100, width: kScreenW - 80, height: kScreenH - 230)
    
    // 背景半透明黑色
    var backgroundColor1: UIColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.4)
    var defaultTime: CGFloat = 0.5
    
    var selectedItem: Int = 0
    
    var buttonGroup: PowerRadioButtonGroup?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initPopBackgroundView() -> UIView {
        self.frame = CGRect.init(x: 0, y: 0, width: kScreenW, height: kScreenH)
        self.backgroundColor = backgroundColor1
        self.isHidden = true
        
        self.whiteView.frame = whiteViewStratFrame
        whiteView.backgroundColor = UIColor.white
        whiteView.layer.masksToBounds = true
        whiteView.layer.cornerRadius = 10
        self.addSubview(whiteView)
        
        return self
    }
    
    // 弹出动画
    func addAnimate() {
        UIApplication.shared.keyWindow?.addSubview(self.initPopBackgroundView())
        self.isHidden = false
        
        UIView.animate(withDuration: TimeInterval(defaultTime), animations: {
            self.whiteView.frame = self.whiteViewEndFrame
        }) { (_) in
            self.addWhiteViewSubView()
        }
        
    }
    
    // 向中间视图添加子视图
    func addWhiteViewSubView() {
        // 弹窗标题
        let titleLable: UILabel = UILabel.init(frame: CGRect(x: 20, y: 25, width: AdaptW(120), height: AdaptH(20)))
        titleLable.text = "实时定位方式"
        titleLable.textAlignment = NSTextAlignment.center
        titleLable.font = UIFont.boldSystemFont(ofSize: 20)
        titleLable.textColor = colorWithRGBA(61.0, 97.0, 132.0, 1.0)
        self.whiteView.addSubview(titleLable)
        // 退出按钮
        let cancel = UIButton.init(frame: CGRect(x: 290, y: 10, width: AdaptW(30), height: AdaptH(40)))
        cancel.setImage(UIImage(named: "shut"), for: .normal)
        cancel.contentMode = .scaleAspectFit
        cancel.addTarget(self, action: #selector(tapBtnAndCancelBtnClick), for: .touchUpInside)
        self.whiteView.addSubview(cancel)
        // 单选图标按钮
        let powerButton1 = PowerRadioButton.init(frame: CGRect(x: 20, y: 70, width: AdaptW(30), height: AdaptH(40)))
        let powerButton2 = PowerRadioButton.init(frame: CGRect(x: 20, y: 160, width: AdaptW(50), height: AdaptH(50)))
        let powerButton3 = PowerRadioButton.init(frame: CGRect(x: 20, y: 250, width: AdaptW(50), height: AdaptH(50)))
        self.whiteView.addSubview(powerButton1)
        self.whiteView.addSubview(powerButton2)
        self.whiteView.addSubview(powerButton3)
        buttonGroup = PowerRadioButtonGroup(buttons: powerButton1, powerButton2, powerButton3, defaultIndex: selectedItem)
        buttonGroup?.delegate = self
        buttonGroup?.shouldLetDeSelect = true
        // 智能功耗 title summary
        let smartPowerTitle = UILabel.init(frame: CGRect(x: 55, y: 70, width: AdaptW(140), height: AdaptH(40)))
        smartPowerTitle.text = "智能功耗(推荐)"
        smartPowerTitle.font = UIFont.boldSystemFont(ofSize: 18)
        smartPowerTitle.textColor = colorWithRGBA(0, 0, 0, 0.87)
        self.whiteView.addSubview(smartPowerTitle)
        let item1Click = UITapGestureRecognizer(target: self, action: #selector(clickItem1))
        item1Click.numberOfTapsRequired = 1
        item1Click.numberOfTouchesRequired = 1
        smartPowerTitle.isUserInteractionEnabled = true
        smartPowerTitle.addGestureRecognizer(item1Click)
        
        let smartPowerSummary = UILabel.init(frame: CGRect(x: 55, y: 110, width: AdaptW(240), height: AdaptH(40)))
        smartPowerSummary.text = "基于距离、电量、追踪器移动速度等采取\n智能定位策略，功耗与定位效果兼得。"
        smartPowerSummary.numberOfLines = 2
        smartPowerSummary.font = UIFont.boldSystemFont(ofSize: 14)
        smartPowerSummary.textColor = colorWithRGBA(155.0, 155.0, 155.0, 1.0)
        self.whiteView.addSubview(smartPowerSummary)
        let item2Click = UITapGestureRecognizer(target: self, action: #selector(clickItem1))
        item2Click.numberOfTapsRequired = 1
        item2Click.numberOfTouchesRequired = 1
        smartPowerSummary.isUserInteractionEnabled = true
        smartPowerSummary.addGestureRecognizer(item2Click)
        
        // 高精确度、刷新频率 title summary
        let highAccuracyTitle = UILabel.init(frame: CGRect(x: 55, y: 167, width: AdaptW(180), height: AdaptH(40)))
        highAccuracyTitle.text = "高精确度、刷新频率"
        highAccuracyTitle.font = UIFont.boldSystemFont(ofSize: 18)
        highAccuracyTitle.textColor = colorWithRGBA(0, 0, 0, 0.87)
        self.whiteView.addSubview(highAccuracyTitle)
        let item3Click = UITapGestureRecognizer(target: self, action: #selector(clickItem2))
        item3Click.numberOfTapsRequired = 1
        item3Click.numberOfTouchesRequired = 1
        highAccuracyTitle.isUserInteractionEnabled = true
        highAccuracyTitle.addGestureRecognizer(item3Click)
        
        let highAccuracySummary = UILabel.init(frame: CGRect(x: 55, y: 207, width: AdaptW(240), height: AdaptH(40)))
        highAccuracySummary.text = "使用GPS、北斗确定位置，仅建议在电量\n充足时使用。"
        highAccuracySummary.numberOfLines = 2
        highAccuracySummary.font = UIFont.boldSystemFont(ofSize: 14)
        highAccuracySummary.textColor = colorWithRGBA(155.0, 155.0, 155.0, 1.0)
        self.whiteView.addSubview(highAccuracySummary)
        let item4Click = UITapGestureRecognizer(target: self, action: #selector(clickItem2))
        item4Click.numberOfTapsRequired = 1
        item4Click.numberOfTouchesRequired = 1
        highAccuracySummary.isUserInteractionEnabled = true
        highAccuracySummary.addGestureRecognizer(item4Click)
        
        // 低耗电量
        let lowPowerTitle = UILabel.init(frame: CGRect(x: 55, y: 257, width: AdaptW(140), height: AdaptH(40)))
        lowPowerTitle.text = "低耗电量"
        lowPowerTitle.font = UIFont.boldSystemFont(ofSize: 18)
        lowPowerTitle.textColor = colorWithRGBA(0, 0, 0, 0.87)
        self.whiteView.addSubview(lowPowerTitle)
        let item5Click = UITapGestureRecognizer(target: self, action: #selector(clickItem3))
        item5Click.numberOfTapsRequired = 1
        item5Click.numberOfTouchesRequired = 1
        lowPowerTitle.isUserInteractionEnabled = true
        lowPowerTitle.addGestureRecognizer(item5Click)
        
        let lowPowerSummary = UILabel.init(frame: CGRect(x: 55, y: 297, width: AdaptW(240), height: AdaptH(40)))
        lowPowerSummary.text = "使用基站定位，可保持高续航时长，但定\n位精度较低。"
        lowPowerSummary.numberOfLines = 2
        lowPowerSummary.font = UIFont.boldSystemFont(ofSize: 14)
        lowPowerSummary.textColor = colorWithRGBA(155.0, 155.0, 155.0, 1.0)
        self.whiteView.addSubview(lowPowerSummary)
        let item6Click = UITapGestureRecognizer(target: self, action: #selector(clickItem3))
        item6Click.numberOfTapsRequired = 1
        item6Click.numberOfTouchesRequired = 1
        lowPowerSummary.isUserInteractionEnabled = true
        lowPowerSummary.addGestureRecognizer(item6Click)
    }
    
    @objc func tapBtnAndCancelBtnClick() {
        
        for view in whiteView.subviews {
            view.removeFromSuperview()
        }
        UIView.animate(withDuration: TimeInterval(defaultTime), animations: {
            self.whiteView.frame = self.whiteViewStratFrame
        }) { (_) in
            self.isHidden = true
        }
    }
    
    @objc func clickItem1() {
        buttonGroup?.setSelectButton(index: 0)
    }
    
    @objc func clickItem2() {
        buttonGroup?.setSelectButton(index: 1)
    }
    
    @objc func clickItem3() {
        buttonGroup?.setSelectButton(index: 2)
    }
}
