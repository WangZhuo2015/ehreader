//
//  PixivRankingViewController.swift
//  ehreader
//
//  Created by 周泽勇 on 16/3/8.
//  Copyright © 2016年 bravedefault. All rights reserved.
//

import UIKit

let PixivRankingViewTableViewCellIdentifier = "PixivRankingViewTableViewCell"

class PixivRankingViewController: UIViewController {
    private var rankingTypes:[String] = ["每日",//PixivRankingMode.Daily.rawValue,
                                         "每周",//PixivRankingMode.Weekly.rawValue,
                                         "每月",//PixivRankingMode.Monthly.rawValue,
                                         "最受男生欢迎",//PixivRankingMode.Male.rawValue,
                                         "最受女生欢迎",//PixivRankingMode.Female.rawValue,
                                         "Rookie",//PixivRankingMode.Rookie.rawValue,
                                         "每日R18",//PixivRankingMode.DailyR18.rawValue,
                                         "每周R18",//PixivRankingMode.WeeklyR18.rawValue,
                                         "最受男生欢迎R18",//PixivRankingMode.MaleR18.rawValue,
                                         "最受女生欢迎R18",//PixivRankingMode.FemaleR18.rawValue,
                                         "R18g"//PixivRankingMode.R18g.rawValue
                                            ]
    
    private lazy var tableView:UITableView = {
        let tableView = UITableView(frame: CGRectZero)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: PixivRankingViewTableViewCellIdentifier)
        return tableView
    }()
    
    private lazy var backgroundView:BlurView = {
        let backgroundView = BlurView(frame: CGRectZero)
        return backgroundView
    }()
    
    override var preferredContentSize: CGSize {
        get{
            return CGSizeMake(self.view.frame.width, CGFloat(rankingTypes.count*44) + 64)
        }
        set {
            super.preferredContentSize = newValue
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.clearColor()
        
        view.addSubview(backgroundView)
        backgroundView.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(self.view)
        }
        
        view.addSubview(tableView)
        tableView.backgroundColor = UIColor.clearColor()
        self.automaticallyAdjustsScrollViewInsets = true
        tableView.snp_makeConstraints { (make) in
            make.top.equalTo(self.snp_topLayoutGuideBottom)
            make.leading.trailing.bottom.equalTo(self.view)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension PixivRankingViewController:UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rankingTypes.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(PixivRankingViewTableViewCellIdentifier)
        cell!.textLabel?.text = rankingTypes[indexPath.row]
        cell?.backgroundColor = UIColor.clearColor()
        return cell!
    }
}
