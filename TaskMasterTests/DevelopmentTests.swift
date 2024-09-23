//
//  DevelopmentTests.swift
//  TaskMasterTests
//
//  Created by Genki on 9/23/24.
//

import CoreData
@testable import TaskMaster
import XCTest

final class DevelopmentTests: BaseTestCase {
    func testSampleDataCreationWorks() {
        dataController.createSampleData()
        XCTAssertEqual(dataController.count(for: Tag.fetchRequest()), 5, "このサンプルタグは5個である必要があります。")
        XCTAssertEqual(dataController.count(for: Issue.fetchRequest()), 50, "このサンプルタスクは50個である必要があります。")
    }
    func testDeleteAllClearsEverything() {
        dataController.createSampleData()
        dataController.deleteAll()
        XCTAssertEqual(dataController.count(for: Tag.fetchRequest()), 0, "このサンプルタグは0個である必要があります。")
        XCTAssertEqual(dataController.count(for: Issue.fetchRequest()), 0, "このサンプルタスクは0個である必要があります。")
    }
    func testExampleTagHasNoIssues() {
        let tag = Tag.example
        XCTAssertEqual(tag.issues?.count, 0, "このサンプルタグにはタスクが0個である必要があります。")
    }
    func testExampleIssueIsHighPriority() {
        let issue = Issue.example
        XCTAssertEqual(issue.priority, 2, "このサンプルタスクの優先度は「高」である必要があります。")
    }
}
