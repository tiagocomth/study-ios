//
//  StudySessionCategoryGridView.swift
//  Study
//
//  Created by Caio Mandarino on 27/06/26.
//

import SwiftUI

struct StudySessionCategoryGridView: View {
    let categories: [StudyCategory]
    let selectedCategoryId: UUID?
    let onSelectCategory: (UUID) -> Void
    let onAddCategory: () -> Void

    var body: some View {
        ScrollView {
            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 100, maximum: 100), spacing: 50)],
                alignment: .leading,
                spacing: 50
            ) {
                ForEach(categories, id: \.categoryId) { category in
                    cardView(for: category, onSelect: onSelectCategory)
                }

                StudySessionAddCardView(action: onAddCategory)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .scrollIndicators(.hidden)
    }
}

private extension StudySessionCategoryGridView {

    func isSelected(_ category: StudyCategory) -> Bool {
        selectedCategoryId == category.categoryId
    }

    @ViewBuilder
    func cardView(for category: StudyCategory, onSelect: @escaping (UUID) -> Void) -> some View {
        if isSelected(category) {
            StudySessionSelectedCardView(categoryName: category.name)
        } else {
            StudySessionCardView(categoryName: category.name) {
                onSelectCategory(category.categoryId)
            }

        }
    }
}

#Preview {
    
    var categories = Array<StudyCategory>()

    for _ in 0...10 {
        let element = StudyCategory(
            categoryId: UUID(),
            userId: UUID(),
            name: "Português",
            createdAt: "19.10.234"
        )
        categories.append(element)
    }
    
    return StudySessionCategoryGridView(
        categories: categories,
        selectedCategoryId: nil,
        onSelectCategory: { _ in
        },
        onAddCategory: {}
    )
}
