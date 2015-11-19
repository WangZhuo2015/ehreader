//
//  Download.swift
//  ehreader
//
//  Created by yrtd on 15/11/17.
//  Copyright © 2015年 bravedefault. All rights reserved.
//

import Foundation
import RealmSwift

public enum DownloadStatus:Int {
    case Downloading = 0
    case Preding = 1
    case Paused = 2
    case Success = 3
    case Error = 4
}

public class Download: Object {
    public dynamic var id:Int = 0
    
    public dynamic var status:Int = 0
    
    public dynamic var progress:Int = 0
    
    public dynamic var created:NSDate = NSDate()
    
    public dynamic var gallery:Gallery?
    
    override public static func primaryKey() -> String? {
        return "id"
    }
}
