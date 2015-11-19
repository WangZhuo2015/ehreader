//
//  Photo.swift
//  ehreader
//
//  Created by yrtd on 15/11/17.
//  Copyright © 2015年 bravedefault. All rights reserved.
//

import Foundation
import RealmSwift

public class Photo: Object {
    public dynamic var id = 0
    
    public dynamic var page:Int = 0
    
    public dynamic var token:String = ""
    
    public dynamic var bookmark:String?
    
    public dynamic var filename:String?
    
    public dynamic var width:Int = 0
    
    public dynamic var height:Int = 0
    
    public dynamic var src:String?
    
    public dynamic var downloaded:Bool = false
    
    public dynamic var invalid:Bool = false
    
    public override static func primaryKey() -> String? {
        return "id"
    }
}
