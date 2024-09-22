//
//  NoIssueView.swift
//  TaskMaster
//
//  Created by Genki on 9/22/24.
//

import SwiftUI

struct NoIssueView: View {
    @EnvironmentObject var dataController: DataController

    var body: some View {
        Text("選択した未達成のタスク")
            .font(.title)
            .foregroundStyle(.secondary)

        Button("新しいタスク") {
            // make a new issue
        }
    }
}

#Preview {
    NoIssueView()
}
