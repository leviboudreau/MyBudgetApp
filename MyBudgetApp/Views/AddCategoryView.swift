//
//  AddCategoryView.swift
//  MyBudgetApp
//
//  Created by Levi Boudreau on 6/7/25.
//

import SwiftUI

struct AddCategoryView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: BudgetViewModel

    @State private var name = ""
    @State private var amount = ""

    var body: some View {
        NavigationView {
            Form {
                TextField("Category Name", text: $name)
                TextField("Budget Amount", text: $amount)
            }
            .navigationTitle("Add Category")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if let amountValue = Double(amount) {
                            viewModel.addCategory(name: name, amount: amountValue)
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
