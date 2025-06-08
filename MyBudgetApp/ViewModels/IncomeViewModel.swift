//
//  IncomeViewModel.swift
//  MyBudgetApp
//
//  Created by Levi Boudreau on 6/7/25.
//

import Foundation

class IncomeViewModel: ObservableObject {
    @Published var entries: [IncomeEntry] = []

    private let storageKey = "income_entries"

    init() {
        load()
    }

    // MARK: - Entry Management

    func addEntry(_ entry: IncomeEntry) {
        entries.append(entry)
        save()
    }

    func deleteEntry(_ entry: IncomeEntry) {
        entries.removeAll { $0.id == entry.id }
        save()
    }

    func updateEntry(_ updated: IncomeEntry) {
        if let index = entries.firstIndex(where: { $0.id == updated.id }) {
            entries[index] = updated
            save()
        }
    }

    // MARK: - Income Calculations

    func monthlyIncome(for month: Date = Date()) -> Double {
        let daysInMonth = Calendar.current.range(of: .day, in: .month, for: month)?.count ?? 30
        return entries.reduce(0) { total, entry in
            total + estimatedMonthly(from: entry, daysInMonth: daysInMonth, for: month)
        }
    }

    func monthlyIncome(for month: Date = Date(), entry: IncomeEntry) -> Double {
        let daysInMonth = Calendar.current.range(of: .day, in: .month, for: month)?.count ?? 30
        return estimatedMonthly(from: entry, daysInMonth: daysInMonth, for: month)
    }

    private func estimatedMonthly(from entry: IncomeEntry, daysInMonth: Int, for month: Date) -> Double {
        let calendar = Calendar.current
        guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: month)),
              let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth) else {
            return 0
        }

        switch entry.frequency {
        case .daily:
            return entry.amount * Double(daysInMonth)

        case .weekly, .biWeekly:
            let intervalDays = entry.frequency == .weekly ? 7 : 14
            var payDates: [Date] = []
            var currentPayDate = entry.firstPayDate

            while currentPayDate <= endOfMonth {
                if calendar.isDate(currentPayDate, equalTo: startOfMonth, toGranularity: .month) {
                    payDates.append(currentPayDate)
                }
                currentPayDate = calendar.date(byAdding: .day, value: intervalDays, to: currentPayDate)!
            }

            return entry.amount * Double(payDates.count)

        case .semiMonthly:
            // Assumes pay on 1st and 15th regardless of weekday
            var count = 0
            let components = calendar.dateComponents([.year, .month], from: startOfMonth)

            if let first = calendar.date(from: DateComponents(year: components.year, month: components.month, day: 1)),
               calendar.isDate(first, equalTo: startOfMonth, toGranularity: .month) {
                count += 1
            }

            if let fifteenth = calendar.date(from: DateComponents(year: components.year, month: components.month, day: 15)),
               calendar.isDate(fifteenth, equalTo: startOfMonth, toGranularity: .month) {
                count += 1
            }

            return entry.amount * Double(count)

        case .monthly:
            return entry.amount
        }
    }

    // MARK: - Persistence

    private func save() {
        if let encoded = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }

    private func load() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([IncomeEntry].self, from: data) {
            entries = decoded
        }
    }
}
