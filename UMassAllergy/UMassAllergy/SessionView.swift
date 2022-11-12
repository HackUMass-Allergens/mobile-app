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
                NavigationLink(destination: PlaceOrder(), label: {Text("Place a New Order")})
                NavigationLink(destination: ViewOrders(), label: {Text("View Existing Orders")})
                NavigationLink(destination: Sett(), label: {Text("Settings")})
                NavigationLink(destination: HelpInfo(), label: {Text("Help/Info")})
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
            label: do {Text("Place an Order") }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
    }
}

struct ViewOrders: View {
    var body: some View {
        VStack {
            label: do {Text("Your Existing Orders") }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
    }
}

struct Sett: View {
    var body: some View {
        VStack {
            label: do {Text("Settings") }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
    }
}

struct HelpInfo: View {
    var body: some View {
        VStack {
        label: do {Text("Some Info") }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
    }
}
