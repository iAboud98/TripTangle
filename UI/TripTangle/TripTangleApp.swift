//
//  TripTangleApp.swift
//  TripTangle
//
//  Created by Aboud Fialah on 03/05/2025.
//

import SwiftUI

@main
struct TripTangleApp: App {
    // Create an instance of AppRouter as a StateObject
    @StateObject var router = AppRouter()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(router) // Inject router into the environment
        }
    }
}
