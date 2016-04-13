//
//  SettingViewController.swift
//  ehreader
//
//  Created by 周泽勇 on 16/4/7.
//  Copyright © 2016年 bravedefault. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController {
    
    private lazy var tableView:UITableView = {
        let tableView = UITableView(frame: CGRectZero)
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
