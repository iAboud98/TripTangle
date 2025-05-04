// TravelPreferencesView.swift
import SwiftUI

// MARK: – API Models

/// Matches the `preferences` field in your FastAPI GroupJoin schema
struct Preferences: Codable {
    let interests: [String]
    let max_budget: Int?
    let weather: String
    let date: String      // "YYYY-MM"
}

/// What your FastAPI /join/{group_id} expects
struct GroupJoinRequest: Codable {
    let user_id: Int
    let preferences: Preferences
}

// MARK: – Networking

enum PreferencesServiceError: LocalizedError {
    case missingAuthToken
    case serverError(String)
    case unknown

    var errorDescription: String? {
        switch self {
        case .missingAuthToken: return "Not logged in."
        case .serverError(let m): return m
        case .unknown: return "Unknown error."
        }
    }
}

final class PreferencesService {
    static let shared = PreferencesService()
    private let baseURL = URL(string: "http://127.0.0.1:8000")!  // adjust as needed

    private init() {}

    func joinGroup(groupId: Int, request: GroupJoinRequest) async throws {
        guard let token = UserDefaults.standard.string(forKey: "authToken") else {
            throw PreferencesServiceError.missingAuthToken
        }
        let url = baseURL.appendingPathComponent("groups/groups/join/\(groupId)")
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        req.httpBody = try JSONEncoder().encode(request)

        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse else { throw PreferencesServiceError.unknown }
        if !(200...299).contains(http.statusCode) {
            let msg = String(data: data, encoding: .utf8) ?? "Server error"
            throw PreferencesServiceError.serverError(msg)
        }
    }
}

// MARK: – View

struct TravelPreferencesView: View {
    let groupId: Int   // passed in via the parent NavigationStack

    // MARK: – Form state
    @State private var selectedInterests: Set<String> = []
    @State private var maxBudget: String = ""
    @State private var selectedWeather: String = "🌤️ Warm"
    @State private var selectedMonth = Calendar.current.component(.month, from: Date())
    @State private var selectedYear  = Calendar.current.component(.year, from: Date())

    // MARK: – Animation & navigation
    @State private var isScanning            = false
    @State private var scale: CGFloat        = 1.0
    @State private var opacity: Double       = 1.0
    @State private var currentMessageIndex   = 0
    @State private var navigateToSuggestions = false

    // MARK: – Error handling
    @State private var errorMessage: String?

    // MARK: – Current user
    @State private var currentUser: AuthenticatedUser?

    private let scanMessages = [
        "✈️ Creating your adventure... 🌍",
        "🧳 Finding perfect matches... 🏖️",
        "🗺️ Planning group experience... 🎒"
    ]

    private let interests = [
        "🏖️ Beach", "🏔️ Mountains", "🏙️ City", "🍕 Food", "🎨 Culture", "🛍️ Shopping",
        "🎉 Nightlife", "📸 Photography", "🚴‍♂️ Adventure", "❄️ Snow", "🌋 Nature",
        "🏛️ History", "🎭 Theater", "🎶 Music", "🍷 Wine Tasting", "🌌 Stargazing",
        "🧘‍♀️ Wellness", "🏄‍♂️ Surfing", "🐬 Wildlife", "🧗 Hiking", "⛺ Camping",
        "🎢 Theme Parks", "🖼️ Museums", "🏟️ Sports", "🛶 Water Sports", "🚂 Scenic Trains",
        "🕌 Religion", "🧳 Road Trip", "📚 Reading Retreat", "🍜 Street Food", "🛕 Temples"
    ]
    private let weathers = ["🌤️ Warm", "❄️ Cold", "⛅ Mild"]
    private let months   = Array(1...12)
    private let years    = Array(2024...2030)

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            VStack(spacing: 25) {
                if !isScanning {
                    preferencesForm
                }

                scanButton

                if isScanning {
                    Text(scanMessages[currentMessageIndex])
                        .font(.headline)
                        .foregroundColor(Color(hex: "#258d93"))
                        .transition(.opacity)
                        .id(currentMessageIndex)
                        .padding(.top, 20)
                }

                Spacer()

                NavigationLink(
                    destination: SuggestedCitiesView(groupId: 1),
                    isActive: $navigateToSuggestions
                ) {
                    EmptyView()
                }
            }
            .padding(.top)
        }
        .navigationTitle("Your Travel Preferences")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
        .onAppear {
            loadCurrentUser()
            startMessageCycle()
        }
        .alert("Error", isPresented: Binding<Bool>(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "")
        }
    }

    // MARK: – Form

    @ViewBuilder
    private var preferencesForm: some View {
        Text("Your Travel Preferences")
            .font(.system(size: 26, weight: .bold))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)

        interestsPicker
        budgetInput
        weatherPicker
        datePicker
    }

    private var interestsPicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("What are you into?")
                .font(.subheadline)
                .foregroundColor(.gray)

            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(interests, id: \.self) { interest in
                        let sel = selectedInterests.contains(interest)
                        Button {
                            if sel { selectedInterests.remove(interest) }
                            else   { selectedInterests.insert(interest) }
                        } label: {
                            Text(interest)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(sel ? Color(hex: "#258d93") : Color(.systemGray6))
                                .foregroundColor(sel ? .white : .black)
                                .clipShape(Capsule())
                        }
                    }
                }
                .padding(.top, 8)
            }
            .frame(height: 220)
            .padding(.horizontal)
        }
    }

    private var budgetInput: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Max Budget ($)")
                .font(.subheadline)
                .foregroundColor(.gray)
            TextField("e.g. 600", text: $maxBudget)
                .keyboardType(.numberPad)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
        }
        .padding(.horizontal)
    }

    private var weatherPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Preferred Weather")
                .font(.subheadline)
                .foregroundColor(.gray)
            HStack(spacing: 12) {
                ForEach(weathers, id: \.self) { w in
                    Button {
                        selectedWeather = w
                    } label: {
                        Text(w)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(selectedWeather == w ? Color(hex: "#258d93") : Color(.systemGray5))
                            .foregroundColor(selectedWeather == w ? .white : .black)
                            .cornerRadius(10)
                    }
                }
            }
        }
        .padding(.horizontal)
    }

    private var datePicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Travel Month")
                .font(.subheadline)
                .foregroundColor(.gray)
            HStack {
                Picker("Month", selection: $selectedMonth) {
                    ForEach(months, id: \.self) { m in
                        Text(DateFormatter().monthSymbols[m - 1]).tag(m)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .frame(maxWidth: .infinity)

                Picker("Year", selection: $selectedYear) {
                    ForEach(years, id: \.self) { y in
                        Text(String(y)).tag(y)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
            .padding(.horizontal)
        }
    }

    // MARK: – Scan Button

    private var scanButton: some View {
        Button(action: startScan) {
            ZStack {
                if isScanning {
                    Circle()
                        .fill(Color(hex: "#258d93").opacity(0.2))
                        .frame(width: 180, height: 180)
                        .scaleEffect(scale)
                        .opacity(opacity)
                }
                HStack {
                    if isScanning {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("🔍 Find My Trip")
                            .fontWeight(.bold)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(hex: "#258d93"))
                .foregroundColor(.white)
                .cornerRadius(14)
                .shadow(radius: 4)
            }
        }
        .padding(.horizontal)
        .disabled(isScanning)
    }

    // MARK: – Control Logic

    private func startScan() {
        withAnimation {
            isScanning = true
            scale = 1; opacity = 1
            withAnimation(Animation.easeOut(duration: 1.5).repeatForever(autoreverses: false)) {
                scale = 3.5; opacity = 0
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation { isScanning = false }
            submitPreferences()
        }
    }

    private func submitPreferences() {
        guard let me = currentUser else {
            errorMessage = "Login required"
            return
        }
        let monthStr = String(format: "%02d", selectedMonth)
        let dateStr = "\(selectedYear)-\(monthStr)"
        let prefs = Preferences(
            interests: Array(selectedInterests),
            max_budget: Int(maxBudget),
            weather: selectedWeather,
            date: dateStr
        )
        let request = GroupJoinRequest(user_id: me.id, preferences: prefs)

        Task {
            do {
                try await PreferencesService.shared.joinGroup(
                    groupId: groupId,
                    request: request
                )
                navigateToSuggestions = true
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    private func startMessageCycle() {
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
            if isScanning {
                withAnimation {
                    currentMessageIndex = (currentMessageIndex + 1) % scanMessages.count
                }
            }
        }
    }

    private func loadCurrentUser() {
        guard
            let data = UserDefaults.standard.data(forKey: "currentUser"),
            let user = try? JSONDecoder().decode(AuthenticatedUser.self, from: data)
        else { return }
        currentUser = user
    }
}

// MARK: – Preview

struct TravelPreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            TravelPreferencesView(groupId: 42)
        }
    }
}
