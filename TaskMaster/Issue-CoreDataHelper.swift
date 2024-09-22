//
//  Issue-CoreDataHelper.swift
//  TaskMaster
//
//  Created by Genki on 9/22/24.
//

import Foundation

extension Issue {
    var issueTitle: String {
        get { title ?? "" }
        set { title = newValue }
    }
    var issueContent: String {
        get { content ?? "" }
        set { content = newValue }
    }
    var issueCreationDate: Date {
        creationDate ?? .now
    }
    var issueModificationDate: Date {
        modificationDate ?? .now
    }
    var issueTags: [Tag] {
        let result = tags?.allObjects as? [Tag] ?? []
        return result.sorted()
    }
    var issuePriority: Int {
            get { Int(priority) }
            set { priority = Int16(newValue) }
        }
    var issueTagsList: String {
        guard let tags else {
            return "タグなし"
        }

        if tags.count == 0 {
            return "タグなし"
        } else {
            return issueTags.map(\.tagName).joined(separator: ", ")
        }
    }
    var issueStatus: String {
        if completed {
            return "完了済み"
        } else {
            return "未達成"
        }
    }
    static var example: Issue {
        let controller = DataController(inMemory: true)
        let viewContext = controller.container.viewContext

        let issue = Issue(context: viewContext)
        issue.title = "テストタスク"
        issue.content = "これはテスト用のタスクです。"
        issue.priority = 2
        issue.creationDate = .now
        return issue
    }
}

extension Issue: Comparable {
    public static func < (lhs: Issue, rhs: Issue) -> Bool {
        let left = lhs.issueTitle.localizedLowercase
        let right = rhs.issueTitle.localizedLowercase

        if left == right {
            return lhs.issueCreationDate < rhs.issueCreationDate
        } else {
            return left < right
        }
    }
}
