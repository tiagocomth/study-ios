//
//  PremiumView.swift
//  Study
//

import SwiftUI

struct PremiumView: View {
    
    @StateObject var viewModel: PremiumViewModel

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Spacer()
                Button(action: { viewModel.dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            
            Image(systemName: "crown.fill")
                .font(.system(size: 60))
                .foregroundColor(.yellow)
            
            Text("Estude sem limites com a Versão Premium!")
                .font(.title2)
                .bold()
                .multilineTextAlignment(.center)
            
            Text("Tenha acesso a estatísticas detalhadas, sessões ilimitadas de estudo e muito mais.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Assinar Agora") {
                // Ação de assinatura
            }
            .buttonStyle(.borderedProminent)
            .tint(.yellow)
            .foregroundColor(.black)
            .padding(.top, 10)
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
    
    let worker = PremiumWorker(
        paymentService: DummyPaymentService(),
        userSession: UserSessionService()
    )
    return PremiumView(viewModel: PremiumViewModel(worker: worker))
}
