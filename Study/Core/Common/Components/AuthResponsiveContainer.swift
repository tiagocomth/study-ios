//
//  AuthResponsiveContainer.swift
//  Study
//

import SwiftUI

struct AuthResponsiveContainer<Content: View>: View {
    let title: String
    let subtitle: String?
    var isHeaderCentered: Bool = false
    var onBack: (() -> Void)? = nil
    @ViewBuilder let content: () -> Content

    var body: some View {
        GeometryReader { geometry in
            let isCompact = geometry.size.width < 650

            HStack(spacing: 0) {
                // MARK: Left Column
                if !isCompact {
                    Image("login")
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width * 0.60)
                        .clipped()

                    Divider()
                }

                // MARK: Right Column
                VStack(spacing: 0) {
                    // Custom Back Button
                    if let onBack = onBack {
                        HStack {
                            Button {
                                onBack()
                            } label: {
                                Image(systemName: "chevron.left")
                                    .font(.title2.bold())
                                    .foregroundStyle(.primary)
                            }
                            .buttonStyle(.plain)

                            Spacer()
                        }
                        .padding(.horizontal, isCompact ? 24 : 60)
                        .padding(.top, isCompact ? 20 : 40)
                    }

                    if isCompact {
                        ScrollView {
                            VStack(spacing: 30) {
                                headerBlock
                                content()
                            }
                            .frame(maxWidth: 420)
                            .padding(.bottom, 40)
                            .padding(.horizontal, 24)
                        }
                        .scrollIndicators(.hidden)
                    } else {
                        Spacer()

                        VStack(spacing: 30) {
                            headerBlock
                            content()
                        }
                        .frame(maxWidth: 420)
                        .padding(.horizontal, 60)
                        .padding(.bottom, 60)

                        Spacer()
                    }
                }
                .frame(width: isCompact ? geometry.size.width : geometry.size.width * 0.40)
            }
            .background(Color.adaptiveBackground)
            .navigationBarBackButtonHidden(onBack != nil)
        }
    }

    private var headerBlock: some View {
        VStack(alignment: isHeaderCentered ? .center : .leading, spacing: isHeaderCentered ? 30 : 10) {
            Text(title)
                .font(.largeTitle.bold())
                .multilineTextAlignment(isHeaderCentered ? .center : .leading)
                .foregroundStyle(.primary)

            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: isHeaderCentered ? .center : .leading)
    }
}
