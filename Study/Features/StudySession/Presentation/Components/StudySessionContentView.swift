//
//  StudySessionContentView.swift
//  Study
//
//  Created by Caio Mandarino on 27/06/26.
//

import SwiftUI

struct StudySessionContentView: View {
    @ObservedObject var viewModel: StudySessionViewModel
    
    var body: some View {
        switch viewModel.viewState {
        case .loading:
            StudySessionLoadingView()
        case .empty:
            StudySessionEmptyView(onAddCategory: viewModel.didTapAddCategory)
        case .content:
            StudySessionCategoryGridView(viewModel: viewModel)
        case .error:
            StudySessionErrorView(errorMessage: viewModel.errorMessage)
        }
    }
}
