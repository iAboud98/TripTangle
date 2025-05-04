// LoginView.swift
import SwiftUI

struct LoginView: View {
    @EnvironmentObject var router: AppRouter

    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack {
                // Back button
                HStack {
                    Button {
                        router.goToWelcome()
                    } label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.black)
                            .frame(width: 36, height: 36)
                            .background(Color.gray.opacity(0.2))
                            .clipShape(Circle())
                    }
                    .padding(.top, 20)
                    .padding(.leading, 10)

                    Spacer()
                }

                Spacer()

                // Title
                Text("Welcome Back")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 30)

                // Email & Password fields
                VStack(spacing: 20) {
                    TextField("Email", text: $email)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)

                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                }
                .padding(.horizontal)

                // Error message
                if let errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.subheadline)
                        .padding(.top, 8)
                }

                // Login button with spinner
                ZStack {
                    PrimaryButton(title: "Login")
                        .opacity(isLoading ? 0.5 : 1)
                        .disabled(isLoading)

                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    }
                }
                .padding(.top, 30)
                .onTapGesture(perform: performLogin)

                // Signup link
                HStack {
                    Text("Don't have an account?")
                    Button {
                        router.goToSignup()
                    } label: {
                        Text("Sign up")
                            .foregroundColor(Color("#258d93"))
                            .fontWeight(.semibold)
                    }
                }
                .padding(.top, 10)

                Spacer()
            }
            .padding(40)
        }
    }

    private func performLogin() {
        // Basic validation
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter both email and password."
            return
        }
        errorMessage = nil
        isLoading = true

        Task {
            do {
                // Call shared AuthService
                let resp = try await AuthService.shared.login(email: email, password: password)
                // Store token
                UserDefaults.standard.set(resp.accessToken, forKey: "authToken")
                // Store user object
                let userData = try JSONEncoder().encode(resp.user)
                UserDefaults.standard.set(userData, forKey: "currentUser")

                // Navigate to main screen
                router.goToMain()
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(AppRouter())
    }
}
