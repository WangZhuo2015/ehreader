//
//  PixivProviderTests.swift
//  ehreader
//
//  Created by 周泽勇 on 16/1/20.
//  Copyright © 2016年 bravedefault. All rights reserved.
//

import XCTest
@testable import ehreader

class PixivProviderTests: XCTestCase {
    private let pixivProvider:PixivProvider = {
        let provider = PixivProvider()
        return provider
    }()
    
    func testLogin() {
        do {
            try self.pixivProvider.login("zzycami@foxmail.com", password: "13968118472q")
        }catch let error as NSError {
            XCTAssert(false, error.localizedDescription)
        }
    }
    
}
