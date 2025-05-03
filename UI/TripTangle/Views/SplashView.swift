//
//  SplashView.swift
//  TripTangle
//
//  Created by Aboud Fialah on 03/05/2025.
//

import SwiftUI

struct SplashView: View {
    @EnvironmentObject var router: AppRouter
    @State private var opacity = 0.0
    @State private var isActive = false
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack {
                // Use the app icon as the logo
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .opacity(opacity)
            }
        }
        .opacity(isActive ? 0.0 : 1.0)
        .onAppear {
            // Fade-in animation for logo
            withAnimation(.easeIn(duration: 1.5)) {
                opacity = 1.0
            }
            
            // After the splash animation, trigger navigation to login or main screen
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.easeOut(duration: 1.5)) {
                    isActive = true
                }
                
                router.goToWelcome()
            }
        }
    }
}

#Preview {
    SplashView()
        .environmentObject(AppRouter())
}
