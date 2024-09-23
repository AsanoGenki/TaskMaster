//
//  AwardTests.swift
//  TaskMasterTests
//
//  Created by Genki on 9/23/24.
//

import CoreData
@testable import TaskMaster
import XCTest

final class AwardTests: BaseTestCase {
    let awards = Award.allAwards
    func testAwardIDMatchesName() {
        for award in awards {
            XCTAssertEqual(award.id, award.name, "awardのidは常にそのnameと一致する必要があります。")
        }
    }
    func testNewUserHasUnlockedNoAwards() {
        for award in awards {
            XCTAssertFalse(dataController.hasEarned(award: award), "新規ユーザーには獲得した賞品はありません")
        }
    }
    func testCreatingIssuesUnlocksAwards() {
        let values = [1, 10, 20, 50, 100, 250, 500, 1000]
        for (count, value) in values.enumerated() {
            var issues = [Issue]()
            for _ in 0..<value {
                let issue = Issue(context: managedObjectContext)
                issues.append(issue)
            }
            let matches = awards.filter { award in
                award.criterion == "issues" && dataController.hasEarned(award: award)
            }
            XCTAssertEqual(matches.count, count + 1, "\(value)のタスクを追加すると、\(count + 1) の賞がロック解除されます。")
            dataController.deleteAll()
        }
    }
    func testClosedAwards() {
        let values = [1, 10, 20, 50, 100, 250, 500, 1000]
        for (count, value) in values.enumerated() {
            var issues = [Issue]()
            for _ in 0..<value {
                let issue = Issue(context: managedObjectContext)
                issue.completed = true
                issues.append(issue)
            }
            let matches = awards.filter { award in
                award.criterion == "closed" && dataController.hasEarned(award: award)
            }
            XCTAssertEqual(matches.count, count + 1, "\(value)のタスクを完了すると、\(count + 1) の賞がロック解除されます。")
            for issue in issues {
                dataController.delete(issue)
            }
        }
    }
}
