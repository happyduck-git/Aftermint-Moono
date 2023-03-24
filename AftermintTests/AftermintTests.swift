//
//  AftermintTests.swift
//  AftermintTests
//
//  Created by Platfarm on 2023/03/24.
//

import XCTest
import FirebaseFirestore

@testable import Aftermint

final class AftermintTests: XCTestCase {

    let sut: LeaderBoardTableViewCellListViewModel = LeaderBoardTableViewCellListViewModel()
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        let num = sut.numberOfRowsInSection(at: 0)
        XCTAssertEqual(num, 0)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
