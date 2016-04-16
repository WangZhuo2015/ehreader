
//
//  SettingModel.swift
//  ehreader
//
//  Created by 周泽勇 on 16/4/14.
//  Copyright © 2016年 bravedefault. All rights reserved.
//

import UIKit

public class SettingGroup: NSObject {
    public var title:String = ""
    public var settings:[SettingModel] = []
    public var cellIdentifier:String?
    
    public override init() {
        super.init()
    }
    
    public init(title:String) {
        super.init()
        self.title = title
    }
}

public class SettingModel: NSObject {
    public convenience init(title:String) {
        self.init(title:title, subtitle:"")
    }
    
    public init(title:String, subtitle:String) {
        super.init()
        self.title = title
        self.subtitle = subtitle
    }
    
    public var title:String = ""
    public var subtitle:String = ""
}