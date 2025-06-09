//
//  DebtDashboardView.swift
//  MyBudgetApp
//
//  Created by Levi Boudreau on 6/8/25.
//

import SwiftUI
import Charts

class DebtViewModel: ObservableObject {
    @Published var debts: [Debt] = []
    private let storageKey = "debts_storage"

    init() {
        load()
    }

    func addDebt(_ debt: Debt) {
        debts.append(debt)
        save()
    }

    func updateDebt(_ updated: Debt) {
        if let index = debts.firstIndex(where: { $0.id == updated.id }) {
            debts[index] = updated
            save()
        }
    }

    func deleteDebt(_ debt: Debt) {
        debts.removeAll { $0.id == debt.id }
        save()
    }

    private func save() {
        if let encoded = try? JSONEncoder().encode(debts) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }

    private func load() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([Debt].self, from: data) {
            debts = decoded
        }
    }
}

struct DebtDashboardView: View {
    @ObservedObject var viewModel: DebtViewModel
    @State private var showingAddSheet = false
    @State private var debtToEdit: Debt?
    @StateObject private var incomeModel = IncomeViewModel()

    func personName(for id: UUID) -> String {
        incomeModel.entries.first(where: { $0.id == id })?.personName ?? "Unknown"
    }

    struct PersonDebtSummary: Identifiable {
        let id = UUID()
        let name: String
        let totalDebt: Double
        let totalCredit: Double
        var utilization: Double {
            totalCredit > 0 ? totalDebt / totalCredit : 0
        }
    }

    var debtSummaries: [PersonDebtSummary] {
        let grouped = Dictionary(grouping: viewModel.debts, by: { $0.personId })
        return grouped.compactMap { (id, debts) in
            guard let name = incomeModel.entries.first(where: { $0.id == id })?.personName else { return nil }
            let totalDebt = debts.map(\.debtAmount).reduce(0, +)
            let totalCredit = debts.map(\.lineOfCredit).reduce(0, +)
            return PersonDebtSummary(name: name, totalDebt: totalDebt, totalCredit: totalCredit)
        }
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Debt Collector")
                    .font(.largeTitle)
                Spacer()
                Button {
                    showingAddSheet = true
                } label: {
                    Label("Add Debt", systemImage: "plus")
                }
            }
            .padding()

            // Summary Section
            if !debtSummaries.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Debt Summary by Person")
                        .font(.title2)
                        .padding(.horizontal)

                    ForEach(debtSummaries) { summary in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(summary.name)
                                .font(.headline)
                            Text("Total Debt: $\(String(format: "%.2f", summary.totalDebt))")
                            Text("Total Credit: $\(String(format: "%.2f", summary.totalCredit))")
                            Text("Utilization: \(String(format: "%.1f", summary.utilization * 100))%")
                                .foregroundColor(summary.utilization > 0.3 ? .red : .green)
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom)
            }

            ScrollView {
                VStack(spacing: 16) {
                    ForEach(viewModel.debts) { debt in
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(debt.payee)
                                    .font(.headline)
                                Spacer()
                                Text("APR: \(String(format: "%.2f", debt.apr))%")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            Text("Responsibility: \(personName(for: debt.personId))")
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            Text("Debt: $\(String(format: "%.2f", debt.debtAmount)) / \(String(format: "%.2f", debt.lineOfCredit))")

                            ProgressView(value: debt.debtAmount, total: debt.lineOfCredit)
                                .accentColor(.red)

                            Text("Minimum Payment: $\(String(format: "%.2f", debt.minimumPayment))")
                            Text("Actual Payment: $\(String(format: "%.2f", debt.actualPayment))")

                            HStack {
                                Button("Edit") {
                                    debtToEdit = debt
                                }
                                Button(role: .destructive) {
                                    viewModel.deleteDebt(debt)
                                } label: {
                                    Text("Delete")
                                }
                            }
                            .padding(.top, 4)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            AddDebtView(viewModel: viewModel)
        }
        .sheet(item: $debtToEdit) { debt in
            EditDebtView(debt: debt, viewModel: viewModel)
        }
    }
}
