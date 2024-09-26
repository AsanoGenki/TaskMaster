//
//  ContentViewToolbar.swift
//  TaskMaster
//
//  Created by Genki on 9/22/24.
//

import SwiftUI

struct ContentViewToolbar: View {
    @EnvironmentObject var dataController: DataController
    var body: some View {
        Menu {
            Button(dataController.filterEnabled ? "フィルターOFF" : "フィルターON") {
                dataController.filterEnabled.toggle()
            }
            Divider()
            Menu("並び順") {
                Picker("作成日・更新日順", selection: $dataController.sortType) {
                    Text("作成日順").tag(SortType.dateCreated)
                    Text("更新日順").tag(SortType.dateModified)
                }
                .pickerStyle(.inline)
                .labelsHidden()
                Divider()
                Picker("新しい・古い順", selection: $dataController.sortNewestFirst) {
                    Text("新しい順").tag(true)
                    Text("古い順").tag(false)
                }
                .pickerStyle(.inline)
                .labelsHidden()
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
            Label("並び替え", systemImage: "line.3.horizontal.decrease.circle")
                .symbolVariant(dataController.filterEnabled ? .fill : .none)
                .help("並び替え")
        }
        Button(action: dataController.newIssue) {
            Label("新しいタスク", systemImage: "square.and.pencil")
        }
        .help("新しいタスク")
    }
}

#Preview {
    ContentViewToolbar()
}
