//
//  DbFunctions.swift
//  UMassAllergy
//
//  Created by Matthew Kotchkin on 11/12/22.
//

import Foundation
import PostgREST;

extension Date {
    static func ISOStringFromDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        
        return dateFormatter.string(from: date).appending("Z")
    }
    
    static func dateFromISOString(string: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        return dateFormatter.date(from: string)
    }
    
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay)!
    }
    
    var startOfWeek: Date {
        Calendar.current.dateComponents([.calendar, .yearForWeekOfYear, .weekOfYear], from: self).date!
    }
    
    var endOfWeek: Date {
        var components = DateComponents()
        components.weekOfYear = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfWeek)!
    }
    
    var startOfMonth: Date {
        let components = Calendar.current.dateComponents([.year, .month], from: startOfDay)
        return Calendar.current.date(from: components)!
    }
    
    var endOfMonth: Date {
        var components = DateComponents()
        components.month = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfMonth)!
    }
}

func getOrders(client: PostgrestClient, userId: UUID) async throws -> [Order] {
    let currentDate = Date.now;
    
    
    let orders = try await client.from("orders")
        .select(columns: "*")
        .gte(column: "time", value: Date.ISOStringFromDate(date: currentDate))
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
func getMealPeriodsOn(client: PostgrestClient, date: Date) async throws -> [MealPeriod] {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .full
    
    let beginningOfDay = date.startOfDay
    let endOfday = date.endOfDay
    
    let response = try await client.from("meal_periods")
        .select(columns: "*,meal_category:meal_categories(*)")
        .gte(column: "date", value: dateFormatter.string(from: beginningOfDay))
        .lte(column: "date", value: dateFormatter.string(from: endOfday))
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
        .select(columns: "*,meal_category:meal_categories(id),foods(*, allergens:things(*))")
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

