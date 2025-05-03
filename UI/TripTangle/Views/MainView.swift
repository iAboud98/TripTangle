//
//  MainView.swift
//  TripTangle
//
//  Created by Aboud Fialah on 03/05/2025.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            Text("Main View")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .foregroundColor(.black)
        }
    }
}

#Preview {
    MainView()
}
