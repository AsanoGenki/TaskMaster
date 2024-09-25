//
//  IssueRowViewModel.swift
//  TaskMaster
//
//  Created by Genki on 9/25/24.
//

import Foundation

extension IssueRow {
    @dynamicMemberLookup
    class ViewModel: ObservableObject {
        let issue: Issue
        var iconOpacity: Double {
            issue.priority == 2 ? 1 : 0
        }
        var iconIdentifier: String {
            issue.priority == 2 ? "\(issue.issueTitle) 高い優先度" : ""
        }
        var creationDate: String {
            issue.issueCreationDate.formatted(date: .numeric, time: .omitted)
        }
        init(issue: Issue) {
            self.issue = issue
        }
        subscript<Value>(dynamicMember keyPath: KeyPath<Issue, Value>) -> Value {
            issue[keyPath: keyPath]
        }
    }
}
