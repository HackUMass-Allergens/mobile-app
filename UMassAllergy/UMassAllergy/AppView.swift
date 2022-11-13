//
//  AppView.swift
//  UMassAllergy
//
//  Created by Matthew Kotchkin on 11/12/22.
//

import Foundation
import GoTrue
import SwiftUI
import Supabase

struct AppView: View {
    @Environment(\.supaClient) private var client
    @State private var session: Session?
    
    var body: some View {
        NavigationView {
            if let session {
                SessionView(session: session)
            } else {
                List {
                    NavigationLink("Auth with Email OTP") {
                        AuthView()
                    }
                }
                .listStyle(.plain)
                .navigationTitle("Allergy Ordering")
            }
        }
        .task {
            for await _ in client.auth.authEventChange.values {
                session = client.auth.session;
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

func stringfy<T: Codable>(_ value: T) -> String {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    let data = try? encoder.encode(value)
    return data.flatMap { String(data: $0, encoding: .utf8) } ?? ""
}

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        AppView()
    }
}
