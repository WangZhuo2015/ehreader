//
//  SearchViewController.swift
//  ehreader
//
//  Created by 周泽勇 on 16/3/17.
//  Copyright © 2016年 bravedefault. All rights reserved.
//

import UIKit
import SnapKit
import RealmSwift

private let SearchTagCellIdentifer = "SearchTagCellIdentifer"

let SearchType:[String] = ["在标签中搜索", "在标题和文本中搜索", "只在标题中搜索"]
let SearchTypeImage:[String] = ["ico_tag", "ico_detail", "ico_user"]

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
    
    lazy var searchHistory:Results<SearchHistory> = SearchHistory.getAllHistory()
    
    lazy var searchHintArray:[NSObject] = {
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
    
    deinit {
        //fix crash bug in ios8 http://stackoverflow.com/questions/26103756/uiscrollview-internal-consistency-crash
        self.tableView.delegate = nil;
        self.tableView.dataSource = nil;
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.displayMainTabbar(true)
        self.loadHistory()
        self.tableView.reloadData()
    }
    
    func addConstraints() {
        tableView.snp_makeConstraints { (make) in
            make.top.leading.trailing.bottom.equalTo(self.view)
        }
    }
    
    func loadHistory() {
        self.searchHistory = SearchHistory.getAllHistory()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        searchBar.frame = CGRectMake(0, 0, self.view.frame.width, 44)
    }
    
    func startSearch(query:String, mode:PixivSearchMode) {
        UIApplication.sharedApplication().keyWindow?.endEditing(true)
        let searchResultViewController = SearchResultViewController()
        searchResultViewController.startSearching(query, mode:mode)
        self.navigationController?.pushViewController(searchResultViewController, animated: true)
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
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        guard let query = searchBar.text else{
            return
        }
        if query.isEmpty {
            return
        }
        self.startSearch(query, mode: PixivSearchMode.Tag)
    }
}

extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.searchHintArray.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let array = self.searchHintArray[section] as? [String] {
            return array.count
        }else if let array = self.searchHintArray[section] as? Results<SearchHistory> {
            return array.count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(SearchTagCellIdentifer)!
        if let array = self.searchHintArray[indexPath.section] as? [String] {
            cell.textLabel?.text = array[indexPath.row]
        }else if let array = self.searchHintArray[indexPath.section] as? Results<SearchHistory> {
            cell.textLabel?.text = array[indexPath.row].keyword
        }
        
        cell.textLabel?.font = UIFont.systemFontOfSize(14)
        if indexPath.section == 0 {
            cell.imageView?.image = UIImage(named: SearchTypeImage[indexPath.row])
        }else {
            cell.imageView?.image = UIImage(named: "ico_tag")
        }
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var mode = PixivSearchMode.Tag
        if indexPath.section == 0 && indexPath.row == 0 {
            mode = PixivSearchMode.Tag
        }else if indexPath.section == 0 && indexPath.row == 1 {
            mode = PixivSearchMode.Text
        }else if indexPath.section == 0 && indexPath.row == 1 {
            mode = PixivSearchMode.Caption
        }else if indexPath.section == 1 {
            if let array = self.searchHintArray[indexPath.section] as? Results<SearchHistory> {
                self.searchBar.text = array[indexPath.row].keyword
            }
            mode = PixivSearchMode.ExactTag
        }
        guard let query = searchBar.text else{
            return
        }
        if query.isEmpty {
            return
        }
        self.startSearch(query, mode: mode)
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "搜索历史"
        }
        return ""
    }
}
