//
//  BudgetDashboardView.swift
//  MyBudgetApp
//
//  Created by Levi Boudreau on 6/7/25.
//

import SwiftUI

struct BudgetDashboardView: View {
    @ObservedObject var monthModel: MonthSelectionViewModel
    @ObservedObject var incomeModel: IncomeViewModel
    @ObservedObject var viewModel: BudgetViewModel
    @ObservedObject var billModel: BillViewModel

    @State private var showingAddCategory = false
    @State private var showingEditSheet = false
    @State private var showingDeleteConfirmation = false
    @State private var categoryToEdit: BudgetCategory?
    @State private var categoryToDelete: BudgetCategory?

    var totalBudgeted: Double {
        displayCategories.reduce(0) { $0 + $1.amount }
    }

    var totalSpent: Double {
        displayCategories.reduce(0) { $0 + $1.spent }
    }

    var totalIncome: Double {
        incomeModel.estimatedMonthly(for: monthModel.selectedMonth)
    }

    var availableSpend: Double {
        totalIncome - totalSpent
    }

    var funFunds: Double {
        totalIncome - totalBudgeted
    }

    var groupedBillCategories: [BudgetCategory] {
        var grouped: [String: Double] = [:]

        for bill in billModel.bills {
            if bill.category == .utilities || bill.category == .subscription {
                let key = bill.category.rawValue
                grouped[key, default: 0] += bill.amount
            }
        }

        return grouped.map { BudgetCategory(name: $0.key, amount: $0.value, spent: 0) }
    }

    var displayCategories: [BudgetCategory] {
        viewModel.categories.filter { cat in
            !["Utilities", "Subscription"].contains(cat.name)
        } + groupedBillCategories
    }

    var body: some View {
        VStack(alignment: .leading) {
            // Title & Add Button
            HStack {
                Text("Budget Overview")
                    .font(.largeTitle)
                Spacer()
                Button(action: { showingAddCategory = true }) {
                    Label("Add Category", systemImage: "plus")
                }
            }
            .padding([.top, .horizontal])

            // Month & Year Selection
            HStack(spacing: 12) {
                Text("Viewing:")
                    .bold()
                Picker("Month", selection: $monthModel.selectedMonthValue) {
                    ForEach(1...12, id: \Int.self) {
                        Text(Calendar.current.monthSymbols[$0 - 1]).tag($0)
                    }
                }
                .frame(width: 120)

                Picker("Year", selection: $monthModel.selectedYearValue) {
                    ForEach(2020...2030, id: \Int.self) {
                        Text(String($0)).tag($0)
                    }
                }
                .frame(width: 100)

                Spacer()

                Button(action: {
                    // Filtered integration to avoid duplicates with groupedBillCategories
                    _ = billModel.bills.filter { ![.utilities, .subscription].contains($0.category) }
                    // Skip integrating utility and subscription bills completely
                    viewModel.integrateBillsAsBudgetedItems(from: [])
                }) {
                    Label("Refresh Budget", systemImage: "arrow.clockwise")
                }
            }
            .padding(.horizontal)

            // Category Progress
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(displayCategories) { category in
                        BudgetProgressView(category: category)
                            .contextMenu {
                                Button("Edit") {
                                    categoryToEdit = category
                                    showingEditSheet = true
                                }
                                Button("Delete", role: .destructive) {
                                    categoryToDelete = category
                                    showingDeleteConfirmation = true
                                }
                            }
                    }
                }
                .padding(.horizontal)
            }

            Divider()

            // Summary
            VStack(spacing: 8) {
                HStack {
                    Text("Total Budgeted:").bold()
                    Spacer()
                    Text(String(format: "$%.2f", totalBudgeted)).bold()
                }
                HStack {
                    Text("Total Spent:").bold()
                    Spacer()
                    Text(String(format: "$%.2f", totalSpent)).bold()
                }
                HStack {
                    Text("Available Spend:").bold()
                    Spacer()
                    Text(String(format: "$%.2f", availableSpend)).bold()
                        .foregroundColor(availableSpend >= 0 ? .green : .red)
                }
                HStack {
                    Text("Fun Funds:").bold()
                    Spacer()
                    Text(String(format: "$%.2f", funFunds)).bold()
                        .foregroundColor(funFunds >= 0 ? .blue : .red)
                }
                HStack {
                    Text("Total Income:").bold()
                    Spacer()
                    Text(String(format: "$%.2f", totalIncome)).bold()
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .sheet(isPresented: $showingAddCategory) {
            AddCategoryView(viewModel: viewModel)
        }
        .sheet(item: $categoryToEdit) { category in
            EditCategoryView(category: category, viewModel: viewModel)
        }
        .alert("Delete Category?", isPresented: $showingDeleteConfirmation, presenting: categoryToDelete) { category in
            Button("Delete", role: .destructive) {
                viewModel.deleteCategory(category)
                categoryToDelete = nil
            }
            Button("Cancel", role: .cancel) {
                categoryToDelete = nil
            }
        } message: { category in
            Text("Are you sure you want to delete \(category.name)? This action cannot be undone.")
        }
    }
}

