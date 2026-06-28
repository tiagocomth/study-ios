//
//  StudySessionViewModel+Category.swift
//  Study
//
//  Created by Caio Mandarino on 28/06/26.
//

import Foundation

extension StudySessionViewModel {
    func selectCategory(_ categoryId: UUID) {
        selectedCategoryId = categoryId
    }

    func didTapAddCategory() {
        coordinator?.presentCreateCategory()
    }

    func isSelected(_ category: StudyCategory) -> Bool {
        selectedCategoryId == category.categoryId
    }

    func isEditing(_ category: StudyCategory) -> Bool {
        editingCategoryId == category.categoryId
    }

    func isActionMenuPresented(for category: StudyCategory) -> Bool {
        actionMenuCategoryId == category.categoryId
    }

    func setActionMenuPresented(_ isPresented: Bool, for category: StudyCategory) {
        if isPresented {
            actionMenuCategoryId = category.categoryId
            return
        }

        if actionMenuCategoryId == category.categoryId {
            actionMenuCategoryId = nil
        }
    }

    func beginEditing(_ category: StudyCategory) {
        actionMenuCategoryId = nil
        editingCategoryId = category.categoryId
        editingCategoryName = category.name
    }

    func commitEditing(for category: StudyCategory) {
        defer {
            editingCategoryId = nil
            editingCategoryName = ""
        }

        guard let validatedName = didSubmitEditCategory(id: category.categoryId, name: editingCategoryName) else {
            return
        }

        guard validatedName != category.name else { return }

        guard let index = categories.firstIndex(where: { $0.categoryId == category.categoryId }) else {
            return
        }
        
        let updatedCategory = StudyCategory(
            categoryId: category.categoryId,
            userId: category.userId,
            name: validatedName,
            createdAt: category.createdAt
        )
        
        categories[index] = updatedCategory

        do {
            _ = try worker.updateCategory(id: category.categoryId, dto: UpdateCategoryDTO(name: validatedName))
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func requestDeleteCategory(_ category: StudyCategory) {
        actionMenuCategoryId = nil
        categoryPendingDeletion = category
    }

    func dismissDeleteCategory() {
        categoryPendingDeletion = nil
    }
    
    func dismissEdit() {
        editingCategoryId = nil
        editingCategoryName = ""
    }

    func confirmDeletePendingCategory() {
        guard let categoryPendingDeletion else { return }

        self.categoryPendingDeletion = nil
        didConfirmDeleteCategory(id: categoryPendingDeletion.categoryId)
    }

    func loadCategories() {
        do {
            let categories = try worker.loadCategories { [weak self] refreshedCategories in
                self?.handleCategoryUpdate(refreshedCategories)
            }
            handleCategoryUpdate(categories)
        } catch {
            errorMessage = error.localizedDescription
            viewState = .error
        }
    }

    func syncSelectedCategory(with session: LocalStudySession?) {
        guard
            let session,
            categories.contains(where: { $0.categoryId == session.categoryId })
        else {
            return
        }

        selectedCategoryId = session.categoryId
    }

    func didSubmitEditCategory(id: UUID, name: String) -> String? {
        let validatedName: String

        do {
            validatedName = try worker.validateCategoryName(name)
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }

        // TODO: integrar edicao real da categoria.
        _ = id
        return validatedName
    }

    func didConfirmDeleteCategory(id: UUID) {
        let previousCategories = categories

        categories.removeAll { $0.categoryId == id }

        if selectedCategoryId == id {
            selectedCategoryId = nil
        }

        do {
            try worker.deleteCategory(id: id)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func handleCategoryUpdate(_ categories: [StudyCategory]) {
        self.categories = categories
        errorMessage = nil
        let validCategoryIds = Set(categories.map(\.categoryId))

        if let selectedCategoryId,
           validCategoryIds.contains(selectedCategoryId) == false {
            self.selectedCategoryId = nil
        }

        if let actionMenuCategoryId,
           validCategoryIds.contains(actionMenuCategoryId) == false {
            self.actionMenuCategoryId = nil
        }

        if let editingCategoryId,
           validCategoryIds.contains(editingCategoryId) == false {
            self.editingCategoryId = nil
            self.editingCategoryName = ""
        }

        if let categoryPendingDeletion,
           validCategoryIds.contains(categoryPendingDeletion.categoryId) == false {
            self.categoryPendingDeletion = nil
        }

        syncSelectedCategory(with: activeSession)

        if categories.isEmpty {
            viewState = .empty
        } else {
            viewState = .content
        }
    }
}
