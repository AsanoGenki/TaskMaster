//
//  TaskMasterApp.swift
//  TaskMaster
//
//  Created by Genki on 9/22/24.
//

import SwiftUI

@main
struct TaskMasterApp: App {
    @StateObject var dataController = DataController()
    var body: some Scene {
        WindowGroup {
            NavigationSplitView {
                SidebarView()
            } content: {
                ContentView()
            } detail: {
                DetailView()
            }
                .environment(\.managedObjectContext, dataController.container.viewContext)
                .environmentObject(dataController)
        }
    }
}
