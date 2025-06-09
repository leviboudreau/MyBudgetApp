//
//  BudgetViewModel.swift
//  MyBudgetApp
//
//  Created by Levi Boudreau on 6/7/25.
//

import SwiftUI

class BudgetViewModel: ObservableObject {
    @Published var categories: [BudgetCategory] = []

    private let storageKey = "budget_categories"

    init() {
        load()
    }

    func addCategory(name: String, amount: Double) {
        let dummySpent = Double.random(in: 0...(amount * 0.8))
        let newCategory = BudgetCategory(name: name, amount: amount, spent: dummySpent)
        categories.append(newCategory)
        save()
    }

    private func save() {
        if let encoded = try? JSONEncoder().encode(categories) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }

    private func load() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([BudgetCategory].self, from: data) {
            categories = decoded
        }
    }
    
    func updateCategory(_ updatedCategory: BudgetCategory) {
        if let index = categories.firstIndex(where: { $0.id == updatedCategory.id }) {
            categories[index] = updatedCategory
            save()
        }
    }

    func deleteCategory(at offsets: IndexSet) {
        categories.remove(atOffsets: offsets)
        save()
    }

    func deleteCategory(_ category: BudgetCategory) {
        categories.removeAll { $0.id == category.id }
        save()
    }

    func totalSpent() -> Double {
        categories.reduce(0) { $0 + $1.spent }
    }

    func autoBudgetedBills(from bills: [Bill]) -> [BudgetCategory] {
        bills
            .filter { $0.category == .subscription || $0.category == .utilities }
            .map {
                BudgetCategory(name: $0.payee, amount: $0.amount, spent: 0)
            }
    }
    
    func integrateBillsAsBudgetedItems(from bills: [Bill]) {
        let filtered = bills.filter { $0.category == .subscription || $0.category == .utilities }

        for bill in filtered {
            // Avoid duplicates by payee name
            if !categories.contains(where: { $0.name == bill.payee }) {
                let category = BudgetCategory(name: bill.payee, amount: bill.amount, spent: 0)
                categories.append(category)
            }
        }

        save() // optional: persist updates
    }

}

