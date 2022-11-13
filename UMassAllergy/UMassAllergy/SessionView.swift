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
import UIKit

struct SessionView: View {
    @Environment(\.supaClient) private var client
    public var session: Session
    @State private var error: Error?

    var body: some View {
        NavigationView {
            VStack {
            label:do{(Text("UMASS S.A.F.E.R"))
                .foregroundColor(Color.white)
                .font(Font.custom("sans serif", size: 48))
            }
                NavigationLink(destination: PlaceOrder(), label: {ButtonView("Place Order")})
                NavigationLink(destination: ViewOrders(), label: {ButtonView("View Orders")})
                NavigationLink(destination: Sett(), label:  {ButtonView("Settings")})
                NavigationLink(destination: HelpInfo(), label: {ButtonView("Help/Info")})
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
    }
}

//: Datetime!
let date = Date()
let calendar  = Calendar.current
let hour = calendar.component(.hour, from: date)
let weekd = calendar.component(.weekday, from:date)
var weekList = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
var weeksOne = Array(weekList[weekd-1..<7]) + Array(weekList[0..<weekd-1])
var weeksTwo = Array(weekList[weekd..<7]) + Array(weekList[0..<weekd])
struct dy:Identifiable {
    var id: String
    var meal: String
}
let meals = [
    dy(id: "a", meal: "Breakfast"),
    dy(id: "b", meal: "Lunch"),
    dy(id: "c", meal:  "Dinner")
]

struct PlaceOrder: View {
    @Environment (\.supaClient) private var client
    @State private var mealPeriods: [MealPeriod]?
    
    var body: some View {
        NavigationView {
            VStack {
                if hour < 17 {
                    ScrollView (.horizontal) {
                        HStack (spacing : 20) {
                            ForEach(meals) { meal in
                                NavigationLink(destination: Menu(day: weeksOne[0], meal: meal.meal), label: {Text(weeksOne[0] + " " + meal.meal)})
                            }
                        }
                    }
                    ScrollView (.horizontal) {
                        HStack (spacing : 20) {
                            ForEach(meals) { meal in
                                NavigationLink(destination: Menu(day: weeksOne[1], meal: meal.meal), label: {Text(weeksOne[1] + " " + meal.meal)})
                            }
                        }
                    }
                    
                    ScrollView (.horizontal) {
                        HStack (spacing : 20) {
                            ForEach(meals) { meal in
                                NavigationLink(destination: Menu(day: weeksOne[2], meal: meal.meal), label: {Text(weeksOne[2] + " " + meal.meal)})
                            }
                        }
                    }
                    
                    
                    ScrollView (.horizontal) {
                        HStack (spacing : 20) {
                            ForEach(meals) { meal in
                                NavigationLink(destination: Menu(day: weeksOne[3], meal: meal.meal), label: {Text(weeksOne[3] + " " + meal.meal)})
                            }
                        }
                    }
                    
                    ScrollView (.horizontal) {
                        HStack (spacing : 20) {
                            ForEach(meals) { meal in
                                NavigationLink(destination: Menu(day: weeksOne[4], meal: meal.meal), label: {Text(weeksOne[4] + " " + meal.meal)})
                            }
                        }
                    }
                    
                    ScrollView (.horizontal) {
                        HStack (spacing : 20) {
                            ForEach(meals) { meal in
                                NavigationLink(destination: Menu(day: weeksOne[5], meal: meal.meal), label: {Text(weeksOne[5] + " " + meal.meal)})
                            }
                        }
                    }
                    
                    ScrollView (.horizontal) {
                        HStack (spacing : 20) {
                            ForEach(meals) { meal in
                                NavigationLink(destination: Menu(day: weeksOne[6], meal: meal.meal), label: {Text(weeksOne[6] + " " + meal.meal)})
                            }
                        }
                    }
                    
                }
                else {
                    ScrollView (.horizontal) {
                        HStack (spacing : 20) {
                            ForEach(meals) { meal in
                                NavigationLink(destination: Menu(day: weeksTwo[0], meal: meal.meal), label: {Text(weeksTwo[0] + " " + meal.meal)})
                            }
                        }
                    }
                    ScrollView (.horizontal) {
                        HStack (spacing : 20) {
                            ForEach(meals) { meal in
                                NavigationLink(destination: Menu(day: weeksTwo[1], meal: meal.meal), label: {Text(weeksTwo[1] + " " + meal.meal)})
                            }
                        }
                    }
                    
                    ScrollView (.horizontal) {
                        HStack (spacing : 20) {
                            ForEach(meals) { meal in
                                NavigationLink(destination: Menu(day: weeksTwo[2], meal: meal.meal), label: {Text(weeksTwo[2] + " " + meal.meal)})
                            }
                        }
                    }
                    
                    
                    ScrollView (.horizontal) {
                        HStack (spacing : 20) {
                            ForEach(meals) { meal in
                                NavigationLink(destination: Menu(day: weeksTwo[3], meal: meal.meal), label: {Text(weeksTwo[3] + " " + meal.meal)})
                            }
                        }
                    }
                    
                    ScrollView (.horizontal) {
                        HStack (spacing : 20) {
                            ForEach(meals) { meal in
                                NavigationLink(destination: Menu(day: weeksTwo[4], meal: meal.meal), label: {Text(weeksTwo[4] + " " + meal.meal)})
                            }
                        }
                    }
                    
                    ScrollView (.horizontal) {
                        HStack (spacing : 20) {
                            ForEach(meals) { meal in
                                NavigationLink(destination: Menu(day: weeksTwo[5], meal: meal.meal), label: {Text(weeksTwo[5] + " " + meal.meal)})
                            }
                        }
                    }
                    
                    ScrollView (.horizontal) {
                        HStack (spacing : 20) {
                            ForEach(meals) { meal in
                                NavigationLink(destination: Menu(day: weeksTwo[6], meal: meal.meal), label: {Text(weeksTwo[6] + " " + meal.meal)})
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: 250, maxHeight: 600)
            .background(Color.white)
        }
        .task {
            do {
                self.mealPeriods = try await getMealPeriodsOn(client: self.client.database, date: date)
            } catch {
                
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
    }
}

struct ViewOrders: View {
    var body: some View {
        VStack {
            label: do {Text("Your Existing Orders").foregroundColor(.white)}
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
    }
}

//struct Sett: View {
//    var body: some View {
//        VStack {
//            label: do {Text("Settings").foregroundColor(.white)}
//        }
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .background(Color.black)
//    }
//}

struct HelpInfo: View {
    var body: some View {
        VStack {
        label: do {Text("Some Info").foregroundColor(.white)}
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
    }
}

struct Menu: View {
    public var day: String
    public var meal: String
    var body: some View {
        VStack {
        label: do {Text(day + meal) }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
    }
}


struct ButtonView: View {
    var text:String = ""
    init(_ text:String) {
        self.text = text
    }
    var body: some View {
        Text(text)
            .frame(width: 300, height: 100, alignment: .center)
            .background(Color(red: 0.2, green: 0.2, blue: 0.2))
            .foregroundColor(Color(red: 0.0, green: 0.0, blue: 0.6))
            .cornerRadius(15)
            .font(Font.custom("sans serif", size: 32))
    }
}

struct QuestionView: View {
    var body: some View {
        Text("?")
            .frame(width: 300, height: 100, alignment: .center)
            .background(Color(red: 0.2, green: 0.2, blue: 0.2))
            .foregroundColor(Color(red: 0.0, green: 0.0, blue: 0.6))
            .cornerRadius(15)
            .font(Font.custom("sans serif", size: 32))
    }
}
