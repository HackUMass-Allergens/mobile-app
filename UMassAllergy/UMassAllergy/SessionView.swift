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
    @State private var error: Error?

    var body: some View {
        NavigationView {
            VStack {
            label:do{(Text("Welcome!"))
                .foregroundColor(Color.white)
                .font(Font.custom("sans serif", size: 48))
            }
            .buffer()
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
struct PlaceOrder: View {
    var body: some View {
        VStack {
            label: do {Text("Place Order").foregroundColor(.white)}
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

struct Sett: View {
    var body: some View {
        VStack {
            label: do {Text("Settings").foregroundColor(.white)}
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
