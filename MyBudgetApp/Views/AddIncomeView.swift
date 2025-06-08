//
//  AddIncomeView.swift
//  MyBudgetApp
//
//  Created by Levi Boudreau on 6/7/25.
//

import SwiftUI

struct AddIncomeView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: IncomeViewModel

    @State private var personName = ""
    @State private var amount = ""
    @State private var frequency: IncomeFrequency = .monthly
    @State private var payday: Int = 6 // Default to Friday (6 = Friday in Calendar.current)
    @State private var firstPayDate: Date = Date()

    
    var body: some View {
        NavigationView {
            Form {
                TextField("Person's Name", text: $personName)
                TextField("Amount", text: $amount)
                    .onChange(of: amount) { _, newValue in
                        amount = newValue.filter { "0123456789.".contains($0) }
                    }

                Picker("Frequency", selection: $frequency) {
                    ForEach(IncomeFrequency.allCases) { freq in
                        Text(freq.rawValue).tag(freq)
                    }
                }
                Picker("Payday", selection: $payday) {
                    ForEach(1...7, id: \.self) { day in
                        Text(Calendar.current.weekdaySymbols[day % 7]) // 1 = Sunday
                            .tag(day)
                    }
                }
                DatePicker("First Pay Date", selection: $firstPayDate, displayedComponents: [.date])
            }
            .navigationTitle("Add Income")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if let amountValue = Double(amount) {
                            let newEntry = IncomeEntry(
                                personName: personName,
                                amount: amountValue,
                                frequency: frequency,
                                payday: payday,
                                firstPayDate: firstPayDate
                            )
                            viewModel.addEntry(newEntry)
                            dismiss()
                        }
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: { dismiss() })
                }
            }
        }
        .frame(minWidth: 400, minHeight: 250)
    }
}
