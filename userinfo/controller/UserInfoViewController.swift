//
//  UserInfoViewController.swift
//  Tracker
//
//  Created by StephenLouis on 2019/1/25.
//  Copyright © 2019 StephenLouis. All rights reserved.
//

import Foundation

let kWindowHeight: CGFloat = 205.0

class UserInfoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var tableView: UITableView?
    var headerView: UserInfoNaviView?
    
    let titles: [String] = ["我的设备","SOS信息","问题反馈","软件版本"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        
        tableView = UITableView(frame: CGRect.zero, style: .grouped)
        tableView?.backgroundColor = UIColor.clear
        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView?.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        self.view.addSubview(tableView!)
        
        headerView = UserInfoNaviView()
        headerView!.myInit(CGRect(x: 0, y: kStatusHeight, width: self.view.frame.size.width, height: kWindowHeight), backImageName: "background", headerImageURL: "http://d.hiphotos.baidu.com/image/pic/item/0ff41bd5ad6eddc4f263b0fc3adbb6fd52663334.jpg", title: "设置", subTitle: "编辑用户信息")
        headerView?.scrollView = tableView
        headerView?.initWithClosure({ () -> Void in
            print("headerImageAction")
        })
        self.view.addSubview(headerView!)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as UITableViewCell
        cell.textLabel!.text = titles[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }
}
