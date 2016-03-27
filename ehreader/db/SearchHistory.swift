//
//  SearchHistory.swift
//  ehreader
//
//  Created by 周泽勇 on 16/3/27.
//  Copyright © 2016年 bravedefault. All rights reserved.
//

import UIKit
import RealmSwift

public class SearchHistory: Object {
    public dynamic var keyword:String = ""
    
    public dynamic var user:PixivUser?
    
    public dynamic var time:NSDate = NSDate()
    
    public static func addHistory(keyword:String) {
        let realm = try! Realm()
        let history = SearchHistory()
        history.keyword = keyword
        history.user = PixivUser.currentLoginUser()
        try! realm.write({ 
            realm.create(SearchHistory.self, value: history, update: true)
        })
    }
    
    public static func getAllHistory()->Results<SearchHistory> {
        let realm = try! Realm()
        let array = realm.objects(SearchHistory).sorted("time")
        return array
    }
    
    public override static func primaryKey() -> String? {
        return "keyword"
    }
}
