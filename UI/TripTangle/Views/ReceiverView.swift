import SwiftUI

struct ReceiverView: View {
    @EnvironmentObject var router: AppRouter
    @Environment(\.dismiss) var dismiss
    @State private var responseMessage: String = ""
    
    // Mock notification data
    let notification = (
        user: "Aboud",
        flight: "QR702",
        problem: "can't find the gate",
        timeReceived: "Just now",
        userIcon: "person.fill.questionmark"
    )
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Notification Header
                VStack(spacing: 16) {
                    Image(systemName: notification.userIcon)
                        .font(.system(size: 50))
                        .foregroundColor(.orange)
                        .padding()
                        .background(Circle().fill(Color.orange.opacity(0.2)))
                    
                    VStack(spacing: 4) {
                        Text("Help \(notification.user)!")
                            .font(.title2.bold())
                        
                        Text("Flight \(notification.flight) • \(notification.timeReceived)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.top, 30)
                
                // Problem Card
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                        Text("Emergency Request")
                            .font(.headline)
                    }
                    
                    Text("\(notification.user) \(notification.problem) and needs assistance.")
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.orange.opacity(0.1)))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                )
                .padding(.horizontal)
                
                // Response Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Your Response")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    TextEditor(text: $responseMessage)
                        .frame(height: 120)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                }
                .padding(.horizontal)
                
                // Action Buttons
                VStack(spacing: 12) {
                    Button(action: sendResponse) {
                        HStack {
                            Image(systemName: "paperplane.fill")
                            Text("Send Helpful Info")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            responseMessage.isEmpty ?
                            Color.gray :
                            Color(red: 0.145, green: 0.553, blue: 0.576)
                        )
                        .cornerRadius(50)
                    }
                    .disabled(responseMessage.isEmpty)
                    
                    Button("I Can't Help") {
                        router.goToMain()
                    }
                    .foregroundColor(.gray)
                }
                .padding()
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        router.goToMain()
                    }
                }
            }
        }
    }
    
    private func sendResponse() {
        print("Sent response for \(notification.flight): \(responseMessage)")
        dismiss()
    }
}

#Preview {
    ReceiverView()
}
