//
//  IncomeEntry.swift
//  MyBudgetApp
//
//  Created by Levi Boudreau on 6/7/25.
//

import Foundation

enum IncomeFrequency: String, Codable, CaseIterable, Identifiable {
    case daily = "Daily"
    case weekly = "Weekly"
    case biWeekly = "Bi-Weekly"
    case semiMonthly = "Semi-Monthly"
    case monthly = "Monthly"

    var id: String { rawValue }
}

struct IncomeEntry: Identifiable, Codable, Equatable {
    var id = UUID()
    var personName: String
    var amount: Double
    var frequency: IncomeFrequency
    var payday: Int // 1 = Sunday, 7 = Saturday
    var firstPayDate: Date
}

