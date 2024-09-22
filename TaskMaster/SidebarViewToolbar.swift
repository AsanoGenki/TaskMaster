//
//  SidebarViewToolbar.swift
//  TaskMaster
//
//  Created by Genki on 9/22/24.
//

import SwiftUI

struct SidebarViewToolbar: View {
    @EnvironmentObject var dataController: DataController
    @State private var showingAwards = false
    
    var body: some View {
        Button(action: dataController.newTag) {
            Label("タグを追加", systemImage: "plus")
        }
        
        Button {
            showingAwards.toggle()
        } label: {
            Label("称号の表示", systemImage: "rosette")
        }
        .sheet(isPresented: $showingAwards, content: AwardsView.init)
        
        #if DEBUG
        Button {
            dataController.deleteAll()
            dataController.createSampleData()
        } label: {
            Label("サンプルを追加", systemImage: "flame")
        }
        #endif
    }
}

#Preview {
    SidebarViewToolbar()
}
