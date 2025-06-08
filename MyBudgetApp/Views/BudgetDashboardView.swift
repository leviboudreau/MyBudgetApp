//
//  BudgetDashboardView.swift
//  MyBudgetApp
//
//  Created by Levi Boudreau on 6/7/25.
//

import SwiftUI

struct BudgetDashboardView: View {
    @StateObject private var viewModel = BudgetViewModel()
    @State private var showingAddCategory = false
    @State private var categoryToEdit: BudgetCategory?

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Budget Dashboard")
                    .font(.largeTitle)
                Spacer()
                Button(action: { showingAddCategory = true }) {
                    Label("Add Category", systemImage: "plus")
                }
            }
            .padding([.top, .horizontal])

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(viewModel.categories) { category in
                        BudgetProgressView(category: category)
                            .contextMenu {
                                Button("Edit") {
                                    categoryToEdit = category
                                }
                                Button("Delete", role: .destructive) {
                                    viewModel.deleteCategory(category)
                                }
                            }
                    }
                }
                .padding()
            }
        }
        .sheet(item: $categoryToEdit) { category in
            EditCategoryView(category: category, viewModel: viewModel)
        }
        .sheet(isPresented: $showingAddCategory) {
            AddCategoryView(viewModel: viewModel)
        }
    }
}

