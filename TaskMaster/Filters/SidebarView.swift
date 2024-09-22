//
//  SidebarView.swift
//  TaskMaster
//
//  Created by Genki on 9/22/24.
//

import SwiftUI

struct SidebarView: View {
    @EnvironmentObject var dataController: DataController
    let smartFilters: [Filter] = [.all, .recent]
    @FetchRequest(sortDescriptors: [SortDescriptor(\.name)]) var tags: FetchedResults<Tag>
    @State private var tagToRename: Tag?
    @State private var renamingTag = false
    @State private var tagName = ""
    var tagFilters: [Filter] {
        tags.map { tag in
            Filter(id: tag.tagID, name: tag.tagName, icon: "tag", tag: tag)
        }
    }
    var body: some View {
        List(selection: $dataController.selectedFilter) {
            Section("フィルター") {
                ForEach(smartFilters, content: SmartFilterRow.init)
            }
            Section("タグ") {
                ForEach(tagFilters) { filter in
                    UserFilterRow(filter: filter, rename: rename, delete: delete)
                }
                .onDelete(perform: delete)
            }
        }
        .toolbar(content: SidebarViewToolbar.init)
        .alert("タグの名前を変更", isPresented: $renamingTag) {
            Button("OK", action: completeRename)
            Button("キャンセル", role: .cancel) { }
            TextField("新しい名前", text: $tagName)
        }
        .navigationTitle("フィルター")
        .navigationBarTitleDisplayMode(.inline)
    }
    func delete(_ offsets: IndexSet) {
        for offset in offsets {
            let item = tags[offset]
            dataController.delete(item)
        }
    }
    func delete(_ filter: Filter) {
        guard let tag = filter.tag else {
            return
        }
        dataController.delete(tag)
        dataController.save()
    }
    func rename(_ filter: Filter) {
        tagToRename = filter.tag
        tagName = filter.name
        renamingTag = true
    }
    func completeRename() {
        tagToRename?.name = tagName
        dataController.save()
    }
}
#Preview {
    SidebarView()
        .environmentObject(DataController.preview)
}
