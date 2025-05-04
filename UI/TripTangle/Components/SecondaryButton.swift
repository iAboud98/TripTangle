//
//  SecondaryButton.swift
//  TripTangle
//
//  Created by Aboud Fialah on 04/05/2025.
//

import SwiftUI

struct SecondaryButton: View {
    var title: String
    var icon: String? = nil
    var color: Color = Color(red: 0.145, green: 0.553, blue: 0.576) // Your teal color
    
    var body: some View {
        HStack(spacing: 12) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.title3)
            }
            Text(title)
        }
        .font(.title3)
        .fontWeight(.bold)
        .fontDesign(.monospaced)
        .foregroundColor(color) // Text color = teal
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white) // Solid white background
        .cornerRadius(50)
        .overlay(
            RoundedRectangle(cornerRadius: 50)
                .stroke(color, lineWidth: 4) // Teal border
        )
        .shadow(color: Color.black.opacity(0.8), radius: 10, x: 0, y: 5) // Lighter shadow
    }
}
#Preview {
        SecondaryButton(title: "Offline Airport Mode",
                       icon: "antenna.radiowaves.left.and.right")
        
}
