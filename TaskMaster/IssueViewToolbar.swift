//
//  IssueViewToolbar.swift
//  TaskMaster
//
//  Created by Genki on 9/22/24.
//

import SwiftUI

struct IssueViewToolbar: View {
    @EnvironmentObject var dataController: DataController
    @ObservedObject var issue: Issue
    var body: some View {
        Menu {
            Button {
                UIPasteboard.general.string = issue.title
            } label: {
                Label("タスクのタイトルをコピー", systemImage: "doc.on.doc")
            }

            Button {
                issue.completed.toggle()
                dataController.save()
            } label: {
                Label(issue.completed ? "タスクを未達成にする" : "タスクを達成する", systemImage: "bubble.left.and.exclamationmark.bubble.right")
            }
            Divider()
            Section("タグ") {
                TagsMenuView(issue: issue)
            }
        } label: {
            Label("アクション", systemImage: "ellipsis.circle")
        }
    }
}

#Preview {
    IssueViewToolbar(issue: Issue.example)
}
