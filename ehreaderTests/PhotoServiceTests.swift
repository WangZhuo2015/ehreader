//
//  PhotoServiceTests.swift
//  ehreader
//
//  Created by 周泽勇 on 16/1/18.
//  Copyright © 2016年 bravedefault. All rights reserved.
//

import XCTest
@testable import ehreader

class PhotoServiceTests: XCTestCase {
    private var photoService:PhotoService!
    
    override func setUp() {
        super.setUp()
        let gallery = createTestGallery()
        self.photoService = PhotoService(gallery: gallery)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
