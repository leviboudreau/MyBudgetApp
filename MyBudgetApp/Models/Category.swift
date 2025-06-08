//
//  Category.swift
//  MyBudgetApp
//
//  Created by Levi Boudreau on 6/7/25.
//

import Foundation

struct BudgetCategory: Identifiable, Codable {
    var id = UUID()
    var name: String
    var amount: Double
    var spent: Double = 0.0 // Default to 0 for now
}
