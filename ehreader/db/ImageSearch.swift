//
//  ImageSearch.swift
//  ehreader
//
//  Created by yrtd on 15/11/17.
//  Copyright © 2015年 bravedefault. All rights reserved.
//

import Foundation
import RealmSwift

public class ImageSearch: Object {
    public dynamic var id:Int = 0
    
    public dynamic var path:String?
    
    public override static func primaryKey() -> String? {
        return "id"
    }
}
