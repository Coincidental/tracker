//
//  UITableViewExampleVC.swift
//  Tracker
//
//  Created by StephenLouis on 2019/2/28.
//  Copyright © 2019 StephenLouis. All rights reserved.
//

import UIKit

class UITableViewExampleVC: UIViewController {
    
    var tableView: UITableView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView = UITableView()
        self.view.addSubview(tableView!)
        tableView?.snp.makeConstraints{ (make) in
            make.left.equalToSuperview()
            make.top.equalToSuperview().offset(kStatusHeight)
            make.width.equalToSuperview()
            make.height.equalToSuperview()
        }
        tableView?.delegate = self
        tableView?.dataSource = self
    }
    
}

extension UITableViewExampleVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    
}
