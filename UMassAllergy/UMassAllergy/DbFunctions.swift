//
//  DbFunctions.swift
//  UMassAllergy
//
//  Created by Matthew Kotchkin on 11/12/22.
//

import Foundation
import PostgREST;

func getOrders(client: PostgrestClient, userId: UUID) async throws -> [Order] {
    let orders = try await client.from("orders")
        .select(columns: "*")
        .execute();
    
    return try orders.decoded(to: [Order].self);
}

func getMealPeriodsAfter(client: PostgrestClient, date: Date) async throws -> [MealPeriod] {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .full
    
    let response = try await client.from("meal_periods")
        .select(columns: "*,meal_category:meal_categories(*)")
        .gte(column: "date", value: dateFormatter.string(from: date))
        .execute();
    
    return try response.decoded(to: [MealPeriod].self)
}

func getMealCategoriesForMealPeriod(client: PostgrestClient, mealPeriod: MealPeriod) async throws -> [MealCategory] {
    let response_daily = try await client.from("meal_categories")
        .select(columns: "*")
        .eq(column: "is_special", value: false)
        .execute()
    
    var daily_categories = try response_daily.decoded(to: [MealCategory].self)
    
    if let mealCategory = mealPeriod.meal_category {
        daily_categories.append(mealCategory)
    }
    
    return daily_categories
}

func getFoodGroupsForMealCategory(client: PostgrestClient, mealCategory: MealCategory) async throws -> [FoodGroup] {
    let response = try await client.from("food_groups")
        .select(columns: "*,meal_category:meal_categories(id),foods(*)")
        .eq(column: "meal_category.id", value: mealCategory.id.uuidString)
        .execute()
    
    return try response.decoded(to: [FoodGroup].self)
}

func getLocations(client: PostgrestClient) async throws -> [Location] {
    let response = try await client.from("locations")
        .select(columns: "*")
        .execute()
    
    return try response.decoded(to: [Location].self);
}

func getUser(client: PostgrestClient, userId: String) async throws -> User {
    let response = try await client.from("users")
        .select(columns: "*")
        .eq(column: "id", value: userId)
        .execute()
    
    let users = try response.decoded(to: [User].self)
    
    return users[0]
}
