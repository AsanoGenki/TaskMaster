//
//  ExtensionTests.swift
//  TaskMasterTests
//
//  Created by Genki on 9/23/24.
//

import CoreData
@testable import TaskMaster
import XCTest

final class ExtensionTests: BaseTestCase {
    // Issueのテスト
    func testIssueTitleUnwrap() {
        let issue = Issue(context: managedObjectContext)
        issue.title = "サンプルタスク"
        XCTAssertEqual(issue.issueTitle, "サンプルタスク", "issueのtitleを変更すると、そのissueTitleも変更される必要があります。")
        issue.issueTitle = "更新したタスク"
        XCTAssertEqual(issue.title, "更新したタスク", "issueのissueTitleを変更すると、そのtitleも変更される必要があります。")
    }
    func testIssueContentUnwrap() {
        let issue = Issue(context: managedObjectContext)
        issue.content = "サンプルタスク"
        XCTAssertEqual(issue.issueContent, "サンプルタスク", "issueのcontentを変更すると、そのissueContentも変更される必要があります。")
        issue.issueContent = "更新したタスク"
        XCTAssertEqual(issue.content, "更新したタスク", "issueのissueContentを変更すると、そのcontentも変更される必要があります。")
    }
    func testIssueCreationDateUnwrap() {
        let issue = Issue(context: managedObjectContext)
        let testDate = Date.now
        issue.creationDate = testDate
        XCTAssertEqual(issue.issueCreationDate, testDate, "issueのcreationDateを変更すると、そのissueCreationDateも変更される必要があります。")
    }
    func testIssueTagsUnwrap() {
        let tag = Tag(context: managedObjectContext)
        let issue = Issue(context: managedObjectContext)
        XCTAssertEqual(issue.issueTags.count, 0, "新しいタスクにはタグがついていません。")
        issue.addToTags(tag)
        XCTAssertEqual(issue.issueTags.count, 1, "タスクにタグを1つ追加すると、issueTagsのカウントは1になります。")
    }
    func testIssueTagsList() {
        let tag = Tag(context: managedObjectContext)
        let issue = Issue(context: managedObjectContext)
        tag.name = "サンプルタグ"
        issue.addToTags(tag)
        XCTAssertEqual(issue.issueTagsList, "サンプルタグ", "タスクにタグを1つ追加すると、issueTagsListがサンプルタグになります。")
    }
    func testIssueSortingIsStable() {
        let issue1 = Issue(context: managedObjectContext)
        issue1.title = "タスクB"
        issue1.creationDate = .now
        let issue2 = Issue(context: managedObjectContext)
        issue2.title = "タスクB"
        issue2.creationDate = .now.addingTimeInterval(1)
        let issue3 = Issue(context: managedObjectContext)
        issue3.title = "タスクA"
        issue3.creationDate = .now.addingTimeInterval(100)
        let allIssues = [issue1, issue2, issue3]
        let sorted = allIssues.sorted()
        XCTAssertEqual([issue3, issue1, issue2], sorted, "タスクの配列を並べ替えるには、名前、次に作成日を使用する必要があります。")
    }
    // Tagのテスト
    func testTagIDUnwrap() {
        let tag = Tag(context: managedObjectContext)
        tag.id = UUID()
        XCTAssertEqual(tag.tagID, tag.id, "tagのidを変更すると、そのtagIDも変更される必要があります。")
    }
    func testTagNameUnwrap() {
        let tag = Tag(context: managedObjectContext)
        tag.name = "サンプルタグ"
        XCTAssertEqual(tag.tagName, "サンプルタグ", "tagのnameを変更すると、そのtagNameも変更される必要があります。")
    }
    func testTagActiveIssues() {
        let tag = Tag(context: managedObjectContext)
        let issue = Issue(context: managedObjectContext)
        XCTAssertEqual(tag.tagActiveIssues.count, 0, "新しいタグにはアクティブなタスクが0個である必要があります。")
        tag.addToIssues(issue)
        XCTAssertEqual(tag.tagActiveIssues.count, 1, "1つの新しいタスクを含む新しいタグには、 1個のアクティブなタスクが含まれている必要があります。")
        issue.completed = true
        XCTAssertEqual(tag.tagActiveIssues.count, 0, "完了したタスクが1つある新しいタグには、アクティブなタスクが0個である必要があります。")
    }
    func testTagSortingIsStable() {
        let tag1 = Tag(context: managedObjectContext)
        tag1.name = "タグB"
        tag1.id = UUID()
        let tag2 = Tag(context: managedObjectContext)
        tag2.name = "タグB"
        tag2.id = UUID(uuidString: "FFFFFFFF-DC22-4463-8C69-7275D037C13D")
        let tag3 = Tag(context: managedObjectContext)
        tag3.name = "タグA"
        tag3.id = UUID()
        let allTags = [tag1, tag2, tag3]
        let sortedTags = allTags.sorted()
        XCTAssertEqual([tag3, tag1, tag2], sortedTags, "タグの配列を並び替えるには、名前、次に UUID文字列を使用する必要があります。")
    }
    // Bundle loadingのテスト
    func testBundleDecodingAwards() {
        let awards = Bundle.main.decode("Awards.json", as: [Award].self)
        XCTAssertFalse(awards.isEmpty, "Awards.jsonは空でない配列にデコードする必要があります。")
    }
    func testDecodingString() {
        let bundle = Bundle(for: ExtensionTests.self)
        let data = bundle.decode("DecodableString.json", as: String.self)
        XCTAssertEqual(data, "Never ask a starfish for directions.", "DecodableString.jsonの内容が一致しません。")
    }
    func testDecodingDictionary() {
        let bundle = Bundle(for: ExtensionTests.self)
        let data = bundle.decode("DecodableDictionary.json", as: [String: Int].self)
        XCTAssertEqual(data.count, 3, "DecodableDictionary.jsonには3つの要素がある必要があります。")
        XCTAssertEqual(data["One"], 1, "辞書にはキー「One」に対する値1が含まれている必要があります。")
    }
}
