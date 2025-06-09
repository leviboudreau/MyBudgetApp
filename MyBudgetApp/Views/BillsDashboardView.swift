//
//  BillsDashboardView.swift
//  MyBudgetApp
//
//  Created by Levi Boudreau on 6/8/25.
//

import SwiftUI

struct BillsDashboardView: View {
    @ObservedObject var billModel: BillViewModel
    @ObservedObject var incomeModel: IncomeViewModel
    @State private var showingAddBill = false
    @State private var billToEdit: Bill?

    var body: some View {
        VStack(alignment: .leading) {
            header
            billList
        }
        .sheet(isPresented: $showingAddBill) {
            AddBillView(billModel: billModel, incomeModel: incomeModel)
        }
        .sheet(item: $billToEdit) { bill in
            EditBillView(bill: bill, billModel: billModel, incomeModel: incomeModel)
        }
    }

    private var header: some View {
        HStack {
            Text("Bills")
                .font(.largeTitle)
            Spacer()
            Button(action: { showingAddBill = true }) {
                Label("Add Bill", systemImage: "plus")
            }
        }
        .padding()
    }

    private var billList: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(billModel.bills, id: \.id) { bill in
                    billCard(for: bill)
                }
            }
            .padding(.horizontal)
        }
    }

    private func billCard(for bill: Bill) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(bill.payee)
                    .font(.headline)
                Spacer()
                Text(bill.category.rawValue)
                    .font(.subheadline)
            }

            HStack {
                Text("Due Day: \(bill.dueDay)")
                Spacer()
                Text("Amount: \(String(format: "$%.2f", bill.amount))")
            }

            responsiblePersonText(for: bill)

            HStack(spacing: 12) {
                Button {
                    billToEdit = bill
                } label: {
                    Label("Edit", systemImage: "pencil")
                }
                Button(role: .destructive) {
                    billModel.deleteBill(bill)
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
            .padding(.top, 4)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }

    private func responsiblePersonText(for bill: Bill) -> some View {
        Group {
            if let person = incomeModel.entries.first(where: { $0.id == bill.responsiblePersonId }) {
                Text("Responsible: \(person.personName)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}
