//
//  AddDebtView.swift
//  MyBudgetApp
//
//  Created by Levi Boudreau on 6/8/25.
//

import SwiftUI

struct AddDebtView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: DebtViewModel
    @StateObject private var incomeModel = IncomeViewModel()

    @State private var payee: String = ""
    @State private var lineOfCredit: String = ""
    @State private var debtAmount: String = ""
    @State private var minimumPayment: String = ""
    @State private var actualPayment: String = ""
    @State private var apr: String = ""
    @State private var selectedPersonId: UUID?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Add Debt")
                .font(.title)

            TextField("Payee", text: $payee)
            TextField("Line of Credit", text: $lineOfCredit)
            TextField("Debt Amount", text: $debtAmount)
            TextField("Minimum Payment", text: $minimumPayment)
            TextField("Actual Payment", text: $actualPayment)
            TextField("APR (%)", text: $apr)

            Picker("Responsible Person", selection: $selectedPersonId) {
                Text("Select").tag(UUID?.none)
                ForEach(incomeModel.entries) { entry in
                    Text(entry.personName).tag(entry.id as UUID?)
                }
            }

            Spacer()

            HStack {
                Button("Cancel") {
                    dismiss()
                }
                Spacer()
                Button("Save") {
                    guard let credit = Double(lineOfCredit),
                          let debt = Double(debtAmount),
                          let minPay = Double(minimumPayment),
                          let actPay = Double(actualPayment),
                          let rate = Double(apr),
                          let personId = selectedPersonId else { return }

                    let newDebt = Debt(
                        payee: payee,
                        lineOfCredit: credit,
                        debtAmount: debt,
                        minimumPayment: minPay,
                        actualPayment: actPay,
                        apr: rate,
                        personId: personId
                    )
                    viewModel.addDebt(newDebt)
                    dismiss()
                }
                .disabled(payee.isEmpty || lineOfCredit.isEmpty || debtAmount.isEmpty || minimumPayment.isEmpty || actualPayment.isEmpty || apr.isEmpty || selectedPersonId == nil)
            }
        }
        .padding()
        .frame(width: 400)
    }
}
