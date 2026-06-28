//
//  StudySessionCategoryGridView.swift
//  Study
//
//  Created by Caio Mandarino on 27/06/26.
//

import SwiftUI

struct StudySessionCategoryGridView: View {
    @ObservedObject var viewModel: StudySessionViewModel

    var body: some View {
        ScrollView {
            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 100, maximum: 100), spacing: 50)],
                alignment: .leading,
                spacing: 50
            ) {
                ForEach(viewModel.categories, id: \.categoryId) { category in
                    cardView(for: category)
                }
                
                StudySessionAddCardView(action: viewModel.didTapAddCategory)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .scrollIndicators(.hidden)
    }
}

private extension StudySessionCategoryGridView {
    func cardView(for category: StudyCategory) -> some View {
        VStack {
            StudySessionCategoryCardView(
                isActionMenuPresented: Binding(
                    get: { viewModel.isActionMenuPresented(for: category) },
                    set: { viewModel.setActionMenuPresented($0, for: category) }
                ),
                editingName: $viewModel.editingCategoryName,
                categoryName: category.name,
                isSelected: viewModel.isSelected(category),
                isEditing: viewModel.isEditing(category),
                onSelect: { viewModel.selectCategory(category.categoryId) },
                onEdit: { viewModel.beginEditing(category) },
                onDelete: { viewModel.requestDeleteCategory(category) },
                onSubmitEditing: { viewModel.commitEditing(for: category) }
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
    }
}
