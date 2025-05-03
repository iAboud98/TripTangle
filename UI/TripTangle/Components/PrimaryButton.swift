//
//  PrimaryButton.swift
//  TripTangle
//
//  Created by Aboud Fialah on 03/05/2025.
//

import SwiftUI

struct PrimaryButton: View {
    var title: String

    var body: some View {
        Text(title)
            .font(.title3)
            .fontWeight(.bold)
            .foregroundColor(.white) // Change text color if needed for contrast
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(red: 0.145, green: 0.553, blue: 0.576))
            .cornerRadius(50)
            .shadow(color: Color.black.opacity(0.8), radius: 10, x: 0, y: 5) // Optional: add soft shadow
    }
}

#Preview {
    PrimaryButton(title: "Get Started")
}
