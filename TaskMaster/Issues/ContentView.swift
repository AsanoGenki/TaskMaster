//
//  ContentView.swift
//  TaskMaster
//
//  Created by Genki on 9/22/24.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.requestReview) var requestReview
    @StateObject var viewModel: ViewModel
    private let newIssueActivity = "com.asanogenki.TaskMaster.newIssue"
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
        .onAppear(perform: askForReview)
        .onOpenURL(perform: openURL)
        .userActivity(newIssueActivity) { activity in
            activity.isEligibleForPrediction = true
            activity.title = "新しいタスク"
        }
        .onContinueUserActivity(newIssueActivity, perform: resumeActivity)
    }
    init(dataController: DataController) {
        let viewModel = ViewModel(dataController: dataController)
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    func askForReview() {
        if viewModel.shouldRequestReview {
            requestReview()
        }
    }
    func openURL(_ url: URL) {
        if url.absoluteString.contains("newIssue") {
            viewModel.dataController.newIssue()
        }
    }
    func resumeActivity(_ userActivity: NSUserActivity) {
        viewModel.dataController.newIssue()
    }
}

#Preview {
    ContentView(dataController: .preview)
}
