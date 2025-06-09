//
//  SavingGoalsViewModel.swift
//  MyBudgetApp
//
//  Created by Levi Boudreau on 6/8/25.
//

import Foundation

class SavingGoalsViewModel: ObservableObject {
    @Published var goals: [SavingGoal] = []

    private let storageKey = "saving_goals"

    init() {
        load()
    }

    func addGoal(_ goal: SavingGoal) {
        goals.append(goal)
        save()
    }

    func updateGoal(_ updated: SavingGoal) {
        if let index = goals.firstIndex(where: { $0.id == updated.id }) {
            goals[index] = updated
            save()
        }
    }

    func deleteGoal(_ goal: SavingGoal) {
        goals.removeAll { $0.id == goal.id }
        save()
    }

    private func save() {
        if let encoded = try? JSONEncoder().encode(goals) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }

    private func load() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([SavingGoal].self, from: data) {
            goals = decoded
        }
    }
}
