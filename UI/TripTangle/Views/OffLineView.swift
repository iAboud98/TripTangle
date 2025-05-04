//
//  OffLineView.swift
//  TripTangle
//
//  Created by Aboud Fialah on 04/05/2025.
//

import SwiftUI
import CoreBluetooth
import Combine  // Add this import

struct OfflineView: View {
    @EnvironmentObject var router: AppRouter
    @Environment(\.dismiss) var dismiss
    @StateObject private var bluetoothManager = BluetoothManager()
    @State private var gateQuery: String = ""
    @State private var receivedMessages: [String] = []
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Header
                    VStack {
                        Image(systemName: "antenna.radiowaves.left.and.right")
                            .font(.system(size: 40))
                            .foregroundColor(Color(red: 0.145, green: 0.553, blue: 0.576))
                        Text("Offline Airport Mode")
                            .font(.title.bold())
                    }
                    .padding(.top)
                    
                    // Instructions
                    Text("Ask nearby travelers for gate info when you have no internet")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                    
                    // Search Input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Your Flight Number")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        TextField("ex: AA123", text: $gateQuery)
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    // Action Button
                    Button(action: broadcastQuery) {
                        HStack {
                            Image(systemName: "paperplane.fill")
                            Text("Ask Nearby Travelers")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            gateQuery.isEmpty
                            ? Color.gray
                            : Color(red: 0.145, green: 0.553, blue: 0.576)
                        )
                        .cornerRadius(50)
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    }
                    .disabled(gateQuery.isEmpty)
                    .padding()
                    
                    // Responses
                    if !receivedMessages.isEmpty {
                        VStack(alignment: .leading) {
                            Text("Responses")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ScrollView {
                                VStack(spacing: 12) {
                                    ForEach(receivedMessages, id: \.self) { message in
                                        HStack {
                                            Image(systemName: "person.fill")
                                                .foregroundColor(.gray)
                                            Text(message)
                                                .padding(10)
                                                .background(Color(.secondarySystemBackground))
                                                .cornerRadius(12)
                                            Spacer()
                                        }
                                    }
                                }
                                .padding()
                            }
                            .frame(maxHeight: 200)
                        }
                    }
                    
                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        router.goToWelcome()
                    }
                }
            }            .onReceive(bluetoothManager.$lastMessage) { message in
                if let message = message {
                    receivedMessages.append(message)
                }
            }
        }
    }
    
    private func broadcastQuery() {
        let message = "Looking for gate info on flight \(gateQuery)"
        bluetoothManager.broadcast(message: message)
    }
}

class BluetoothManager: NSObject, ObservableObject {
    private var peripheralManager: CBPeripheralManager!
    @Published var lastMessage: String?  // Changed to @Published
    
    override init() {
        super.init()
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }
    
    func broadcast(message: String) {
        // Simulate receiving a response after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.lastMessage = "Gate for \(message) is at Terminal B, Concourse 12"
        }
    }
}

extension BluetoothManager: CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        // Handle BLE state changes
    }
}
// Preview
#Preview {
    OfflineView()
}
