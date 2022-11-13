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
//                StrokeText(text: "Sample Text", width: 0.5, color: .red)
//                .foregroundColor(.black)
//                .font(.system(size: 12, weight: .bold))
            label:do{(Text("UMASS S.A.F.E.R").padding(10))
                .foregroundColor(Color.white).background(RoundedRectangle(cornerRadius: 10, style: .continuous).foregroundColor(Color(red: 0.55, green: 0.1, blue: 0.1)))
                .font(.system(size: 75, weight: .bold, design: .serif))
            }
                NavigationLink(destination: PlaceOrder(), label: {ButtonView("Place Order")}).opacity(0.7).foregroundColor(Color.red)
                NavigationLink(destination: ViewOrders(), label: {ButtonView("View Orders")}).opacity(0.7)
                NavigationLink(destination: Sett(), label:  {ButtonView("Settings")}).opacity(0.7)
                NavigationLink(destination: HelpInfo(), label: {ButtonView("Help/Info")}).opacity(0.7)
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Image("Foodfoodfood").resizable().aspectRatio(contentMode: .fill).ignoresSafeArea())
            
        }
        
    }
}

struct PlaceOrder: View {
    @Environment (\.supaClient) private var client
    @State private var date = Date()
    
    let dateRange: ClosedRange<Date> = {
        let today = Date.now
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: today)
        let currentMonth = calendar.component(.month, from: today)
        let currentDay = calendar.component(.day, from: today)
        let startComponents = DateComponents(year: currentYear, month: currentMonth, day: currentDay)
        let startDate = calendar.date(from: startComponents)!
        let endDate = DateInterval(start: startDate, duration: TimeInterval(60 * 60 * 24 * 7 * 4)).end
        
        return startDate...endDate
    }()
    
    var body: some View {
        VStack {
        label:do{(Text("Select order date"))
            .foregroundColor(Color.white)
            .font(Font.custom("sans serif", size: 48))}
            
            DatePicker("Order Date",
            selection: $date,
            in: dateRange,
            displayedComponents: .date)
            .datePickerStyle(.graphical)
            .foregroundColor(.white)
            .colorInvert()
            
            NavigationLink(destination: PlaceOrderChooseMealPeriod(date: self.date), label:  {ButtonView("Select")})
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
    }
}


struct PlaceOrderChooseMealPeriod : View {
    @Environment (\.supaClient) private var client
    public var date: Date
    @State private var mealPeriods: [MealPeriod]?
    
    var body: some View {
        VStack {
        label:do{(Text("Select meal"))
            .foregroundColor(Color.white)
            .font(Font.custom("sans serif", size: 48))}
            
            if let mealPeriods {
                ForEach(mealPeriods) { mealPeriod in
                    NavigationLink(destination: PlaceOrderChooseMealCategory(mealPeriod: mealPeriod), label:  {ButtonView(mealPeriod.name)})
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .task {
            do {
                self.mealPeriods = try await getMealPeriodsOn(client: self.client.database, date: self.date)
            } catch {
                
            }
        }
    }
}

struct PlaceOrderChooseMealCategory : View {
    @Environment (\.supaClient) private var client
    public var mealPeriod: MealPeriod
    @State private var mealCategories: [MealCategory]?
    
    var body: some View {
        VStack {
        label:do{(Text("Select meal category"))
            .foregroundColor(Color.white)
            .font(Font.custom("sans serif", size: 48))}
            
            if let mealCategories {
                ForEach(mealCategories) { mealCategory in
                    NavigationLink(destination: PlaceOrderMenu(mealCategory: mealCategory), label:  {ButtonView(mealCategory.name)})
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .task {
            do {
                self.mealCategories = try await getMealCategoriesForMealPeriod(client: client.database, mealPeriod: self.mealPeriod)
            } catch {
                
            }
        }
    }
}

struct PlaceOrderMenu : View {
    @Environment (\.supaClient) private var client
    public var mealCategory: MealCategory
    @State private var foodGroups: [FoodGroup]?
    @State private var foodSelection = Set<UUID>()
    
    var body: some View {
        VStack {
        label:do{(Text(mealCategory.name))
            .foregroundColor(Color.white)
            .font(Font.custom("sans serif", size: 48))}
            
            List(selection: $foodSelection) {
                if let foodGroups {
                    ForEach(foodGroups) { foodGroup in
                        Section(header: Text(foodGroup.name)) {
                            ForEach(foodGroup.foods) { food in
                                Text(food.name)
                            }
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .task {
            do {
                self.foodGroups = try await getFoodGroupsForMealCategory(client: client.database, mealCategory: mealCategory)
            } catch {
                
            }
        }
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

struct HelpInfo: View {
    var body: some View {
        VStack {
        label: do {Text("Some Info").foregroundColor(.white)}
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
            .padding(-20)
            .background(Color(red: 0.8, green: 0.8, blue: 0.8))
            .foregroundColor(Color(red: 0.55, green: 0.1, blue: 0.1))
            .cornerRadius(15)
            .font(.system(size: 40, design: .serif))
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
