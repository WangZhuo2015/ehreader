//
//  Regex.swift
//  ehreader
//
//  Created by yrtd on 15/11/19.
//  Copyright © 2015年 bravedefault. All rights reserved.
//

import UIKit

public class RegexHelper: NSObject {
    public var pattern:String
    private var regularExpression:NSRegularExpression!
    
    public init(pattern:String, options:NSRegularExpressionOptions = NSRegularExpressionOptions.CaseInsensitive)throws {
        self.pattern = pattern
        super.init()
        self.regularExpression = try NSRegularExpression(pattern: pattern, options: options)
    }
    
    public func matches(string:String, matchOptions:NSMatchingOptions = NSMatchingOptions.ReportProgress)->[[String]] {
        let totoalRange = NSMakeRange(0, string.characters.count)
        let matches = self.regularExpression.matchesInString(string, options: matchOptions, range: totoalRange)
        var results:[[String]] = []
        if matches.count > 0 {
            for result in matches {
                var r:[String] = []
                for var i = 0; i < result.numberOfRanges; i++ {
                    let range = result.rangeAtIndex(i)
                    let temp = string as NSString
                    r.append(temp.substringWithRange(range))
                }
                results.append(r)
            }
        }
        return results
    }
}
