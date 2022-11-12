//
//  UMassAllergyApp.swift
//  UMassAllergy
//
//  Created by Matthew Kotchkin on 11/11/22.
//

import SwiftUI
import GoTrue
import Supabase

private enum SupabaseEnvironmentKey: EnvironmentKey {
    static let defaultValue = SupabaseClient(supabaseURL: SUPABASE_URL, supabaseKey: SUPABASE_API_KEY)
}

extension EnvironmentValues {
    var supaClient: SupabaseClient {
        get { self[SupabaseEnvironmentKey.self]}
        set { self[SupabaseEnvironmentKey.self] = newValue}
    }
}

@main
struct UMassAllergyApp: App {
    var body: some Scene {
        WindowGroup {
            AppView()
        }
    }
}
