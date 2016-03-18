//
//  PixivProviderTests.swift
//  ehreader
//
//  Created by 周泽勇 on 16/1/20.
//  Copyright © 2016年 bravedefault. All rights reserved.
//

import XCTest
@testable import ehreader

let username = "zzycami"
let password = "13968118472q"

class PixivProviderTests: XCTestCase {
    private let pixivProvider:PixivProvider = {
        let provider = PixivProvider()
        return provider
    }()

    func testLogin() {
        do {
            let user = try self.pixivProvider.login(username, password: password)
            XCTAssertNotNil(user)
            XCTAssertNotEqual(user!.id, "")
            XCTAssertNotNil(user?.access_token)
            XCTAssertNotNil(self.pixivProvider.session)
        }catch let error as NSError {
            XCTAssert(false, error.localizedDescription)
        }
    }
    
    func testGetRankingAll() {
        do {
            try self.pixivProvider.loginIfNeeded(username, password: password)
        }catch let error as NSError {
            XCTAssert(false, error.localizedDescription)
        }
        
        let expectation = expectationWithDescription("")
        
        self.pixivProvider.getRankingAll(PixivRankingMode.Daily, page: 1) { (illust, error) -> Void in
            XCTAssertNil(error)
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(defaultTimeout, handler: nil)
    }
    
    func testGetLastWorks() {
        do {
            try self.pixivProvider.loginIfNeeded(username, password: password)
        }catch let error as NSError {
            XCTAssert(false, error.localizedDescription)
        }
        let expectation = expectationWithDescription("")
        self.pixivProvider.getLastWorks { (gallery, error) in
            XCTAssertNil(error)
            XCTAssertNotNil(gallery)
            XCTAssertGreaterThan(gallery!.illusts.count, 0)
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(defaultTimeout, handler: nil)
    }
    
    func testGetUserInfomation() {
        do {
            try self.pixivProvider.loginIfNeeded(username, password: password)
        }catch let error as NSError {
            XCTAssert(false, error.localizedDescription)
        }
        let expectation = expectationWithDescription("")
        let userId = PixivUser.currentLoginUser()!.id
        self.pixivProvider.getUserInfomation(userId) { (gallery, error) in
            XCTAssertNil(error)
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(defaultTimeout, handler: nil)
    }
    
}
