//
//  PerformanceTests.swift
//  TaskMasterTests
//
//  Created by Genki on 9/23/24.
//

import CoreData
@testable import TaskMaster
import XCTest

final class PerformanceTests: BaseTestCase {
    func testAwardCalculationPerformance() {
        // テスト用に大量のデータを生成する
        for _ in 1...100 {
            dataController.createSampleData()
        }
        let awards = Array(repeating: Award.allAwards, count: 25).joined()
        XCTAssertEqual(awards.count, 500, "ここでは称号の数が一定であるかどうかをチェックします。")
        measure {
            _ = awards.filter(dataController.hasEarned).count
        }
    }
}
