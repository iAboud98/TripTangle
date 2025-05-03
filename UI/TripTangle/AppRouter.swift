//
//  AppRouter.swift
//  TripTangle
//
//  Created by Aboud Fialah on 03/05/2025.
//

import Foundation

// Enum to define all screens in the app
enum AppScreen {
    case splash
    case welcome
    case login
    case signup
    case main
}

class AppRouter: ObservableObject {
    // Controls the current visible screen
    @Published var currentScreen: AppScreen = .splash

    // Navigation functions
    func goToSplash() {
        currentScreen = .splash
    }
    
    func goToWelcome() {
        currentScreen = .welcome
    }

    func goToLogin() {
        currentScreen = .login
    }

    func goToSignup() {
        currentScreen = .signup
    }

    func goToMain() {
        currentScreen = .main
    }

}
