//
//  EditBillView.swift
//  MyBudgetApp
//
//  Created by Levi Boudreau on 6/8/25.
//

import SwiftUI

struct EditBillView: View {
    @Environment(\.dismiss) var dismiss
    var bill: Bill
    @ObservedObject var billModel: BillViewModel
    @ObservedObject var incomeModel: IncomeViewModel

    @State private var payee: String
    @State private var amount: String
    @State private var dueDay: Int
    @State private var category: BillCategory
    @State private var selectedPersonId: UUID?

    init(bill: Bill, billModel: BillViewModel, incomeModel: IncomeViewModel) {
        self.bill = bill
        self.billModel = billModel
        self.incomeModel = incomeModel
        _payee = State(initialValue: bill.payee)
        _amount = State(initialValue: String(format: "%.2f", bill.amount))
        _dueDay = State(initialValue: bill.dueDay)
        _category = State(initialValue: bill.category)
        _selectedPersonId = State(initialValue: bill.responsiblePersonId)
    }

    var responsiblePersonBinding: Binding<UUID> {
        Binding<UUID>(
            get: {
                selectedPersonId ?? (incomeModel.entries.first?.id ?? UUID())
            },
            set: {
                selectedPersonId = $0
            }
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Edit Bill")
                .font(.title)

            TextField("Payee", text: $payee)
            TextField("Amount", text: $amount)

            Picker("Due Day", selection: $dueDay) {
                ForEach(1...31, id: \Int.self) { day in
                    Text("\(day)").tag(day)
                }
            }
            .pickerStyle(MenuPickerStyle())

            Picker("Category", selection: $category) {
                ForEach(BillCategory.allCases, id: \.self) { cat in
                    Text(cat.rawValue).tag(cat)
                }
            }
            .pickerStyle(MenuPickerStyle())

            Picker("Responsible Person", selection: responsiblePersonBinding) {
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
                    let updated = Bill(id: bill.id, payee: payee, amount: amt, dueDay: dueDay, category: category, responsiblePersonId: personId)
                    billModel.updateBill(updated)
                    dismiss()
                }
                .disabled(payee.isEmpty || amount.isEmpty || selectedPersonId == nil)
            }
        }
        .padding()
        .frame(width: 400)
    }
}

