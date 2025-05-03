//
//  NotificationView.swift
//  TripTangle
//
//  Created by Aboud Fialah on 03/05/2025.
//

import SwiftUI

struct NotificationView: View {
    let notifications = [
        ("Anna invited you to a new group in Paris.", "Tap to view the group."),
        ("Your group flight to Tokyo is now cheaper!", "Check for discounts."),
        ("Liam reacted to your travel post.", "See Liam's reaction."),
        ("3 new people are interested in Rome like you.", "Tap to learn more.")
    ]
    
    var body: some View {
        VStack {
            Text("Notifications")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.black)
                .padding(.top, 75)
            
            Spacer()
            
            ForEach(notifications, id: \.0) { notification in
                NotificationCard(title: notification.0, subtitle: notification.1) {
                    print("Tapped on notification: \(notification.0)")
                }
                .padding(.horizontal, 20) // Added padding to the left and right of the card
                .padding(.bottom, 10)
            }
            
            Spacer()
        }
        .background(Color.gray.opacity(0.4)) // Light gray with slight transparency
        .edgesIgnoringSafeArea(.all)
    }
}

struct NotificationCard: View {
    var title: String
    var subtitle: String
    var action: () -> Void
    
    let color: Color = Color(#colorLiteral(red: 0.1450980456, green: 0.5537163615, blue: 0.5778363342, alpha: 1)) // #258d93
    let textColor: Color = .white
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(textColor)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(textColor.opacity(0.7))
                    .lineLimit(nil) // Allow subtitle to wrap and adjust to the available space
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading) // Allow card to expand with content
            .background(color)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white, lineWidth: 2)
            )
            .shadow(color: .gray.opacity(0.3), radius: 4, x: 0, y: 2)
        }
    }
}

#Preview {
    NotificationView()
        .environmentObject(AppRouter())
}

