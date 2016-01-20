//
//  PixivProvider.swift
//  ehreader
//
//  Created by yrtd on 16/1/20.
//  Copyright © 2016年 bravedefault. All rights reserved.
//

import UIKit
import Alamofire

/// NSOperatioinQueue maxConcurrentOperationCount define
public let MaxConCurrentOperationCount:Int = 2

/// API fetch timeout
public let MaxPixivAPIFetchTimeout:NSTimeInterval = 30

/// return value if a intger field is NSNull
public let PixivIntInvalid = -1

/// Auth key for NSUserDefaults
public let PixivAuthStorageKey = "PixivAPI_Auth"

/// API URLs
public let PixivLoginRoot = "https://oauth.secure.pixiv.net/auth/token"
public let PixivSAPIRoot = "http://spapi.pixiv.net/iphone/"
public let PixivPAPIRoot = "https://public-api.secure.pixiv.net/v1/"

public let PixivDefaultHeaders = [
    "Referer": "http://spapi.pixiv.net/",
    "User-Agent": "PixivIOSApp/5.1.1",
    "Content-Type": "application/x-www-form-urlencoded"
]

public class PixivProvider: NSObject {
    public var accessToken:String?
    public var session:String?
    public var userId:Int = PixivIntInvalid
    
    private var loginRoot:String = PixivLoginRoot
    private var sapiRoot:String = PixivSAPIRoot
    private var papiRoot:String = PixivPAPIRoot
    private var defaultHeaders:[String:String] = PixivDefaultHeaders
    
    public lazy var operationQueue:NSOperationQueue = {
        let queue = NSOperationQueue()
        queue.maxConcurrentOperationCount = MaxConCurrentOperationCount
        return queue
    }()
    
    public static func getInstance()->PixivProvider {
        return Inner.instance
    }
    
    private struct Inner {
        static let instance: PixivProvider = PixivProvider()
    }
    
    public func login(username:String, password:String)->[String:String] {
        let url = self.loginRoot
        var loginHeader:[String:String] = [
            "Referer": "http://www.pixiv.net/"
        ]
        
        let data = [
            "username": username,
            "password": password,
            //// OAuth login from PixivIOSApp/5.1.1
            "grant_type": "password",
            "client_id": "bYGKuGVw91e0NMfPGp44euvGt59s",
            "client_secret": "HP3RmkgAmEGro0gn1x9ioawQE8WMfvLXDz3ZqxpK"
        ]
        
        Alamofire.request(.POST, url, parameters: loginHeader, encoding: ParameterEncoding.URL, headers: loginHeader)
        return [String:String]()
    }
}
