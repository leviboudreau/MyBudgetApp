//
//  Bill.swift
//  MyBudgetApp
//
//  Created by Levi Boudreau on 6/8/25.
//

import Foundation

enum BillCategory: String, CaseIterable, Codable, Identifiable {
    var id: String { rawValue }

    case creditCard = "Credit Card"
    case personalLoan = "Personal Loan"
    case k401Loan = "401K Loan"
    case studentLoan = "Student Loan"
    case subscription = "Subscription"
    case utilities = "Utilities"
    case taxes = "Taxes"
}

struct Bill: Identifiable, Codable, Equatable {
    var id = UUID()
    var payee: String
    var amount: Double
    var dueDay: Int
    var category: BillCategory
    var responsiblePersonId: UUID
}

