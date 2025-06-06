import SwiftUI

struct MenuView: View {
    @Environment(\.presentationMode) var presentationMode  // Used for back navigation

    var body: some View {
        NavigationView {
            VStack {
                // Custom Back Button
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 20)

                // Header
                Text("Main Menu")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .padding(.top, 10)

                // Menu Options List
                List {
                    NavigationLink(destination: Text("Group View")) {
                        Text("Group View")
                            .font(.headline)
                    }
                    NavigationLink(destination: Text("Flights View")) {
                        Text("Flights View")
                            .font(.headline)
                    }
                    NavigationLink(destination: Text("Posts View")) {
                        Text("Posts View")
                            .font(.headline)
                    }
                    NavigationLink(destination: Text("People View")) {
                        Text("People View")
                            .font(.headline)
                    }
                }
                .listStyle(PlainListStyle())
                .frame(maxWidth: .infinity)
                .background(Color.white)

                Spacer()
            }
            .background(Color(#colorLiteral(red: 0.1450980456, green: 0.5537163615, blue: 0.5778363342, alpha: 1)).opacity(0.1)) // Light background color
            .edgesIgnoringSafeArea(.all)
        }
    }
}
