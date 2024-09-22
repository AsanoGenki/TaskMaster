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
                
                Menu {
                    ForEach(issue.issueTags) { tag in
                        Button {
                            issue.removeFromTags(tag)
                        } label: {
                            Label(tag.tagName, systemImage: "checkmark")
                        }
                    }

                    let otherTags = dataController.missingTags(from: issue)

                    if otherTags.isEmpty == false {
                        Divider()

                        Section("タグを追加") {
                            ForEach(otherTags) { tag in
                                Button(tag.tagName) {
                                    issue.addToTags(tag)
                                }
                            }
                        }
                    }
                } label: {
                    Text(issue.issueTagsList)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .animation(nil, value: issue.issueTagsList)
                }
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
            } label: {
                Label("アクション", systemImage: "ellipsis.circle")
            }
        }
    }
}

#Preview {
    IssueView(issue: .example)
}
