//
//  Login.swift
//  TripTangle
//
//  Created by Aboud Fialah on 03/05/2025.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var router: AppRouter
    @State private var email: String = ""
    @State private var password: String = ""

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack {
                
                HStack {
                    Button(action: {
                        router.goToWelcome()
                    }) {
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

                Text("Welcome Back")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 30)

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

                PrimaryButton(title: "Login")
                    .padding(.top, 30).onTapGesture {
                        router.goToMain()
                    }

                HStack {
                    Text("Don't have an account?")
                    Button(action: {
                        router.goToSignup()
                    }) {
                        Text("Sign up")
                            .foregroundColor(Color(red: 0.145, green: 0.553, blue: 0.576))
                            .fontWeight(.semibold)
                    }
                }

                .padding(.top, 10)

                Spacer()
            }
            .padding(40)
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AppRouter())
}
