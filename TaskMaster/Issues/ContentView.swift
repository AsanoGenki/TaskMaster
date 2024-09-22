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
        .toolbar(content: ContentViewToolbar.init)
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
