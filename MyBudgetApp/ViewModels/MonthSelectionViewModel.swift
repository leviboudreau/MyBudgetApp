//
//  MonthSelectionViewModel.swift
//  MyBudgetApp
//
//  Created by Levi Boudreau on 6/8/25.
//

import Foundation

class MonthSelectionViewModel: ObservableObject {
    @Published var selectedMonthValue: Int
    @Published var selectedYearValue: Int

    init(date: Date = Date()) {
        let calendar = Calendar.current
        self.selectedMonthValue = calendar.component(.month, from: date)
        self.selectedYearValue = calendar.component(.year, from: date)
    }

    var selectedMonth: Date {
        Calendar.current.date(from: DateComponents(year: selectedYearValue, month: selectedMonthValue)) ?? Date()
    }
}
