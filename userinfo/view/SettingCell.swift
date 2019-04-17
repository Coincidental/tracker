//
//  SettingCell.swift
//  Tracker
//
//  Created by StephenLouis on 2019/1/23.
//  Copyright © 2019 StephenLouis. All rights reserved.
//

import Foundation

class SettingCell: UITableViewCell {
    var funcNameLabel: UILabel?
    var imgView: UIImageView?
    var detailLabel: UILabel?
    var detailImageView: UIImageView?
    
    var item: SettingItemModel?
    var contentViewCenterY: CGFloat = 0
    
    func setItem(item: SettingItemModel) {
        self.item = item
        contentViewCenterY = self.contentView.center.y
        updateUI()
    }
    
    func updateUI() {
        let subviews: [UIView] = self.contentView.subviews
        for subview in subviews {
            subview.removeFromSuperview()
        }
        
        // 如果有图片
        if (self.item?.img) != nil {
            setupImgView()
        }
        
        // 功能名称
        if (self.item?.funcName) != nil {
            setupFuncLabel()
        }
        
        // accessoryType
        if (self.item?.accessoryType) != nil {
            
        }
        
        // detailView
        if (self.item?.detailText) != nil {
            
        }
        
        if (self.item?.detailImage) != nil {
            
        }
        
        // bottomline
        let line = UIView(frame: CGRect(x: 0, y: self.bounds.height - 1, width: kScreenW, height: 1))
        line.backgroundColor = colorWithRGBA(234.0, 234.0, 234.0, 1)
        self.contentView.addSubview(line)
    }
    
    func setupImgView() {
        self.imgView = UIImageView(image: self.item?.img)
        self.contentView.addSubview(self.imgView!)
        self.imageView?.snp.makeConstraints{ make in
            make.left.equalTo(kFuncImgToLeftGap)
            make.centerY.equalToSuperview()
        }
    }
    
    func setupFuncLabel() {
        self.funcNameLabel = UILabel()
        self.funcNameLabel?.text = self.item!.funcName
        self.funcNameLabel?.textColor = UIColor(red: 51.0, green: 51.0, blue: 51.0, alpha: 1.0)
        self.funcNameLabel?.font = UIFont.systemFont(ofSize: kFuncLabelFont)
        self.contentView.addSubview(self.funcNameLabel!)
        self.funcNameLabel?.snp.makeConstraints{ make in
            make.left.equalTo((self.imgView?.frame.maxX)! + kFuncLabelToFuncImgGap)
            make.centerY.equalToSuperview()
        }
    }
    
    func sizeForTitle(title: NSString, withFont font: UIFont) -> CGSize {
        let titleRect: CGRect = title.boundingRect(with: CGSize(width: CGFloat(Float.greatestFiniteMagnitude), height: CGFloat(Float.greatestFiniteMagnitude)), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return CGSize(width: titleRect.size.width, height: titleRect.size.height)
    }
    
    func setAccessoryType() {
        switch self.item!.accessoryType! {
        case SettingAccessoryType.settingAccessoryTypeNone:
            break
        case SettingAccessoryType.settingAccessoryTypeDisclosureIndicator:
            setupIndicator()
            break
        case SettingAccessoryType.settingAccessoryTypeSwitch:
            setupSwitch()
            break
        }
    }
    
    func setupIndicator() {
        let indicater = UIImageView(image: UIImage(named: "icon-arrow1"))
        self.contentView.addSubview(indicater)
        indicater.snp.makeConstraints{ make in
            make.centerY.equalToSuperview()
            make.left.equalTo(kScreenW - indicater.bounds.width - kIndicatorToRightGap)
        }
    }
    
    func setupSwitch() {
        let aswitch = UISwitch()
        self.contentView.addSubview(aswitch)
        aswitch.snp.makeConstraints{ make in
            make.centerY.equalToSuperview()
            make.left.equalTo(kScreenW - aswitch.bounds.width - kIndicatorToRightGap)
        }
    }
    
    func setupDetailText() {
        
    }

    
}
