//
//  WelcomeView.swift
//  TripTangle
//
//  Created by Aboud Fialah on 03/05/2025.
//

import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var router: AppRouter

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack {
                
                Text("TripTangle")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color.black)
                
                Spacer()
                
                Image("board")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 250)
                
                    
                Spacer()
                
                
                PrimaryButton(title: "Login")
                    .onTapGesture {
                        router.goToLogin()
                    }
                    .padding(.bottom, 10)

                PrimaryButton(title: "Sign Up")
                    .onTapGesture {
                        router.goToSignup()
                    }
                    .padding(.bottom, 10)
                
                SecondaryButton(title: "Off-line Service")
                    .onTapGesture {
                        router.goToOffline()                    }

            }
            .padding(40)
        }
    }
}

#Preview {
    WelcomeView()
        .environmentObject(AppRouter())
}

