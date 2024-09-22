//
//  Filter.swift
//  TaskMaster
//
//  Created by Genki on 9/22/24.
//

import Foundation

struct Filter: Identifiable, Hashable {
    var id: UUID
    var name: String
    var icon: String
    var minModificationDate = Date.distantPast
    var tag: Tag?
    static var all = Filter(id: UUID(), name: "すべてのタスク", icon: "tray")
    static var recent = Filter(id: UUID(), name: "最近のタスク", icon: "clock", minModificationDate: .now.addingTimeInterval(86400 * -7))
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    static func == (lhs: Filter, rhs: Filter) -> Bool {
        lhs.id == rhs.id
    }
}
