//
//  LoginHelperTests.swift
//  ehreader
//
//  Created by yrtd on 15/11/18.
//  Copyright © 2015年 bravedefault. All rights reserved.
//

import XCTest
@testable import ehreader

let defaultTimeout:NSTimeInterval = 1000

class LoginHelperTests: XCTestCase {
    
    func testLogin() {
        // Given
        let expectation = expectationWithDescription("Login should success")
        var testResult = false
        
        // When
        LoginHelper.getInstance().login("zzycami", password: "13968118472q") { (result) -> Void in
            testResult = result
            expectation.fulfill()
        }
        
        // Then
        waitForExpectationsWithTimeout(defaultTimeout, handler: nil)
        XCTAssertTrue(testResult)
        
        let userDefault = NSUserDefaults.standardUserDefaults()
        
        let loggedIn = userDefault.boolForKey(PREF_LOGGED_IN)
        XCTAssertTrue(loggedIn, "not login")
        
        let memberId = userDefault.stringForKey(PREF_LOGIN_MEMBERID)
        XCTAssertNotNil(memberId, "member id should not nil after login")
        
        let passHash = userDefault.stringForKey(PREF_LOGIN_PASSHASH)
        XCTAssertNotNil(passHash, "pass hash should not nil after login in")
        
        let sessionId = userDefault.stringForKey(PREF_LOGIN_SESSIONID)
        XCTAssertNotNil(sessionId, "session id should not nil after loggin in")
    }
    
}
