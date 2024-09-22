//
//  UserFilterRow.swift
//  TaskMaster
//
//  Created by Genki on 9/22/24.
//

import SwiftUI

struct UserFilterRow: View {
    var filter: Filter
    var rename: (Filter) -> Void
    var delete: (Filter) -> Void
    var body: some View {
        NavigationLink(value: filter) {
            Label(filter.name, systemImage: filter.icon)
                .badge(filter.tag?.tagActiveIssues.count ?? 0)
                .contextMenu {
                    Button {
                        rename(filter)
                    } label: {
                        Label("名前を変更", systemImage: "pencil")
                    }
                    Button(role: .destructive) {
                        delete(filter)
                    } label: {
                        Label("削除", systemImage: "trash")
                    }
                }
        }
    }
}

#Preview {
    UserFilterRow(filter: .all, rename: { _ in }, delete: { _ in })
}
