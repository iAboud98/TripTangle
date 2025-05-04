import SwiftUI

struct NotificationView: View {
    
    @EnvironmentObject var router: AppRouter
    @State private var navigateToPreferences = false
    @State private var navigateToReceiver = false

    let notifications = [
        ("Anna invited you to a new group in Paris.", "Tap to view the group."),
        ("Aboud is offline and lost his flight Gate !", "Tap to answer"),
        ("Liam reacted to your travel post.", "See Liam's reaction."),
        ("3 new people are interested in Rome like you.", "Tap to learn more.")
    ]
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Button(action: {
                        router.goToMain()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.black)
                            .frame(width: 36, height: 36)
                            .background(Color.gray.opacity(0.2))
                            .clipShape(Circle())
                    }
                    .padding(.top, 70)
                    .padding(.leading, 30)
                    
                    Spacer()
                }
                
                Text("Notifications")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .padding(.top, 75)
                
                Spacer()
                
                ForEach(notifications.indices, id: \.self) { index in
                    NotificationCard(title: notifications[index].0, subtitle: notifications[index].1) {
                        if index == 0 {
                            navigateToPreferences = true
                        }else if index == 1 {
                            navigateToReceiver = true
                        }else {
                            print("Tapped on notification: \(notifications[index].0)")
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 10)
                }

                Spacer()
                
                NavigationLink(destination: TravelPreferencesView(groupId: 1), isActive: $navigateToPreferences) {
                    EmptyView()
                }
                NavigationLink(destination: ReceiverView(), isActive: $navigateToReceiver) {
                                    EmptyView()
                                }
            }
            .background(Color.gray.opacity(0.3)) // Light gray with slight transparency
            .edgesIgnoringSafeArea(.all)
        }
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
                    .lineLimit(nil)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
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
