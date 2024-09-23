//
//  TagTests.swift
//  TaskMasterTests
//
//  Created by Genki on 9/23/24.
//

import CoreData
@testable import TaskMaster
import XCTest

final class TagTests: BaseTestCase {
    func testCreatingTagsAndIssues() {
        let count = 10
        let issueCount = count * count
        for _ in 0..<count {
            let tag = Tag(context: managedObjectContext)
            for _ in 0..<count {
                let issue = Issue(context: managedObjectContext)
                tag.addToIssues(issue)
            }
        }
        XCTAssertEqual(dataController.count(for: Tag.fetchRequest()), count, "予想されるタグ数: \(count)")
        XCTAssertEqual(dataController.count(for: Issue.fetchRequest()), issueCount, "予想されるタスク数:\(issueCount)")
    }
    func testDeletingTagDoesNotDeleteIssues() throws {
        dataController.createSampleData()
        let request = NSFetchRequest<Tag>(entityName: "Tag")
        let tags = try managedObjectContext.fetch(request)
        dataController.delete(tags[0])
        XCTAssertEqual(dataController.count(for: Tag.fetchRequest()), 4, "1つのタグを削除した後、4つのタグが予想されます。")
        XCTAssertEqual(dataController.count(for: Issue.fetchRequest()), 50, "タグを削除した後、50個のタスクが発生すると予想されます。")
    }
}
