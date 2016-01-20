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
public let MaxPixivAPIFetchTimeout:NSTimeInterval = 3000

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

private struct ResponseWrapper {
    var header:[NSObject : AnyObject]
    var data:NSData?
    var payload:String?
    
    init(header:[NSObject : AnyObject], responseData:NSData?) {
        self.header = header
        self.data = responseData
        if responseData != nil {
            self.payload = String(data: responseData!, encoding: NSUTF8StringEncoding)
        }
    }
    
    func isValid()->Bool {
        return self.data != nil
    }
}

private extension Dictionary {
    func buildUrlParameters()->String? {
        var parts:[String] = []
        for (key, value) in self {
            let encodedKey = (key as? String)?.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            let encodedValue = (value as? String)?.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            if encodedKey == nil || encodedValue == nil {
                continue
            }
            parts.append("\(encodedKey!)=\(encodedValue!)")
        }
        if parts.count > 0 {
            return (parts as NSArray).componentsJoinedByString("&")
        }else {
            return nil
        }
    }
}


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
    
    /**
     Login to the server, use oauth2.0. the response example like:
     {"response":{"access_token":"P7xGYwAmksSI-ZLPteTESgT4SIH1NVWTctOf0kzSnGU","expires_in":3600,"token_type":"bearer","scope":"unlimited","refresh_token":"YHTOSLhPJTylNUyP6ntiI6CyNohlyd7AH-xhMasxs4o","user":{"profile_image_urls":{"px_16x16":"http:\\source.pixiv.net/common/images/no_profile_ss.png","px_50x50":"http:/\\/source.pixiv.net/common/images/no_profile_s.png","px_170x170":"http://source.pixiv.net/common/images/no_profile.png"},"id":"8701294","name":"zzycami","account":"zzycami"}}}
     
     - parameter username:
     - parameter password:
     
     - returns: user information
     */
    public func login(username:String, password:String)throws->[String:String]? {
        let url = self.loginRoot
        let loginHeader:[String:String] = [
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
        
        let result = try requestUrl("POST", url: url, headers: loginHeader, parameters: nil, content: data)
        if !result.isValid() {
            return nil
        }
        
        
        return [String:String]()
    }
}

extension PixivProvider {
    private func requestUrl(method:String = "GET", url:String, headers:[String:String]?, parameters:[String:String]?, content:[String:String]?)throws->ResponseWrapper {
        let request = NSMutableURLRequest()
        request.HTTPMethod = method
        request.timeoutInterval = MaxPixivAPIFetchTimeout
        request
        
        //headers
        for (key, value) in self.defaultHeaders {
            request.setValue(value, forHTTPHeaderField: key)
        }
        if let _headers = headers {
            for (key, value) in _headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        // url
        var requestUrl = url
        if let urlParameters = parameters?.buildUrlParameters() {
            requestUrl = "\(requestUrl)?\(urlParameters)"
        }
        request.URL = NSURL(string: requestUrl)
        
        //body
        if let payload = content?.buildUrlParameters() {
            request.HTTPBody = payload.dataUsingEncoding(NSUTF8StringEncoding)
        }
        
        // request
        var response:NSURLResponse?
        let responseData = try NSURLConnection.sendSynchronousRequest(request, returningResponse: &response)
        let httpResponse = response as! NSHTTPURLResponse
        return ResponseWrapper(header: httpResponse.allHeaderFields, responseData: responseData)
    }
}
