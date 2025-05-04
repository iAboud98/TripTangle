//
//  RootView.swift
//  TripTangle
//
//  Created by Aboud Fialah on 03/05/2025.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var router: AppRouter

    var body: some View {
        Group {
            switch router.currentScreen {
                case .splash:
                    SplashView()
                case .welcome:
                    WelcomeView()
                case .login:
                    LoginView()
                case .signup:
                    SignUpView()
                case .main:
                    MainView()
                case .notification:
                    NotificationView()
                case .menu:
                    MenuView()
                case .offline:
                    OfflineView()
            }
        }
        .transition(.opacity)
        .animation(.easeInOut, value: router.currentScreen)
    }
}
