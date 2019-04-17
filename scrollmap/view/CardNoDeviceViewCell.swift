//
//  CardNoDeviceViewCell.swift
//  Tracker
//
//  Created by StephenLouis on 2018/11/22.
//  Copyright © 2018 StephenLouis. All rights reserved.
//

import UIKit

class CardNoDeviceViewCell: UICollectionViewCell {
    var petView: UIImageView?
    var noDeviceLable: UILabel?
    var bindButton: UIButton?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 16
        self.backgroundColor = UIColor.white
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        petView = UIImageView(image: UIImage(named: "dog"))
        self.contentView.addSubview(petView!)
        petView?.snp.makeConstraints{ (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(Adapt(-30))
        }
        
        noDeviceLable = UILabel()
        noDeviceLable?.text = "当前没有绑定任何设备哦~"
        noDeviceLable?.font = UIFont.systemFont(ofSize: 18)
        noDeviceLable?.textColor = colorWithRGBA(155.0, 155.0, 155.0, 1.0)
        self.contentView.addSubview(noDeviceLable!)
        noDeviceLable?.snp.makeConstraints{ (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(petView!.snp.bottom).offset(Adapt(13))
        }
        
        bindButton = UIButton()
        bindButton?.setTitle("立即绑定", for: .normal)
        bindButton?.setTitleColor(UIColor.white, for: .normal)
        bindButton?.layer.cornerRadius = 15
        bindButton?.backgroundColor = UIColor.orange
        self.contentView.addSubview(bindButton!)
        bindButton?.snp.makeConstraints{ (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(noDeviceLable!.snp.bottom).offset(Adapt(30))
            make.width.equalTo(Adapt(120))
            make.height.equalTo(Adapt(40))
        }
    }
    
}
