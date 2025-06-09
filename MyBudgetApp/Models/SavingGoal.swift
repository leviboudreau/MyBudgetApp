//
//  SavingGoal.swift
//  MyBudgetApp
//
//  Created by Levi Boudreau on 6/8/25.
//

import Foundation

struct SavingGoal: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String
    var targetAmount: Double
    var savedAmount: Double
    var monthlyContribution: Double?
}
