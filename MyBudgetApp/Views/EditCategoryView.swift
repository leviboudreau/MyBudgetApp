//
//  EditCategoryView.swift
//  MyBudgetApp
//
//  Created by Levi Boudreau on 6/7/25.
//

import SwiftUI

struct EditCategoryView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: BudgetViewModel

    @State private var name: String
    @State private var amount: String

    var category: BudgetCategory

    init(category: BudgetCategory, viewModel: BudgetViewModel) {
        self.category = category
        self.viewModel = viewModel
        _name = State(initialValue: category.name)
        _amount = State(initialValue: String(category.amount))
    }

    var body: some View {
        NavigationView {
            Form {
                TextField("Category Name", text: $name)
                TextField("Budget Amount", text: $amount)
            }
            .navigationTitle("Edit Category")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if let newAmount = Double(amount) {
                            let updated = BudgetCategory(id: category.id, name: name, amount: newAmount)
                            viewModel.updateCategory(updated)
                            dismiss()
                        }
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: { dismiss() })
                }
            }
        }
    }
}
