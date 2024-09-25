//
//  ContentView.swift
//  TaskMaster
//
//  Created by Genki on 9/22/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel: ViewModel
    var body: some View {
        List(selection: $viewModel.selectedIssue) {
            ForEach(viewModel.dataController.issuesForSelectedFilter()) { issue in
                IssueRow(issue: issue)
            }
            .onDelete(perform: viewModel.delete)
        }
        .navigationTitle("タスク")
        .searchable(text: $viewModel.filterText, tokens: $viewModel.filterTokens, suggestedTokens: .constant(viewModel.suggestedFilterTokens), prompt: "検索") { tag in
            Text(tag.tagName)
        }
        .toolbar(content: ContentViewToolbar.init)
    }
    init(dataController: DataController) {
        let viewModel = ViewModel(dataController: dataController)
        _viewModel = StateObject(wrappedValue: viewModel)
    }
}

#Preview {
    ContentView(dataController: .preview)
}
