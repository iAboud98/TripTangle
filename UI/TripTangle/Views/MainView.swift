//
//  MainView.swift
//  TripTangle
//
//  Created by Aboud Fialah on 03/05/2025.
//


import SwiftUI

struct MainView: View {
    @EnvironmentObject var router: AppRouter
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.white
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 30) {
                Spacer().frame(height: 100)

                // App Title and Subtitle
                VStack(spacing: 8) {
                    Text("TripTangle")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(Color(hex: "#258d93"))

                    Text("Connect. Combine. Travel Together.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }

                // Animated Globe or Icon Placeholder
                Image(systemName: "globe.europe.africa")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .foregroundColor(Color(hex: "#258d93").opacity(0.2))
                    .padding(.top, 20)
                    .rotationEffect(.degrees(15))
                    .shadow(radius: 5)

                Spacer()

                // Action Cards
                VStack(spacing: 25) {
                    ActionCard(title: "Create a Group", subtitle: "Start your travel circle now!", color: Color(hex: "#258d93"), textColor: .white) {
                        // Navigate to Create Group Page
                    }

                    ActionCard(title: "Find Travel Partners", subtitle: "Meet new people with shared vibes", color: Color.white, textColor: Color(hex: "#258d93"), borderColor: Color(hex: "#258d93")) {
                        // Action for Find Travel Partners
                    }
                }
                .padding(.horizontal, 30)

                Spacer()
            }

            // Floating Buttons
            HStack {
                CircleButton(iconName: "line.3.horizontal") {
                    // Menu action
                }
                Spacer()
                CircleButton(iconName: "bell",
                             action: router.goToNotification)
                
            }
            .padding(.horizontal, 20)
            .padding(.top, 40)

        }
    }
}

struct CircleButton: View {
    var iconName: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: iconName)
                .font(.title2)
                .foregroundColor(.black)
                .frame(width: 50, height: 50)
                .background(Color.gray.opacity(0.3))
                .clipShape(Circle())
                .shadow(radius: 3)
        }
    }
}

struct ActionCard: View {
    var title: String
    var subtitle: String
    var color: Color
    var textColor: Color
    var borderColor: Color? = nil
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(textColor)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(textColor.opacity(0.7))
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(color)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(borderColor ?? .clear, lineWidth: 2)
            )
            .shadow(color: .gray.opacity(0.3), radius: 4, x: 0, y: 2)
        }
    }
}

// Color extension for HEX
extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")

        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)

        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >> 8) & 0xFF) / 255.0
        let b = Double(rgb & 0xFF) / 255.0

        self.init(red: r, green: g, blue: b)
    }
}

#Preview {
    MainView()
        .environmentObject(AppRouter())
}

