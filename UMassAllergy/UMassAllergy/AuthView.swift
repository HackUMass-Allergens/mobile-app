//
//  AuthView.swift
//  UMassAllergy
//
//  Created by Matthew Kotchkin on 11/12/22.
//

import Foundation
import GoTrue
import SwiftUI

struct AuthView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var token = ""
    @State private var error: Error?
    @Environment(\.supaClient) private var client
    @State private var needsVerification: Bool = false
    
    var body: some View {
        
        if needsVerification {
            Form {
                Section {
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                    TextField("Token", text: $token)
                        .keyboardType(.default)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                }
                
                Section {
                    Button("Sign in") {
                        verifyOTP()
                    }
                }
                
                if let error {
                    Section {
                        Text(error.localizedDescription)
                            .foregroundColor(.red)
                    }
                }
            }
        } else {
            Form {
                Section {
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                }
                
                Section {
                    Button("Sign in") {
                        signInButtonTapped()
                    }
                }
                
                if let error {
                    Section {
                        Text(error.localizedDescription)
                            .foregroundColor(.red)
                    }
                }
            }
        }
    }
    
    private func signInButtonTapped() {
        Task {
            do {
                self.error = nil
                try await client.auth.signIn(email: email)
                self.needsVerification = true
            } catch {
                self.error = error
            }
        }
    }
    
    private func verifyOTP() {
        Task {
            do {
                self.error = nil
                try await client.auth.verifyOTP(params: .verifyEmailOTPParams(VerifyEmailOTPParams(email: email, token: token, type: .recovery)))
            } catch {
                self.error = error
            }
        }
    }
}
