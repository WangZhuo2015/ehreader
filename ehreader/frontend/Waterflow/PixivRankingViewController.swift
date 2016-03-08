//
//  PixivRankingViewController.swift
//  ehreader
//
//  Created by 周泽勇 on 16/3/8.
//  Copyright © 2016年 bravedefault. All rights reserved.
//

import UIKit

let PixivRankingViewTableViewCellIdentifier = "PixivRankingViewTableViewCell"

var rankingTypes:[PixivRankingMode:String] = [
    PixivRankingMode.Daily: "每日",
    PixivRankingMode.Weekly:"每周",
    PixivRankingMode.Monthly:"每月",
    PixivRankingMode.Male:"最受男生欢迎",
    PixivRankingMode.Female:"最受女生欢迎",
    PixivRankingMode.Rookie:"Rookie",
    PixivRankingMode.DailyR18:"每日R18",
    PixivRankingMode.WeeklyR18:"每周R18",
    PixivRankingMode.MaleR18:"最受男生欢迎R18",
    PixivRankingMode.FemaleR18:"最受女生欢迎R18",
    PixivRankingMode.R18g:"R18g"]

protocol PixivRankingViewControllerDelegate:NSObjectProtocol {
    func pixivRankingViewController(viewController:PixivRankingViewController, didSelectRankingMode rankingMode:PixivRankingMode, rankingName:String?)
}

class PixivRankingViewController: UIViewController {
    weak var delegate:PixivRankingViewControllerDelegate?
    
    private var rankingKeys:[PixivRankingMode] = [PixivRankingMode.Daily, PixivRankingMode.Weekly, PixivRankingMode.Monthly, PixivRankingMode.Male, PixivRankingMode.Female, PixivRankingMode.Rookie, PixivRankingMode.DailyR18, PixivRankingMode.WeeklyR18, PixivRankingMode.MaleR18, PixivRankingMode.FemaleR18, PixivRankingMode.R18g]
    
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
        return rankingKeys.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(PixivRankingViewTableViewCellIdentifier)
        let key = rankingKeys[indexPath.row]
        cell!.textLabel?.text = rankingTypes[key]
        cell?.backgroundColor = UIColor.clearColor()
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let key = rankingKeys[indexPath.row]
        self.delegate?.pixivRankingViewController(self, didSelectRankingMode: key, rankingName: rankingTypes[key])
    }
}
