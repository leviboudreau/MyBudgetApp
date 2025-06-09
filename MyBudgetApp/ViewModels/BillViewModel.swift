//
//  BillViewModel.swift
//  MyBudgetApp
//
//  Created by Levi Boudreau on 6/8/25.
//

import Foundation

class BillViewModel: ObservableObject {
    @Published var bills: [Bill] = []

    private let storageKey = "bills"

    init() {
        load()
    }

    func addBill(_ bill: Bill) {
        bills.append(bill)
        save()
    }

    func updateBill(_ updated: Bill) {
        if let index = bills.firstIndex(where: { $0.id == updated.id }) {
            bills[index] = updated
            save()
        }
    }

    func deleteBill(_ bill: Bill) {
        bills.removeAll { $0.id == bill.id }
        save()
    }

    private func save() {
        if let encoded = try? JSONEncoder().encode(bills) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }

    private func load() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([Bill].self, from: data) {
            bills = decoded
        }
    }
}
