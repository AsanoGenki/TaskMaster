//
//  IssueView.swift
//  TaskMaster
//
//  Created by Genki on 9/22/24.
//

import SwiftUI

struct IssueView: View {
    @ObservedObject var issue: Issue
    @EnvironmentObject var dataController: DataController
    
    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading) {
                    TextField("タイトル", text: $issue.issueTitle, prompt: Text("タイトル"))
                        .font(.title)

                    Text("**更新日:** \(issue.issueModificationDate.formatted(date: .long, time: .shortened))")
                        .foregroundStyle(.secondary)
                    
                    Text("**ステータス:** \(issue.issueStatus)")
                        .foregroundStyle(.secondary)

                }

                Picker("優先度", selection: $issue.issuePriority) {
                    Text("低").tag(0)
                    Text("中").tag(1)
                    Text("高").tag(2)
                }
                
               TagsMenuView(issue: issue)
            }
            Section {
                VStack(alignment: .leading) {
                    Text("説明文")
                        .font(.title2)
                        .foregroundStyle(.secondary)

                    TextField("説明", text: $issue.issueContent, prompt: Text("タスクの説明をここに記入..."), axis: .vertical)
                }
            }
        }
        .disabled(issue.isDeleted)
        .onReceive(issue.objectWillChange) { _ in
            dataController.queueSave()
        }
        .onSubmit(dataController.save)
        .toolbar {
            IssueViewToolbar(issue: issue)
        }
    }
}

#Preview {
    IssueView(issue: .example)
}
