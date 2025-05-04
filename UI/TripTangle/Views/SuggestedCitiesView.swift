// SuggestedCitiesView.swift
import SwiftUI

// MARK: – Response Models

struct AnalyzeResponse: Decodable {
    let group_id: Int
    let aggregated_preferences: AggregatedPreferences
    let suggested_destinations: [Destination]
}

struct AggregatedPreferences: Decodable {
    let origin: String?
    let travel_month: String    // "YYYY-MM"
    let budget: Int?
    let interests: [String]?
    let weather: String?
}

struct Destination: Identifiable, Decodable {
    let city: String
    let country: String
    let iata_code: String
    let reason: String
    let estimated_price: Int
    let image_url: URL
    let skyscanner_url: URL
    let gemini_price: Int?
    let votes: Votes

    var id: String { city }
}

struct Votes: Decodable {
    let number: Int
    // let by: [Voter]   // if you need the actual voters
}

// MARK: – View

struct SuggestedCitiesView: View {
    let groupId: Int

    @State private var destinations: [Destination] = []
    @State private var travelMonth: String = ""
    @State private var isLoading = true
    @State private var errorMessage: String?

    @State private var currentPage = 0
    @State private var isSelected = false

    var body: some View {
        VStack {
            if isLoading {
                Spacer()
                ProgressView()
                Spacer()
            } else if let err = errorMessage {
                Spacer()
                Text("Error: \(err)")
                    .foregroundColor(.red)
                Spacer()
            } else if destinations.isEmpty {
                Spacer()
                Text("No suggestions available.")
                    .foregroundColor(.gray)
                Spacer()
            } else {
                Spacer()

                // Pager of fetched city cards
                TabView(selection: $currentPage) {
                    ForEach(destinations.indices, id: \.self) { idx in
                        card(for: destinations[idx], at: idx)
                            .tag(idx)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .frame(height: 300)

                // Skip / Vote buttons
                HStack(spacing: 16) {
                    skipButton
                    voteButton
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)

                Spacer()
            }
        }
        .navigationTitle("Pick Your City")
        .navigationBarBackButtonHidden(true)
        .task { await loadSuggestions() }
    }

    // MARK: – Networking

    private func loadSuggestions() async {
        do {
            let url = URL(string: "http://127.0.0.1:8000/groups/groups/\(groupId)/analyze")!
            var req = URLRequest(url: url)
            req.httpMethod = "GET"
            req.setValue("application/json", forHTTPHeaderField: "Accept")
            if let token = UserDefaults.standard.string(forKey: "authToken") {
                req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }

            let (data, resp) = try await URLSession.shared.data(for: req)
            guard let http = resp as? HTTPURLResponse, 200..<300 ~= http.statusCode else {
                throw URLError(.badServerResponse)
            }

            let result = try JSONDecoder().decode(AnalyzeResponse.self, from: data)
            travelMonth = result.aggregated_preferences.travel_month
            destinations = result.suggested_destinations
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    // MARK: – Card View

    @ViewBuilder
    private func card(for dest: Destination, at index: Int) -> some View {
        HStack(spacing: 20) {
            // Text info
            VStack(alignment: .leading, spacing: 6) {
                Text(dest.city)
                    .font(.headline)
                    .foregroundColor(.white)
                Text(detailsString(for: dest))
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                Text(dest.reason)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.9))
                    .lineLimit(4)
                Spacer()
                Text("Votes: \(dest.votes.number)")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.8))
                Link("Book ↗︎", destination: dest.skyscanner_url)
                    .font(.caption)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Async image thumbnail
            AsyncImage(url: dest.image_url) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                Color.white.opacity(0.3)
            }
            .frame(width: 120, height: 120)
            .clipped()
            .cornerRadius(12)
        }
        .padding()
        .frame(
            width: UIScreen.main.bounds.width * 0.8,
            height: 280
        )
        .background(Color(hex: "#258d93"))
        .cornerRadius(20)
        .shadow(radius: 5)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white, lineWidth: isSelected && index == currentPage ? 3 : 0)
        )
        .onTapGesture {
            guard index == currentPage else { return }
            isSelected.toggle()
        }
    }

    private func detailsString(for dest: Destination) -> String {
        let monthYear = formattedMonthYear(from: travelMonth)
        return "$\(dest.estimated_price) • \(monthYear)"
    }

    private func formattedMonthYear(from iso: String) -> String {
        let parts = iso.split(separator: "-")
        guard parts.count == 2,
              let y = Int(parts[0]),
              let m = Int(parts[1]),
              (1...12).contains(m)
        else {
            return iso
        }
        let monthName = DateFormatter().monthSymbols[m - 1]
        return "\(monthName) \(y)"
    }

    // MARK: – Buttons

    private var skipButton: some View {
        Button("Skip") { goToNext() }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.secondarySystemBackground))
            .foregroundColor(.primary)
            .cornerRadius(10)
    }

    private var voteButton: some View {
        Button("Vote") {
            vote(for: destinations[currentPage])
            goToNext()
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(isSelected ? Color(hex: "#258d93") : Color.gray)
        .foregroundColor(.white)
        .cornerRadius(10)
        .disabled(!isSelected)
    }

    // MARK: – Actions

    private func goToNext() {
        if currentPage < destinations.count - 1 {
            currentPage += 1
            isSelected = false
        } else {
            currentPage = destinations.count
        }
    }

    private func vote(for dest: Destination) {
        print("✅ Voted for \(dest.city)")
        // TODO: wire up your backend voting endpoint
    }
}

// MARK: – Color(hex:) Extension

extension Color {
    init(hex: String) {
        var s = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if s.hasPrefix("#") { s.removeFirst() }
        let scanner = Scanner(string: s)
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        let r = Double((rgb & 0xFF0000) >> 16)/255
        let g = Double((rgb & 0x00FF00) >> 8)/255
        let b = Double( rgb & 0x0000FF       )/255
        self.init(red: r, green: g, blue: b)
    }
}
