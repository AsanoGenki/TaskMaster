//
//  StoreView.swift
//  TaskMaster
//
//  Created by Genki on 9/25/24.
//

import StoreKit
import SwiftUI

struct StoreView: View {
    enum LoadState {
        case loading, loaded, error
    }
    @EnvironmentObject var dataController: DataController
    @Environment(\.dismiss) var dismiss
    @State private var loadState = LoadState.loading
    @State private var showingPurchaseError = false
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // ヘッダー
                VStack {
                    Image(decorative: "unlock")
                        .resizable()
                        .scaledToFit()
                    Text("プレミアムプランにアップグレード")
                        .font(.title.bold())
                        .fontDesign(.rounded)
                        .foregroundStyle(.white)
                    Text("アプリを制限なしで楽しみましょう！")
                        .font(.headline)
                        .foregroundStyle(.white)
                }
                .frame(maxWidth: .infinity)
                .padding(20)
                .background(.blue.gradient)
                ScrollView {
                    VStack {
                        switch loadState {
                        case .loading:
                            Text("ロード中...")
                                .font(.title2.bold())
                                .padding(.top, 50)
                            ProgressView()
                                .controlSize(.large)
                        case .loaded:
                            ForEach(dataController.products) { product in
                                Button {
                                    purchase(product)
                                } label: {
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text(product.displayName)
                                                .font(.title2.bold())
                                            Text(product.description)
                                        }
                                        
                                        Spacer()
                                        
                                        Text(product.displayPrice)
                                            .font(.title)
                                            .fontDesign(.rounded)
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
                                    .frame(maxWidth: .infinity)
                                    .background(.gray.opacity(0.2), in: .rect(cornerRadius: 20))
                                    .contentShape(.rect)
                                }
                                .buttonStyle(.plain)
                            }
                        case .error:
                            Text("申し訳ございません、商品の読み込み中にエラーが発生しました。")
                                .padding(.top, 50)
                            Button("再度試す") {
                                Task {
                                    await load()
                                }
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                    .padding(20)
                }
                // フッター
                Button("復元", action: restore)
                Button("キャンセル") {
                    dismiss()
                }
                .padding(.top, 20)
            }
        }
        .onChange(of: dataController.fullVersionUnlocked) {
            checkForPurchase()
        }
        .task {
            await load()
        }
        .alert("アプリ内購入は無効です", isPresented: $showingPurchaseError) {
        } message: {
            Text("""
            このデバイスではアプリ内購入が無効になっているため、プレミアムロック解除を購入することはできません。
            
            デバイスを管理している方にサポートを依頼してください。
            """)
        }
    }
    func checkForPurchase() {
        if dataController.fullVersionUnlocked {
            dismiss()
        }
    }
    func purchase(_ product: Product) {
        guard AppStore.canMakePayments else {
            showingPurchaseError.toggle()
            return
        }
        Task { @MainActor in
            try await dataController.purchase(product)
        }
    }
    func load() async {
        loadState = .loading
        do {
            try await dataController.loadProducts()
            if dataController.products.isEmpty {
                loadState = .error
            } else {
                loadState = .loaded
            }
        } catch {
            loadState = .error
        }
    }
    func restore() {
        Task {
            try await AppStore.sync()
        }
    }
}

#Preview {
    StoreView()
}
