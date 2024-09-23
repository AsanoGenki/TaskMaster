//
//  IssueRow.swift
//  TaskMaster
//
//  Created by Genki on 9/22/24.
//

import SwiftUI

struct IssueRow: View {
    @EnvironmentObject var dataController: DataController
    @ObservedObject var issue: Issue
    var body: some View {
        NavigationLink(value: issue) {
            HStack {
                Image(systemName: "exclamationmark.circle")
                    .imageScale(.large)
                    .opacity(issue.priority == 2 ? 1 : 0)
                    .accessibilityIdentifier(issue.priority == 2 ? "\(issue.issueTitle) 高い優先度" : "")
                VStack(alignment: .leading) {
                    Text(issue.issueTitle)
                        .font(.headline)
                        .lineLimit(1)
                    Text(issue.issueTagsList)
                        .font(.subheadline)
                        .lineLimit(1)
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text(issue.issueCreationDate.formatted(date: .numeric, time: .omitted))
                        .font(.subheadline)

                    if issue.completed {
                        Text("完了済み")
                            .font(.body.smallCaps())
                    }
                }
                .foregroundStyle(.secondary)
            }
        }
        .accessibilityIdentifier(issue.issueTitle)
    }
}

#Preview {
    IssueRow(issue: .example)
}
