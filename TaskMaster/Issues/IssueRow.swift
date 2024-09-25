//
//  IssueRow.swift
//  TaskMaster
//
//  Created by Genki on 9/22/24.
//

import SwiftUI

struct IssueRow: View {
    @EnvironmentObject var dataController: DataController
    @StateObject var viewModel: ViewModel
    var body: some View {
        NavigationLink(value: viewModel.issue) {
            HStack {
                Image(systemName: "exclamationmark.circle")
                    .imageScale(.large)
                    .opacity(viewModel.iconOpacity)
                    .accessibilityIdentifier(viewModel.iconIdentifier)
                VStack(alignment: .leading) {
                    Text(viewModel.issueTitle)
                        .font(.headline)
                        .lineLimit(1)
                    Text(viewModel.issueTagsList)
                        .font(.subheadline)
                        .lineLimit(1)
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text(viewModel.creationDate)
                        .font(.subheadline)
                    if viewModel.completed {
                        Text("完了済み")
                            .font(.body.smallCaps())
                    }
                }
                .foregroundStyle(.secondary)
            }
        }
        .accessibilityIdentifier(viewModel.issueTitle)
    }
    init(issue: Issue) {
        let viewModel = ViewModel(issue: issue)
        _viewModel = StateObject(wrappedValue: viewModel)
    }
}

#Preview {
    IssueRow(issue: .example)
}
