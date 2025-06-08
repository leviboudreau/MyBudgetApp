//
//  ContentView.swift
//  MyBudgetApp
//
//  Created by Levi Boudreau on 6/7/25.
//

import SwiftUI

enum DashboardSection: String, CaseIterable, Identifiable {
    case budget = "Budget Overview"
    case income = "Income"

    var id: String { self.rawValue }
}

struct ContentView: View {
    @State private var selection: DashboardSection? = .budget
    @StateObject private var monthModel = MonthSelectionViewModel()

    var body: some View {
        NavigationSplitView {
            List(DashboardSection.allCases, selection: $selection) { section in
                NavigationLink(value: section) {
                    Text(section.rawValue)
                }
            }
            .navigationTitle("Dashboard")
            .navigationDestination(for: DashboardSection.self) { section in
                switch section {
                case .budget:
                    BudgetDashboardView()
                case .income:
                    IncomeDashboardView(monthModel: monthModel)
                }
            }
        } detail: {
            // Optional fallback detail view
            Text("Select a section")
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    ContentView()
}


