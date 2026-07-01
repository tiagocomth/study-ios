//
//  PremiumView.swift
//  Study
//

import SwiftUI

struct PremiumView: View {
    
    @StateObject var viewModel: PremiumViewModel

    var body: some View {
        VStack(spacing: 20) {
            if viewModel.isPremium {
                VStack(spacing: 12) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.green)
                    Text("Você já é um usuário Premium!")
                        .font(.headline)
                        .foregroundColor(.green)
                }
            } else if viewModel.isLoading {
                ProgressView("Processando compra...")
            } else {
                Button("Comprar") {
                    viewModel.purchasePremium()
                }
                .buttonStyle(.borderedProminent)
            }
            
            if let errorMessage = viewModel.errorMessage {
                Text("Erro: \(errorMessage)")
                    .font(.caption)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding()
            }
        }
        .padding()
        .frame(width: 400, height: 320)
    }
}

#Preview {
    struct DummyPaymentService: PaymentProtocol {
        func loadProducts() async throws(PaymentError) -> [PaymentProduct] { [] }
        func purchase(_ identifier: ProductIdentifier, appAccountToken: UUID) async throws(PaymentError) -> PaymentPurchaseResult {
            return .success(.premiumMonthly)
        }
        func isPurchased(_ identifier: ProductIdentifier) async -> Bool { false }
        func refreshEntitlements() async {}
        func startTransactionListener(callback: @escaping PaymentEventCallback) async {}
        func stopTransactionListener() async {}
    }
    
    struct DummyPremiumWorker: PremiumWorkerProtocol {
        var isPremium: Bool = false
        func purchasePremium() async throws {}
    }
    
    let worker = DummyPremiumWorker()
    return PremiumView(viewModel: PremiumViewModel(worker: worker))
}
