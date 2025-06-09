//
//  SavingsDashboardView.swift
//  MyBudgetApp
//
//  Created by Levi Boudreau on 6/8/25.
//

import SwiftUI
import Charts

struct SavingsDashboardView: View {
    @ObservedObject var viewModel: SavingGoalsViewModel
    @State private var showingAddGoal = false
    @State private var goalToEdit: SavingGoal?

    @AppStorage("useSamePercentageForAll") private var useSamePercentageForAll: Bool = true
    @AppStorage("universalSavingsPercentage") private var universalSavingsPercentage: Double = 10.0

    @State private var individualPercentages: [UUID: Double] = [:]
    @State private var goalDistributions: [UUID: [UUID: Double]] = [:] // goalID -> [personID: %]
    @StateObject private var incomeModel = IncomeViewModel()
    @StateObject private var monthModel = MonthSelectionViewModel()

    func savingsAmount(for person: IncomeEntry) -> Double {
        let percentage = useSamePercentageForAll ? universalSavingsPercentage : (individualPercentages[person.id] ?? 0)
        return incomeModel.monthlyIncome(for: monthModel.selectedMonth, entry: person) * (percentage / 100)
    }

    func totalPercentageAllocated(for person: IncomeEntry) -> Double {
        viewModel.goals.reduce(0) { total, goal in
            total + (goalDistributions[goal.id]?[person.id] ?? 0)
        }
    }

    func contribution(for goal: SavingGoal, person: IncomeEntry) -> Double {
        let savings = savingsAmount(for: person)
        let personGoalShare = goalDistributions[goal.id]?[person.id] ?? 0
        return savings * (personGoalShare / 100)
    }

    func totalContribution(for goal: SavingGoal) -> Double {
        incomeModel.entries.reduce(0) { total, entry in
            total + contribution(for: goal, person: entry)
        }
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Savings")
                    .font(.largeTitle)
                Spacer()
                Button {
                    showingAddGoal = true
                } label: {
                    Label("Add Goal", systemImage: "plus")
                }
            }
            .padding()

            ScrollView {
                VStack(spacing: 12) {
                    ForEach(viewModel.goals) { goal in
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(goal.name)
                                    .font(.headline)
                                Spacer()
                                Text(String(format: "$%.2f / $%.2f", goal.savedAmount, goal.targetAmount))
                            }

                            ProgressView(value: goal.savedAmount, total: goal.targetAmount)
                                .accentColor(.green)

                            Text("Estimated Monthly Contribution: $\(String(format: "%.2f", totalContribution(for: goal)))")
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            ForEach(incomeModel.entries) { entry in
                                VStack(alignment: .leading) {
                                    Text("\(entry.personName)")
                                        .font(.caption)

                                    HStack {
                                        Slider(value: Binding(
                                            get: { goalDistributions[goal.id]?[entry.id] ?? 0 },
                                            set: { newValue in
                                                let personId = entry.id
                                                let goalId = goal.id

                                                if goalDistributions[goalId] == nil {
                                                    goalDistributions[goalId] = [:]
                                                }

                                                _ = goalDistributions[goalId]?[personId] ?? 0
                                                goalDistributions[goalId]?[personId] = newValue

                                                let totalPercentage = viewModel.goals.reduce(0.0) { sum, g in
                                                    g.id == goalId ? sum + newValue : sum + (goalDistributions[g.id]?[personId] ?? 0)
                                                }

                                                if totalPercentage > 100 {
                                                    let excess = totalPercentage - 100
                                                    let otherGoals = viewModel.goals.filter {
                                                        $0.id != goalId && (goalDistributions[$0.id]?[personId] ?? 0) > 0
                                                    }
                                                    let totalOthers = otherGoals.reduce(0.0) {
                                                        sum, g in sum + (goalDistributions[g.id]?[personId] ?? 0)
                                                    }

                                                    for g in otherGoals {
                                                        let current = goalDistributions[g.id]?[personId] ?? 0
                                                        let proportion = current / totalOthers
                                                        let reduction = excess * proportion
                                                        goalDistributions[g.id]?[personId] = max(0, current - reduction)
                                                    }
                                                }
                                            }
                                        ), in: 0...100)
                                        Text("\(Int(goalDistributions[goal.id]?[entry.id] ?? 0))%")
                                            .frame(width: 40)
                                    }

                                    Text("Contributing: $\(String(format: "%.2f", contribution(for: goal, person: entry)))")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)

                                    if totalPercentageAllocated(for: entry) > 100 {
                                        Text("⚠ Total for \(entry.personName) exceeds 100%")
                                            .font(.caption2)
                                            .foregroundColor(.red)
                                    }
                                }
                            }

                            HStack(spacing: 12) {
                                Button {
                                    goalToEdit = goal
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                }

                                Button(role: .destructive) {
                                    viewModel.deleteGoal(goal)
                                } label: {
                                    Label("Delete", systemImage: "trash")
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

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Automatic Savings")
                        .font(.title2)
                    Spacer()
                }

                Toggle("Use same percentage for all", isOn: $useSamePercentageForAll)
                    .padding(.vertical, 4)

                if useSamePercentageForAll {
                    HStack {
                        Text("Savings Percentage: ")
                        Slider(value: $universalSavingsPercentage, in: 0...100, step: 1)
                        Text("\(Int(universalSavingsPercentage))%")
                            .frame(width: 40, alignment: .leading)
                    }
                }

                ForEach(incomeModel.entries) { entry in
                    VStack(alignment: .leading) {
                        Text(entry.personName)
                            .font(.headline)

                        if !useSamePercentageForAll {
                            Slider(value: Binding(
                                get: { individualPercentages[entry.id] ?? 0 },
                                set: { individualPercentages[entry.id] = $0 }
                            ), in: 0...100, step: 1)
                            Text("\(Int(individualPercentages[entry.id] ?? 0))%")
                        } else {
                            Text("Using universal percentage")
                                .foregroundColor(.secondary)
                        }

                        Text("Estimated Monthly Savings: $\(String(format: "%.2f", savingsAmount(for: entry)))")
                            .font(.subheadline)
                    }
                    .padding(.vertical, 4)
                }
            }
            .padding()
        }
        .sheet(isPresented: $showingAddGoal) {
            AddSavingGoalView(viewModel: viewModel)
        }
        .sheet(item: $goalToEdit) { goal in
            EditSavingGoalView(goal: goal, viewModel: viewModel)
        }
    }
}
