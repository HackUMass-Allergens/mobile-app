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

func getOrder(client: PostgrestClient, orderId: UUID) async throws -> Order? {
    let response = try await client.from("orders")
        .select(columns: "*")
        .eq(column: "id", value: orderId.uuidString)
        .execute()
    
    return try response.decoded(to: [Order].self)[0]
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

func getUser(client: PostgrestClient, userId: UUID) async throws -> User {
    let response = try await client.from("users")
        .select(columns: "*,allergies:things(name)")
        .eq(column: "id", value: userId.uuidString)
        .execute()
    
    let users = try response.decoded(to: [User].self)
    
    return users[0]
}

struct AddAllergyParams: Codable {
    var allergy: String
}

func addAllergy(client: PostgrestClient, allergy: String) async throws {
    try await client.rpc(fn: "add_allergy", params: AddAllergyParams(allergy: allergy)).execute()
}

struct RemoveAllergyParams: Codable {
    var allergy: String
}

func removeAllergy(client: PostgrestClient, allergy: String) async throws {
    try await client.rpc(fn: "remove_allergy", params: RemoveAllergyParams(allergy: allergy))
        .execute()
}

func getAllAllergies(client: PostgrestClient) async throws -> [AllergyOrAllergen] {
    let response = try await client.from("things")
        .select(columns: "*")
        .execute()
    
    return try response.decoded(to: [AllergyOrAllergen].self)
}

struct CreateOrderParams : Codable {
    let order_time: String
    let comment: String
    let location: String
}

func createOrder(client: PostgrestClient, order_time: Date, comment: String, location: String) async throws -> Order? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .full
    
    let response = try await client.rpc(fn: "create_order", params: CreateOrderParams(order_time: dateFormatter.string(from: order_time), comment: comment, location: location))
        .execute()
    
    let orderId = try response.decoded(to: UUID.self)
    
    return try await getOrder(client: client, orderId: orderId)
}

struct AddOrderFoodParams : Codable {
    let order_id: UUID
    let food_id: UUID
}

func addOrderFood(client: PostgrestClient, order: Order, food: Food) async throws {
    try await client.rpc(fn: "add_order_food", params: AddOrderFoodParams(order_id: order.id, food_id: food.id))
        .execute()
}

