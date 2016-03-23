//
//  SearchViewController.swift
//  ehreader
//
//  Created by 周泽勇 on 16/3/17.
//  Copyright © 2016年 bravedefault. All rights reserved.
//

import UIKit
import SnapKit

private let SearchTagCellIdentifer = "SearchTagCellIdentifer"

let SearchType:[String] = ["在标签中搜索", "按热门度搜索", "在标题中搜索", "在用户中搜索"]
let SearchTypeImage:[String] = ["ico_tag", "ico_func_premium", "ico_detail", "ico_user"]

class SearchViewController: UIViewController {
    private lazy var searchBar:UISearchBar = {
        let searchBar = UISearchBar(frame: CGRectZero)
        searchBar.showsCancelButton = false
        searchBar.delegate = self
        return searchBar
    }()
    
    private lazy var tableView:UITableView = {
        let tableView = UITableView(frame: CGRectZero, style: UITableViewStyle.Grouped)
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: SearchTagCellIdentifer)
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()
    
    var searchHistory:[String] = []
    
    lazy var searchHintArray:[[String]] = {
        let array = [SearchType, self.searchHistory]
        return array
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.navigationItem.titleView = self.searchBar
        self.view.addSubview(tableView)
        addConstraints()
    }
    
    func addConstraints() {
        tableView.snp_makeConstraints { (make) in
            make.top.leading.trailing.bottom.equalTo(self.view)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        searchBar.frame = CGRectMake(0, 0, self.view.frame.width, 44)
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(true, animated: true)
        return true
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        UIApplication.sharedApplication().keyWindow?.endEditing(true)
    }
}

extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.searchHintArray.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchHintArray[section].count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(SearchTagCellIdentifer)!
        cell.textLabel?.text = self.searchHintArray[indexPath.section][indexPath.row]
        cell.textLabel?.font = UIFont.systemFontOfSize(14)
        if indexPath.section == 0 {
            cell.imageView?.image = UIImage(named: SearchTypeImage[indexPath.row])
        }else {
            cell.imageView?.image = UIImage(named: "ico_tag")
        }
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        return cell
    }
}
