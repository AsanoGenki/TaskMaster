//
//  AssetTest.swift
//  TaskMasterTests
//
//  Created by Genki on 9/23/24.
//

import XCTest
@testable import TaskMaster

class AssetTests: XCTestCase {
    func testColorsExist() {
        let allColors = ["Dark Blue", "Dark Gray", "Gold", "Gray", "Green",
                         "Light Blue", "Midnight", "Orange", "Pink", "Purple", "Red", "Teal"]
        for color in allColors {
            XCTAssertNotNil(UIColor(named: color), "アセットから'\(color)'を取得できませんでした。")
        }
    }    
    func testAwardsLoadCorrectly() {
        XCTAssertTrue(Award.allAwards.isEmpty == false, "JSONからAwardsを取得できませんでした。")
    }
}
