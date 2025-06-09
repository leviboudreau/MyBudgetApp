//
//  AddSavingGoalView.swift
//  MyBudgetApp
//
//  Created by Levi Boudreau on 6/8/25.
//

import SwiftUI

struct AddSavingGoalView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: SavingGoalsViewModel

    @State private var name: String = ""
    @State private var targetAmount: String = ""
    @State private var savedAmount: String = ""
    @State private var monthlyContribution: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Add Savings Goal")
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
                    let newGoal = SavingGoal(
                        name: name,
                        targetAmount: target,
                        savedAmount: saved,
                        monthlyContribution: contribution
                    )
                    viewModel.addGoal(newGoal)
                    dismiss()
                }
                .disabled(name.isEmpty || targetAmount.isEmpty || savedAmount.isEmpty)
            }
        }
        .padding()
        .frame(width: 400)
    }
}
