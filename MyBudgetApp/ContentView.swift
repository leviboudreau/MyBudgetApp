//
//  ContentView.swift
//  MyBudgetApp
//
//  Created by Levi Boudreau on 6/7/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var monthModel = MonthSelectionViewModel()
    @StateObject private var incomeModel = IncomeViewModel()
    @StateObject private var billModel = BillViewModel()
    @StateObject private var budgetModel = BudgetViewModel()
    @StateObject private var savingModel = SavingGoalsViewModel()
    @StateObject private var debtModel = DebtViewModel()

    var body: some View {
        TabView {
            BudgetDashboardView(
                monthModel: monthModel,
                incomeModel: incomeModel,
                viewModel: budgetModel,
                billModel: billModel
            )
            .tabItem {
                Label("Budget", systemImage: "chart.bar.doc.horizontal")
            }

            IncomeDashboardView(
                monthModel: monthModel,
                viewModel: incomeModel
            )
            .tabItem {
                Label("Income", systemImage: "dollarsign.circle")
            }

            BillsDashboardView(billModel: billModel, incomeModel: incomeModel)
                .tabItem {
                    Label("Bills", systemImage: "list.bullet.rectangle")
                }

            SavingsDashboardView(viewModel: savingModel)
                .tabItem {
                    Label("Savings", systemImage: "banknote")
                }

            DebtDashboardView(viewModel: debtModel)
                .tabItem {
                    Label("Debt", systemImage: "creditcard")
                }
        }
        .onAppear {
            let filtered = billModel.bills.filter { ![.utilities, .subscription].contains($0.category) }
            budgetModel.integrateBillsAsBudgetedItems(from: filtered)
        }
    }
}
