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
        Text("タスクがありません")
            .font(.title)
            .foregroundStyle(.secondary)
        Button("新しいタスク", action: dataController.newIssue)
    }
}

#Preview {
    NoIssueView()
        .environmentObject(DataController(inMemory: true))

}
