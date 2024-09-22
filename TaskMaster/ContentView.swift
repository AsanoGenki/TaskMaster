//
//  ContentView.swift
//  TaskMaster
//
//  Created by Genki on 9/22/24.
//

import SwiftUI

struct ContentView: View {    
    @EnvironmentObject var dataController: DataController
    
    var body: some View {
        List(selection: $dataController.selectedIssue) {
            ForEach(dataController.issuesForSelectedFilter()) { issue in
                IssueRow(issue: issue)
            }
            .onDelete(perform: delete)
        }
        .navigationTitle("タスク")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $dataController.filterText, tokens: $dataController.filterTokens, suggestedTokens: .constant(dataController.suggestedFilterTokens), prompt: "検索") { tag in
            Text(tag.tagName)
        }
        .toolbar {
            Menu {
                Button(dataController.filterEnabled ? "フィルターOFF" : "フィルターON") {
                    dataController.filterEnabled.toggle()
                }

                Divider()

                Menu("並び順") {
                    Picker("Sort By", selection: $dataController.sortType) {
                        Text("作成日順").tag(SortType.dateCreated)
                        Text("更新日順").tag(SortType.dateModified)
                    }

                    Divider()

                    Picker("Sort Order", selection: $dataController.sortNewestFirst) {
                        Text("新しい順").tag(true)
                        Text("古い順").tag(false)
                    }
                }

                Picker("ステータス", selection: $dataController.filterStatus) {
                    Text("すべて").tag(Status.all)
                    Text("未達成").tag(Status.open)
                    Text("完了済み").tag(Status.closed)
                }
                .disabled(dataController.filterEnabled == false)
                
                Picker("優先度", selection: $dataController.filterPriority) {
                    Text("すべて").tag(-1)
                    Text("低").tag(0)
                    Text("中").tag(1)
                    Text("高").tag(2)
                }
            } label: {
                Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                    .symbolVariant(dataController.filterEnabled ? .fill : .none)
            }
        }
    }
    
    func delete(_ offsets: IndexSet) {
        let issues = dataController.issuesForSelectedFilter()
        
        for offset in offsets {
            let item = issues[offset]
            dataController.delete(item)
        }
    }
    
}

#Preview {
    ContentView()
}
