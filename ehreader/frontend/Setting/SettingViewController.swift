//
//  SettingViewController.swift
//  ehreader
//
//  Created by 周泽勇 on 16/4/7.
//  Copyright © 2016年 bravedefault. All rights reserved.
//

import UIKit

private let SettingCellIdentifier = "SettingCellIdentifier"

class SettingViewController: UIViewController {
    private lazy var tableView:UITableView = {
        let tableView = UITableView(frame: CGRectZero, style: UITableViewStyle.Grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: SettingCellIdentifier)
        return tableView
    }()

    private lazy var settingGroups:[SettingGroup] = {
        var settingGroups:[SettingGroup] = []
        
        var group = SettingGroup()
        group.title = "设定"
        group.settings.append(SettingModel(title: "分享设定"))
        group.settings.append(SettingModel(title: "清除本地缓存"))
        group.settings.append(SettingModel(title: "删除历史搜索记录"))
        settingGroups.append(group)
        
        group = SettingGroup()
        group.title = "支援"
        group.settings.append(SettingModel(title: "关于"))
        group.settings.append(SettingModel(title: "给我们评分"))
        group.settings.append(SettingModel(title: "反馈中心"))
        settingGroups.append(group)
        
        return settingGroups
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        self.title = "设置"
        view.addSubview(tableView)
        addConstraints()
    }
    
    private func addConstraints() {
        tableView.snp_makeConstraints { (make) in
            make.top.bottom.leading.trailing.equalTo(self.view)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension SettingViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return settingGroups.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingGroups[section].settings.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(SettingCellIdentifier)!
        cell.textLabel?.text = settingGroups[indexPath.section].settings[indexPath.row].title
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return settingGroups[section].title
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44;
    }
}
