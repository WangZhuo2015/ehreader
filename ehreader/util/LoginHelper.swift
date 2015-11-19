//
//  LoginHelper.swift
//  ehreader
//
//  Created by yrtd on 15/11/17.
//  Copyright © 2015年 bravedefault. All rights reserved.
//

import UIKit
import Alamofire


public let LOGIN_URL = "https://forums.e-hentai.org/index.php"

public let FIELD_USERNAME = "UserName"
public let FIELD_PASSWORD = "PassWord"
public let FIELD_COOKIE_DATE = "CookieDate"

public let PREF_LOGIN_MEMBERID = "login_memberid"
public let PREF_LOGIN_PASSHASH = "login_passhash"
public let PREF_LOGIN_SESSIONID = "login_sessionid"
public let PREF_LOGGED_IN = "logged_in"

public let IPB_MEMBER_ID = "ipb_member_id"
public let IPB_PASS_HASH = "ipb_pass_hash"
public let IPB_SESSION_ID = "ipb_session_id"

public class LoginHelper: NSObject {
    public static func getInstance()->LoginHelper {
        return Inner.instance
    }
    
    private struct Inner {
        static let instance: LoginHelper = LoginHelper()
    }
    
    private let userDefault:NSUserDefaults
    private let httpManager:Manager
    
    public override init() {
        userDefault = NSUserDefaults.standardUserDefaults()
        httpManager = Manager.sharedInstance
        
        super.init()
    }
    
    public func isLoggedIn()->Bool {
        return self.userDefault.boolForKey(PREF_LOGGED_IN)
    }
    
    public func login(username:String, password:String, complete:(result:Bool)->Void) {
        // send a login post
        let parameters:[String:AnyObject] = [
            FIELD_USERNAME: username,
            FIELD_PASSWORD: password,
            FIELD_COOKIE_DATE: "1",
            "CODE": "01",
            "act": "Login"
        ]
        
        httpManager.session.configuration.HTTPShouldSetCookies = true
        
        httpManager.request(.POST, LOGIN_URL, parameters: parameters, encoding: ParameterEncoding.URL, headers: nil).response { (request, response, data, error) -> Void in
            if let source = data {
                let resultString = String(data: source, encoding: NSUTF8StringEncoding)
                print(resultString)
            }
            
            var memberId = ""
            var passHash = ""
            var sessionId = ""
            
            
            if let cookieJar = self.httpManager.session.configuration.HTTPCookieStorage?.cookies {
                for cookie in cookieJar {
                    if cookie.name == IPB_MEMBER_ID {
                        memberId = cookie.value
                    }else if cookie.name == IPB_PASS_HASH {
                        passHash = cookie.value
                    }else if cookie.name == IPB_SESSION_ID {
                        sessionId = cookie.value
                    }
                }
            }
            
            if memberId.isEmpty || passHash.isEmpty || sessionId.isEmpty {
                complete(result: false)
            }else {
                self.userDefault.setBool(true, forKey: PREF_LOGGED_IN)
                self.userDefault.setObject(memberId, forKey: PREF_LOGIN_MEMBERID)
                self.userDefault.setObject(sessionId, forKey: PREF_LOGIN_SESSIONID)
                self.userDefault.setObject(passHash, forKey: PREF_LOGIN_PASSHASH)
                complete(result: true)
            }
        }
    }
    
    public func logout() {
        self.userDefault.setBool(false, forKey: PREF_LOGGED_IN)
        self.userDefault.removeObjectForKey(PREF_LOGIN_MEMBERID)
        self.userDefault.removeObjectForKey(PREF_LOGIN_PASSHASH)
        self.userDefault.removeObjectForKey(PREF_LOGIN_SESSIONID)
    }
}
