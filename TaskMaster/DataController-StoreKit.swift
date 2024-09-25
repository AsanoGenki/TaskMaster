//
//  DataController-StoreKit.swift
//  TaskMaster
//
//  Created by Genki on 9/25/24.
//

import Foundation
import StoreKit

extension DataController {
    static let unlockPremiumProductID = "com.asanogenki.TaskMaster.premiumUnlock"
    var fullVersionUnlocked: Bool {
        get {
            UserDefaults.standard.bool(forKey: "fullVersionUnlocked")
        }

        set {
            UserDefaults.standard.set(newValue, forKey: "fullVersionUnlocked")
        }
    }
    func monitorTransactions() async {
        // 以前の購入を確認
        for await entitlement in Transaction.currentEntitlements {
            if case let .verified(transaction) = entitlement {
                await finalize(transaction)
            }
        }
        // 今後発生する取引を監視
        for await update in Transaction.updates {
            if let transaction = try? update.payloadValue {
                await finalize(transaction)
            }
        }
    }
    func purchase(_ product: Product) async throws {
        let result = try await product.purchase()
        if case let .success(validation) = result {
            try await finalize(validation.payloadValue)
        }
    }
    @MainActor
    func finalize(_ transaction: Transaction) async {
        if transaction.productID == Self.unlockPremiumProductID {
            objectWillChange.send()
            fullVersionUnlocked = transaction.revocationDate == nil
            await transaction.finish()
        }
    }
    @MainActor
    func loadProducts() async throws {
        // 製品を複数回読み込まないようにする
        guard products.isEmpty else { return }
        try await Task.sleep(for: .seconds(0.2))
        products = try await Product.products(for: [Self.unlockPremiumProductID])
    }
}
