//
//  AwardsView.swift
//  TaskMaster
//
//  Created by Genki on 9/22/24.
//

import SwiftUI

struct AwardsView: View {
    @EnvironmentObject var dataController: DataController
    @Environment(\.dismiss) var dismiss
    @State private var selectedAward = Award.example
    @State private var showingAwardDetails = false
    var columns: [GridItem] {
        [GridItem(.adaptive(minimum: 100, maximum: 100))]
    }
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(Award.allAwards) { award in
                        Button {
                            selectedAward = award
                            showingAwardDetails = true
                        } label: {
                            Image(systemName: award.image)
                                .resizable()
                                .scaledToFit()
                                .padding()
                                .frame(width: 100, height: 100)
                                .foregroundColor(color(for: award))
                        }
                        .buttonStyle(.borderless)
                    }
                }
            }
            .navigationTitle("称号")
            .toolbar {
                Button("閉じる") {
                    dismiss()
                }
            }
        }
        .macFrame(minWidth: 600, minHeight: 500)
        .alert(awardTitle, isPresented: $showingAwardDetails) {
        } message: {
            Text(selectedAward.description)
        }
    }
    var awardTitle: String {
        if dataController.hasEarned(award: selectedAward) {
            return "獲得済み: \(selectedAward.name)"
        } else {
            return "未獲得"
        }
    }
    func color(for award: Award) -> Color {
        dataController.hasEarned(award: award) ? Color(award.color) : .secondary.opacity(0.5)
    }
}

#Preview {
    AwardsView()
        .environmentObject(DataController(inMemory: true))
}
