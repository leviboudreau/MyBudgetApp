//
//  BudgetProgressView.swift
//  MyBudgetApp
//
//  Created by Levi Boudreau on 6/7/25.
//

import SwiftUI

struct BudgetProgressView: View {
    var category: BudgetCategory

    var progress: Double {
        guard category.amount > 0 else { return 0 }
        return min(category.spent / category.amount, 1.0)
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(category.name)
                    .font(.headline)
                Spacer()
                Text(String(format: "$%.2f / $%.2f", category.spent, category.amount))
                    .font(.subheadline)
            }

            ProgressView(value: progress)
                .progressViewStyle(.linear)
                .accentColor(progress < 0.5 ? .green : (progress < 0.9 ? .yellow : .red))
                .frame(height: 8)

        }
        .padding(.vertical, 4)
    }
}
