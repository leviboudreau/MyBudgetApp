//
//  NavigationSection.swift
//  MyBudgetApp
//
//  Created by Levi Boudreau on 6/7/25.
//

import Foundation

enum NavigationSection: String, CaseIterable, Identifiable, Hashable {
    case budget = "Budget Overview"
    case income = "Income"

    var id: String { rawValue }
}

