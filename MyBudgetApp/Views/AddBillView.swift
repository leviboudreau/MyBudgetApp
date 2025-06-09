//
//  AddBillView.swift
//  MyBudgetApp
//
//  Created by Levi Boudreau on 6/8/25.
//

import SwiftUI

struct AddBillView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var billModel: BillViewModel
    @ObservedObject var incomeModel: IncomeViewModel

    @State private var payee: String = ""
    @State private var amount: String = ""
    @State private var dueDay: Int = 1
    @State private var category: BillCategory = .utilities
    @State private var selectedPersonId: UUID?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Add New Bill")
                .font(.title)

            TextField("Payee", text: $payee)
            TextField("Amount", text: $amount)

            Picker("Due Day", selection: $dueDay) {
                ForEach(1...31, id: \.self) { day in
                    Text("\(day)").tag(day)
                }
            }
            .pickerStyle(MenuPickerStyle())

            Picker("Category", selection: $category) {
                ForEach(BillCategory.allCases) { cat in
                    Text(cat.rawValue).tag(cat)
                }
            }
            .pickerStyle(MenuPickerStyle())

            Picker("Responsible Person", selection: Binding(get: {
                selectedPersonId ?? UUID()
            }, set: {
                selectedPersonId = $0
            })) {
                ForEach(incomeModel.entries, id: \.id) { person in
                    Text(person.personName).tag(person.id)
                }
            }

            .pickerStyle(MenuPickerStyle())

            Spacer()

            HStack {
                Button("Cancel") {
                    dismiss()
                }
                Spacer()
                Button("Save") {
                    guard let amt = Double(amount), let personId = selectedPersonId else { return }
                    let bill = Bill(payee: payee, amount: amt, dueDay: dueDay, category: category, responsiblePersonId: personId)
                    billModel.addBill(bill)
                    dismiss()
                }
                .disabled(payee.isEmpty || amount.isEmpty || selectedPersonId == nil)
            }
        }
        .padding()
        .frame(width: 400)
    }
}
