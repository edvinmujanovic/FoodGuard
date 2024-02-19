//
//  PreferencesModel.swift
//  FoodGuard
//
//  Created by Edvin Mujanovic on 2024-02-13.
//

import Foundation
import Observation

@Observable
class PreferencesModel {
    var selectedIngredients: Set<String> = ["Lactose", "Eggs", "Nuts", "Gluten", "Soy", "Fish"]

    init() {
        loadPreferences()
    }

    func toggleIngredient(_ ingredient: String) {
        if selectedIngredients.contains(ingredient) {
            selectedIngredients.remove(ingredient)
        } else {
            selectedIngredients.insert(ingredient)
        }
        savePreferences()
    }
    
    
    //maybe fix enum for the values
    private func savePreferences() {
        UserDefaults.standard.set(Array(selectedIngredients), forKey: "selectedIngredients")
    }

    private func loadPreferences() {
        if let savedIngredients = UserDefaults.standard.array(forKey: "selectedIngredients") as? [String] {
            selectedIngredients = Set(savedIngredients)
        }
    }
}