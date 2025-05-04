// MainView.swift
import SwiftUI

struct MainView: View {
    @EnvironmentObject var router: AppRouter

    // Navigation state
    @State private var showCreateGroup = false
    @State private var navigateToPreferences = false

    // Current user loaded from UserDefaults
    @State private var currentUser: AuthenticatedUser?

    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                Color.white
                    .ignoresSafeArea()

                VStack(spacing: 30) {
                    Spacer().frame(height: 100)

                    // 👋 Greet the user if available
                    if let user = currentUser {
                        Text("Hello, \(user.username)!")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(Color(hex: "#258d93"))
                    }

                    // App Title & Subtitle
                    VStack(spacing: 8) {
                        Text("TripTangle")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(Color(hex: "#258d93"))
                        Text("Connect. Combine. Travel Together.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }

                    // Globe Icon
                    Image(systemName: "globe.europe.africa")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .foregroundColor(Color(hex: "#258d93").opacity(0.2))
                        .rotationEffect(.degrees(15))
                        .shadow(radius: 5)

                    Spacer()

                    // Action Cards
                    VStack(spacing: 25) {
                        // Create Group
                        NavigationLink(destination: CreateGroupView(), isActive: $showCreateGroup) {
                            EmptyView()
                        }
                        ActionCard(
                            title: "Create a Group",
                            subtitle: "Start your travel circle now!",
                            color: Color(hex: "#258d93"),
                            textColor: .white
                        ) {
                            showCreateGroup = true
                        }

                        // Find Travel Partners
                        NavigationLink(destination: TravelPreferencesView(groupId: 1), isActive: $navigateToPreferences) {
                            EmptyView()
                        }
                        ActionCard(
                            title: "Find Travel Partners",
                            subtitle: "Meet new people with shared vibes",
                            color: Color.white,
                            textColor: Color(hex: "#258d93"),
                            borderColor: Color(hex: "#258d93")
                        ) {
                            navigateToPreferences = true
                        }
                    }
                    .padding(.horizontal, 30)

                    Spacer()
                }

                // Floating Buttons
                HStack {
                    CircleButton(iconName: "line.3.horizontal", action: router.goToMenu)
                    Spacer()
                    CircleButton(iconName: "bell", action: router.goToNotification)
                }
                .padding(.horizontal, 20)
                .padding(.top, 40)
            }
            .onAppear(perform: loadCurrentUser)
        }
    }

    // Load the user from UserDefaults
    private func loadCurrentUser() {
        if
            let data = UserDefaults.standard.data(forKey: "currentUser"),
            let user = try? JSONDecoder().decode(AuthenticatedUser.self, from: data)
        {
            currentUser = user
        } else {
            currentUser = nil
        }
    }
}

// MARK: – CircleButton

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

// MARK: – ActionCard

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

// MARK: – Preview

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .environmentObject(AppRouter())
    }
}
