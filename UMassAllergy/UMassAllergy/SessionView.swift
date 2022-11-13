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
                //NavigationLink(destination: Settings(), label:  {ButtonView("Settings")}).opacity(0.7)
                NavigationLink(destination: HelpInfo(), label: {ButtonView("Help/Info")}).opacity(0.7)
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Image("Foodfoodfood").resizable().aspectRatio(contentMode: .fill).ignoresSafeArea())
            
        }
        
    }
}

struct PlaceOrder : View {
    @Environment (\.supaClient) private var client
    @State private var locations: [Location]?
    
    var body: some View {
        VStack {
        label:do{(Text("Choose location"))
            .foregroundColor(Color.white)
            .font(Font.custom("sans serif", size: 48))}
            
            if let locations {
                    ForEach(locations) {location in
                        NavigationLink(destination: PlaceOrderDateTime(location: location), label:  {ButtonView(location.name)})
                    }
            }
        }.task {
            do {
                self.locations = try await getLocations(client: self.client.database)
            } catch {
                
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
    }
}

struct PlaceOrderDateTime: View {
    @Environment (\.supaClient) private var client
    public var location: Location
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
            
            DatePicker("Order Date/Time",
                       selection: $date,
                       in: dateRange,
                       displayedComponents: [.date, .hourAndMinute])
            .datePickerStyle(.graphical)
            .foregroundColor(.white)
            .colorInvert()
            
            NavigationLink(destination: PlaceOrderChooseMealPeriod(date: self.date, location: self.location), label:  {ButtonView("Select")})
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
    }
}


struct PlaceOrderChooseMealPeriod : View {
    @Environment (\.supaClient) private var client
    public var date: Date
    public var location: Location
    @State private var mealPeriods: [MealPeriod]?
    
    var body: some View {
        VStack {
        label:do{(Text("Select meal"))
            .foregroundColor(Color.white)
            .font(Font.custom("sans serif", size: 48))}
            
            if let mealPeriods {
                ForEach(mealPeriods) { mealPeriod in
                    NavigationLink(destination: PlaceOrderChooseMealCategory(date: self.date, mealPeriod: mealPeriod, location: self.location), label:  {ButtonView(mealPeriod.name)})
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
    public var date: Date
    public var mealPeriod: MealPeriod
    public var location: Location
    @State private var mealCategories: [MealCategory]?
    
    var body: some View {
        VStack {
        label:do{(Text("Select meal category"))
            .foregroundColor(Color.white)
            .font(Font.custom("sans serif", size: 48))}
            
            if let mealCategories {
                ForEach(mealCategories) { mealCategory in
                    NavigationLink(destination: PlaceOrderMenu(date: self.date, mealCategory: mealCategory, location: self.location), label:  {ButtonView(mealCategory.name)})
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
    public var date: Date
    public var mealCategory: MealCategory
    public var location: Location
    @State private var searchText = ""
    @State private var foodGroups: [FoodGroup]?
    @State private var foodSelection = Set<UUID>()
    
    var searchResults: [FoodGroup] {
        if let foodGroups {
            if searchText.isEmpty {
                return foodGroups
            } else {
                return foodGroups.map { foodGroup in
                    var newFoodGroup = foodGroup
                    
                    newFoodGroup.foods = newFoodGroup.foods.filter {$0.name.contains(searchText)}
                    
                    return newFoodGroup
                }
            }
        } else {
            return []
        }
    }
    
    var body: some View {
        NavigationView {
            List(selection: $foodSelection) {
                ForEach(searchResults) { foodGroup in
                    Section(header: Text(foodGroup.name)) {
                        ForEach(foodGroup.foods) { food in
                            NavigationLink(destination: FoodInfo(food: food), label:  {Text(food.name)})
                        }
                    }
                }
            }
            .toolbar {
                EditButton()
                Button("Order") {
                    Task {
                        let order = try await createOrder(client: client.database, order_time: self.date, comment: "", location: self.location.name)
                        
                        if let order {
                            for foodId in self.foodSelection {
                                try await addOrderFood(client: self.client.database, order: order, foodId: foodId)
                            }
                        }
                    }
                }
            }
            .searchable(text: $searchText)
            .navigationTitle(Text(mealCategory.name))
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .task {
            do {
                var foodGroups = try await getFoodGroupsForMealCategory(client: client.database, mealCategory: mealCategory)
                
                let user = try await getUser(client: client.database, userId: client.auth.session!.user.id)
                
                foodGroups = foodGroups.map({foodGroup in
                    var newFoodGroup = foodGroup
                    
                    newFoodGroup.foods = foodGroup.foods.filter({food in
                        var dangerous = false;
                        
                        for allergen in food.allergens {
                            if user.allergies.contains(allergen) {
                                dangerous = true;
                                break;
                            }
                        }
                        
                        return dangerous
                    })
                    
                    return newFoodGroup
                })
                
                self.foodGroups = foodGroups
            } catch {
                
            }
        }
    }
}


struct FoodInfo : View {
    public var food: Food
    
    var body: some View {
        VStack {
        label:do{(Text(food.name))
            .foregroundColor(Color.black)
            .font(Font.custom("sans serif", size: 48))}
            
            if let ingredients = food.ingredients {
                Text(ingredients)
            }
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ViewOrders: View {
    @Environment (\.supaClient) private var client
    @State private var orders: [Order]?
    
    var body: some View {
        VStack {
            var displayList:[String] = []
        label: do {Text("Your Existing Orders").foregroundColor(.white)}
                if let orders {
                    Table(orders) {
                        TableColumn("location", value: \.time)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .task {
            do {
                let passId = client.auth.session!.user.id
                self.orders = try await getOrders(client: client.database, userId: passId)
            } catch {
            }
        }
    }
    }


struct HelpInfo: View {
    var body: some View {
        VStack {
            Text("")
            .padding(10)
        label: do {Text("What is UMass S.A.F.E.R?")
                .foregroundColor(.white)
                .font(Font.custom("sans serif", size: 40))
                .multilineTextAlignment(.center)
                .padding(.bottom, 10)
        }
        label: do {Text("\tUMass S.A.F.E.R allows students with allergens to submit orders for safely prepared food catered to their dietary needs.\n\n\tAdd allergens to your account in the \"Settings\" page and foods containing those allergens will be excluded from your place order page. To place an order, go to the \"Place Order\" page and select the date, meal, meal type, dining hall, and time of pickup for your order.\n\n\tView and cancel your order from the View Orders page. You may change your order pickup time up until 5:00 Pm the day before the order date")
            .foregroundColor(.white)
            .font(Font.custom("sans serif", size: 18))
            .padding(20)
        }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.black)
    }
}

struct ImageButtonView: View {
    var text:String = ""
    var imageType:String = ""
    init(_ text:String, _ imageType:String) {
        self.text = text
        self.imageType = imageType
    }
    var body: some View {
        HStack {
            let image = UIImage(systemName: imageType)
            let targetSize = CGSize(width: 50, height: 50)
            let scaledImage = image!.scalePreservingAspectRatio(
                targetSize: targetSize
            )
            Image(uiImage: scaledImage)
                .foregroundColor(Color.red)
                .padding(10)
                Text(text)
                .foregroundColor(Color.red)
                .font(Font.custom("sans serif", size: 32))
        }
        .frame(width: 300, height: 100, alignment: .leading)
        .background(Color(red: 0.8, green: 0.8, blue: 0.8))
        .cornerRadius(15)
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

extension UIImage {
    func scalePreservingAspectRatio(targetSize: CGSize) -> UIImage {
        // Determine the scale factor that preserves aspect ratio
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        
        let scaleFactor = min(widthRatio, heightRatio)
        
        // Compute the new image size that preserves aspect ratio
        let scaledImageSize = CGSize(
            width: size.width * scaleFactor,
            height: size.height * scaleFactor
        )

        // Draw and return the resized UIImage
        let renderer = UIGraphicsImageRenderer(
            size: scaledImageSize
        )

        let scaledImage = renderer.image { _ in
            self.draw(in: CGRect(
                origin: .zero,
                size: scaledImageSize
            ))
        }
        
        return scaledImage
    }
}
