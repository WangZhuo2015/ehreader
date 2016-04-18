//
//  PixivRankingViewController.swift
//  ehreader
//
//  Created by 周泽勇 on 16/3/8.
//  Copyright © 2016年 bravedefault. All rights reserved.
//

import UIKit

let PixivRankingViewTableViewCellIdentifier = "PixivRankingViewTableViewCell"


protocol SimpleListViewControllerDelegate:NSObjectProtocol {
    func simpleListViewController(viewController:SimpleListViewController, didSelectIndex index:Int)
}

protocol SimpleListViewControllerDataSource:NSObjectProtocol {
    func numberOfItemsForSimpleList(viewController:SimpleListViewController) -> Int
    func simpleListViewController(viewController:SimpleListViewController, titleForItemIndex index:Int) -> String
}

class SimpleListViewController: UIViewController {
    weak var delegate:SimpleListViewControllerDelegate?
    weak var dataSource:SimpleListViewControllerDataSource?
    
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
            let count = self.dataSource?.numberOfItemsForSimpleList(self) ?? 0
            return CGSizeMake(self.view.frame.width, CGFloat(count*44) + 64)
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
    
    deinit {
        //fix crash bug in ios8 http://stackoverflow.com/questions/26103756/uiscrollview-internal-consistency-crash
        self.tableView.delegate = nil;
        self.tableView.dataSource = nil;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension SimpleListViewController:UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource?.numberOfItemsForSimpleList(self) ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(PixivRankingViewTableViewCellIdentifier)
        cell!.textLabel?.text = dataSource?.simpleListViewController(self, titleForItemIndex: indexPath.row)
        cell?.backgroundColor = UIColor.clearColor()
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.delegate?.simpleListViewController(self, didSelectIndex: indexPath.row)
    }
}
