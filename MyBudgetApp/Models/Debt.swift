//
//  Debt.swift
//  MyBudgetApp
//
//  Created by Levi Boudreau on 6/8/25.
//

import Foundation

struct Debt: Identifiable, Codable, Equatable {
    var id = UUID()
    var payee: String
    var lineOfCredit: Double
    var debtAmount: Double
    var minimumPayment: Double
    var actualPayment: Double
    var apr: Double
    var personId: UUID
}
