//
//  IncomeDashboardView.swift
//  MyBudgetApp
//
//  Created by Levi Boudreau on 6/7/25.
//

import SwiftUI
import Charts

struct IncomeDashboardView: View {
    @ObservedObject var monthModel: MonthSelectionViewModel
    @ObservedObject var viewModel: IncomeViewModel
    @State private var showingAddSheet = false
    @State private var entryToEdit: IncomeEntry?
    @State private var entryToDelete: IncomeEntry?
    @State private var showingDeleteConfirmation = false

    struct IncomeShare: Identifiable {
        let id = UUID()
        let person: String
        let value: Double
        let percentage: Double
    }

    var incomeShares: [IncomeShare] {
        let total = viewModel.monthlyIncome(for: monthModel.selectedMonth)
        guard total > 0 else { return [] }

        return viewModel.entries.map {
            let share = viewModel.monthlyIncome(for: monthModel.selectedMonth, entry: $0)
            return IncomeShare(
                person: $0.personName,
                value: share,
                percentage: (share / total * 100)
            )
        }
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Income Overview")
                    .font(.largeTitle)
                Spacer()
                Button(action: { showingAddSheet = true }) {
                    Label("Add Income", systemImage: "plus")
                }
            }
            .padding([.top, .horizontal])

            HStack(spacing: 16) {
                Text("Selected Month:")

                Picker("Month", selection: $monthModel.selectedMonthValue) {
                    ForEach(1...12, id: \Int.self) { month in
                        Text(Calendar.current.monthSymbols[month - 1]).tag(month)
                    }
                }
                .labelsHidden()
                .frame(width: 120)

                Picker("Year", selection: $monthModel.selectedYearValue) {
                    ForEach(2020...Calendar.current.component(.year, from: Date()) + 5, id: \Int.self) { year in
                        Text(String(year)).tag(year)
                    }
                }
                .labelsHidden()
                .frame(width: 80)

                Spacer()
            }
            .padding([.horizontal, .bottom])

            if !incomeShares.isEmpty {
                Text("Monthly Income Distribution — \(monthModel.selectedMonth.formatted(.dateTime.year().month(.wide)))")
                    .font(.title2)
                    .padding(.horizontal)

                Chart(incomeShares) { share in
                    SectorMark(
                        angle: .value("Income", share.value),
                        innerRadius: .ratio(0.5),
                        angularInset: 1.5
                    )
                    .foregroundStyle(by: .value("Person", share.person))
                    .annotation(position: .overlay) {
                        VStack {
                            Text(share.person)
                            Text("\(String(format: "%.0f%%", share.percentage))")
                        }
                        .font(.caption)
                        .multilineTextAlignment(.center)
                    }
                }
                .frame(height: 300)
                .padding()
            } else {
                Text("No income data available.")
                    .foregroundColor(.secondary)
                    .padding()
            }

            Divider()

            List {
                ForEach(viewModel.entries) { entry in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(entry.personName)
                                .font(.headline)
                            Text("\(entry.frequency.rawValue): \(String(format: "$%.2f", entry.amount))")
                            Text("Estimated Monthly: \(String(format: "$%.2f", viewModel.monthlyIncome(for: monthModel.selectedMonth, entry: entry)))")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        HStack(spacing: 12) {
                            Button {
                                entryToEdit = entry
                            } label: {
                                Image(systemName: "pencil")
                            }
                            .help("Edit")

                            Button(role: .destructive) {
                                entryToDelete = entry
                                showingDeleteConfirmation = true
                            } label: {
                                Image(systemName: "trash")
                            }
                            .help("Delete")
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .padding([.horizontal, .bottom])

            Divider()

            HStack {
                Text("Total Estimated Monthly Income:")
                    .bold()
                Spacer()
                Text(String(format: "$%.2f", viewModel.monthlyIncome(for: monthModel.selectedMonth)))
                    .bold()
            }
            .padding()
        }
        .sheet(isPresented: $showingAddSheet) {
            AddIncomeView(viewModel: viewModel)
        }
        .sheet(item: $entryToEdit) { entry in
            EditIncomeView(entry: entry, viewModel: viewModel)
        }
        .alert("Delete Income Entry?", isPresented: $showingDeleteConfirmation, presenting: entryToDelete) { entry in
            Button("Delete", role: .destructive) {
                viewModel.deleteEntry(entry)
                entryToDelete = nil
            }
            Button("Cancel", role: .cancel) {
                entryToDelete = nil
            }
        } message: { entry in
            Text("Are you sure you want to delete income for \(entry.personName)? This action cannot be undone.")
        }
    }
}
