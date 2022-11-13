//
//  Types.swift
//  UMassAllergy
//
//  Created by Matthew Kotchkin on 11/12/22.
//

import Foundation

struct Order: Codable, Hashable {
    let id: UUID;
    let time: String
    let user: String
    let comment: String
    let location: String
}

struct User: Codable, Hashable {
    let id: UUID
    var first_name: String
    var last_name: String
    var allergies: [AllergyOrAllergen]
}

struct Location: Codable, Hashable {
    let name: String
}

struct MealPeriod: Codable, Hashable, Identifiable {
    let id: UUID
    let date: String
    let name: String
    let meal_category: MealCategory?
}

struct Food: Codable, Hashable, Identifiable {
    let id: UUID
    let name: String
    let ingredients: String?
    let allergens: [AllergyOrAllergen]
}

struct FoodGroup: Codable, Hashable {
    let name: String
    let num_items: Int8
    var foods: [Food]
}

extension FoodGroup: Identifiable {
    var id: String { name }
}

struct MealCategory: Codable, Hashable, Identifiable {
    let id: UUID
    let name: String
    let is_special: Bool
}

struct AllergyOrAllergen: Codable, Hashable, Equatable {
    let name: String
}
