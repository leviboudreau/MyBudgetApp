//
//  EditSavingGoalView.swift
//  MyBudgetApp
//
//  Created by Levi Boudreau on 6/8/25.
//

import SwiftUI

struct EditSavingGoalView: View {
    @Environment(\.dismiss) var dismiss
    var goal: SavingGoal
    @ObservedObject var viewModel: SavingGoalsViewModel

    @State private var name: String
    @State private var targetAmount: String
    @State private var savedAmount: String
    @State private var monthlyContribution: String

    init(goal: SavingGoal, viewModel: SavingGoalsViewModel) {
        self.goal = goal
        self.viewModel = viewModel
        _name = State(initialValue: goal.name)
        _targetAmount = State(initialValue: String(goal.targetAmount))
        _savedAmount = State(initialValue: String(goal.savedAmount))
        _monthlyContribution = State(initialValue: goal.monthlyContribution != nil ? String(format: "%.2f", goal.monthlyContribution!) : "")
    }
  
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Edit Savings Goal")
                .font(.title)

            TextField("Goal Name", text: $name)
            TextField("Target Amount", text: $targetAmount)
            TextField("Saved Amount", text: $savedAmount)
            TextField("Monthly Contribution (optional)", text: $monthlyContribution)

            Spacer()

            HStack {
                Button("Cancel") {
                    dismiss()
                }
                Spacer()
                Button("Save") {
                    guard let target = Double(targetAmount),
                          let saved = Double(savedAmount) else { return }

                    let contribution = Double(monthlyContribution)

                    let updated = SavingGoal(
                        id: goal.id,
                        name: name,
                        targetAmount: target,
                        savedAmount: saved,
                        monthlyContribution: contribution
                    )
                    viewModel.updateGoal(updated)
                    dismiss()
                }
                .disabled(name.isEmpty || targetAmount.isEmpty || savedAmount.isEmpty)
            }
        }
        .padding()
        .frame(width: 400)
    }
}
