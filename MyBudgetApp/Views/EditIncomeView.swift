//
//  EditIncomeView.swift
//  MyBudgetApp
//
//  Created by Levi Boudreau on 6/7/25.
//

import SwiftUI

struct EditIncomeView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: IncomeViewModel

    @State private var personName: String
    @State private var amount: String
    @State private var frequency: IncomeFrequency
    @State private var payday: Int
    @State private var firstPayDate: Date


    var entry: IncomeEntry

    init(entry: IncomeEntry, viewModel: IncomeViewModel) {
        self.entry = entry
        self.viewModel = viewModel
        _personName = State(initialValue: entry.personName)
        _amount = State(initialValue: String(entry.amount))
        _frequency = State(initialValue: entry.frequency)
        _payday = State(initialValue: entry.payday) // ← this line is key
        _firstPayDate = State(initialValue: entry.firstPayDate)
    }

    var body: some View {
        NavigationView {
            Form {
                TextField("Person's Name", text: $personName)
                TextField("Amount", text: $amount)
                    .onChange(of: amount) { oldValue, newValue in
                        amount = newValue.filter { "0123456789.".contains($0) }
                    }

                Picker("Frequency", selection: $frequency) {
                    ForEach(IncomeFrequency.allCases) { freq in
                        Text(freq.rawValue).tag(freq)
                    }
                }
                Picker("Payday", selection: $payday) {
                    ForEach(1...7, id: \.self) { day in
                        Text(Calendar.current.weekdaySymbols[day % 7])
                            .tag(day)
                    }
                }
                DatePicker("First Pay Date", selection: $firstPayDate, displayedComponents: [.date])
            }
            .navigationTitle("Edit Income")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if let amountValue = Double(amount) {
                            let updated = IncomeEntry(
                                id: entry.id,
                                personName: personName,
                                amount: amountValue,
                                frequency: frequency,
                                payday: payday,
                                firstPayDate: firstPayDate
                            )
                            viewModel.updateEntry(updated)
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

