//
//  SidebarView.swift
//  TaskMaster
//
//  Created by Genki on 9/22/24.
//

import SwiftUI

struct SidebarView: View {
    @StateObject private var viewModel: ViewModel
    let smartFilters: [Filter] = [.all, .recent]
    init(dataController: DataController) {
        let viewModel = ViewModel(dataController: dataController)
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    var body: some View {
        List(selection: $viewModel.dataController.selectedFilter) {
            Section("フィルター") {
                ForEach(smartFilters, content: SmartFilterRow.init)
            }
            Section("タグ") {
                ForEach(viewModel.tagFilters) { filter in
                    UserFilterRow(filter: filter, rename: viewModel.rename, delete: viewModel.delete)
                }
                .onDelete(perform: viewModel.delete)
            }
        }
        .toolbar(content: SidebarViewToolbar.init)
        .alert("タグの名前を変更", isPresented: $viewModel.renamingTag) {
            Button("OK", action: viewModel.completeRename)
            Button("キャンセル", role: .cancel) { }
            TextField("新しい名前", text: $viewModel.tagName)
        }
        .navigationTitle("フィルター")
    }
}
#Preview {
    SidebarView(dataController: .preview)
}
