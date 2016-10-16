//
//  iTunesSearchTests.swift
//  iTunesSearchTests
//
//  Created by RAJESH SUKUMARAN on 10/13/16.
//  Copyright © 2016 RAJESH SUKUMARAN. All rights reserved.
//

import XCTest
@testable import iTunesSearch

class iTunesSearchTests: XCTestCase,ItunesSearchManagerDelegate {
    
    
    func getSongsWhenDataTaskCompleted(songs:[Song])
    {
        print(songs)
    }
    func getSongDataTaskError(error:NSError)
    {
        print(error.localizedDescription)
    }
    
    
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let manager = ItunesSearchManager()
        manager.delegate = self
        manager.fetchMusicListFromiTunes()
        //XCTAssertEqual(manager.count, 0)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
