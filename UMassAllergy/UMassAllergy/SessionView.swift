//
//  SessionView.swift
//  UMassAllergy
//
//  Created by Matthew Kotchkin on 11/12/22.
//

import Foundation
import GoTrue
import SwiftUI
import PostgREST

struct SessionView: View {
    @Environment(\.supaClient) private var client
    public var session: Session
    @State private var orders: [Order]?
    @State private var locations: [Location]?
    @State private var user: User?
    @State private var mealPeriods: [MealPeriod]?
    @State private var mealCategories: [MealCategory]?
    @State private var foodGroups: [FoodGroup]?
    @State private var error: Error?
    
    var body: some View {
        ScrollView {
            Text(stringfy(self.foodGroups?[0]))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            
            if let error {
                Section {
                    Text(error.localizedDescription)
                        .foregroundColor(.red)
                }
            }
        }
        .navigationTitle("Session")
        .toolbar {
            ToolbarItem {
                Button("Sign out") {
                    Task {
                        try? await client.auth.signOut()
                    }
                }
            }
        }
        .task {
            do {
                locations = try await getLocations(client: self.client.database)
                orders = try await getOrders(client: self.client.database, userId: session.user.id)
                user = try await getUser(client: self.client.database, userId: self.client.auth.session!.user.id.uuidString)
                mealPeriods = try await getMealPeriodsAfter(client: self.client.database, date: Date.now)
                mealCategories = try await getMealCategoriesForMealPeriod(client: self.client.database, mealPeriod: mealPeriods![0])
                foodGroups = try await getFoodGroupsForMealCategory(client: self.client.database, mealCategory: mealCategories![0])
            } catch {
                self.error = error
            }
            
        }
    }
}
