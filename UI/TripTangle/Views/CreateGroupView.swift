// CreateGroupView.swift
import SwiftUI

struct CreateGroupView: View {
    @EnvironmentObject var router: AppRouter

    // MARK: – Navigation path
    @State private var path: [Int] = []

    // MARK: – Form state
    @State private var groupName     = ""
    @State private var searchText    = ""
    @State private var isPublic      = true
    @State private var selectedEmoji = "🌍"
    @State private var selectedUsers = Set<AuthenticatedUser>()

    // MARK: – Data from server
    @State private var allUsers      = [AuthenticatedUser]()

    // MARK: – Loading & errors
    @State private var isLoading     = false
    @State private var errorMessage: String?

    // MARK: – Current user
    @State private var currentUser: AuthenticatedUser?

    private let emojiOptions = ["🌍","✈️","🏝️","🏔️","🎒","🌆"]

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        headerView
                        groupNameSection
                        emojiPickerSection
                        publicToggleSection
                        searchSection
                        userListSection
                        errorSection
                        createButton
                        Spacer(minLength: 40)
                    }
                    .padding(.top)
                }
            }
            .onAppear(perform: loadCurrentUser)
            .onChange(of: searchText) { searchUsers(matching: $0) }
            .navigationTitle("Create Group")
            .navigationBarTitleDisplayMode(.inline)

            // MARK: – Programmatic destination
            .navigationDestination(for: Int.self) { groupId in
                TravelPreferencesView(groupId: groupId)
            }
        }
    }

    // MARK: – Subviews

    private var headerView: some View {
        Text("Create Group")
            .font(.system(size: 28, weight: .bold))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
    }

    private var groupNameSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Group Name")
                .font(.subheadline)
                .foregroundColor(.gray)
            TextField("e.g. Summer Getaway", text: $groupName)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
        }
        .padding(.horizontal)
    }

    private var emojiPickerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Group Photo")
                .font(.subheadline)
                .foregroundColor(.gray)
            HStack {
                Text(selectedEmoji)
                    .font(.system(size: 40))
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(emojiOptions, id: \.self) { emoji in
                            Button { selectedEmoji = emoji } label: {
                                Text(emoji)
                                    .font(.system(size: 30))
                                    .padding(8)
                                    .background(selectedEmoji == emoji
                                                ? Color.blue.opacity(0.2)
                                                : Color.clear)
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
    }

    private var publicToggleSection: some View {
        Toggle("Make Group Public", isOn: $isPublic)
            .padding(.horizontal)
    }

    private var searchSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Invite Members")
                .font(.subheadline)
                .foregroundColor(.gray)
            TextField("Search by name...", text: $searchText)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
        }
        .padding(.horizontal)
    }

    private var userListSection: some View {
        VStack(spacing: 0) {
            ForEach(allUsers, id: \.self) { user in
                Button {
                    toggleSelection(of: user)
                } label: {
                    HStack {
                        Text(user.username)
                        Spacer()
                        Image(systemName: selectedUsers.contains(user)
                              ? "checkmark.circle.fill"
                              : "circle")
                            .foregroundColor(selectedUsers.contains(user) ? .green : .gray)
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal)
                }
                Divider()
            }
        }
        .background(Color(.systemGroupedBackground))
        .cornerRadius(12)
        .padding(.horizontal)
    }

    private var errorSection: some View {
        Group {
            if let err = errorMessage {
                Text(err)
                    .foregroundColor(.red)
                    .font(.subheadline)
                    .padding(.horizontal)
            }
        }
    }

    private var createButton: some View {
        Button(action: submitCreateGroup) {
            Group {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "#258d93"))
                        .cornerRadius(16)
                        .padding(.horizontal)
                } else {
                    Text("Create Group")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(groupName.isEmpty
                                    ? Color.gray.opacity(0.4)
                                    : Color(hex: "#258d93"))
                        .foregroundColor(.white)
                        .cornerRadius(16)
                        .shadow(radius: 3)
                        .padding(.horizontal)
                }
            }
        }
        .disabled(groupName.isEmpty || isLoading)
    }

    // MARK: – Actions

    private func loadCurrentUser() {
        guard
            let data = UserDefaults.standard.data(forKey: "currentUser"),
            let user = try? JSONDecoder().decode(AuthenticatedUser.self, from: data)
        else { return }
        currentUser = user
    }

    private func searchUsers(matching query: String) {
        Task {
            guard let me = currentUser, !query.isEmpty else {
                allUsers = []
                return
            }
            do {
                allUsers = try await UserService.shared.searchUsers(
                    query: query,
                    currentUserID: me.id
                )
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    private func toggleSelection(of user: AuthenticatedUser) {
        if selectedUsers.contains(user) {
            selectedUsers.remove(user)
        } else {
            selectedUsers.insert(user)
        }
    }

    private func submitCreateGroup() {
        guard let me = currentUser else {
            errorMessage = "You must be logged in."
            return
        }
        let request = GroupCreateRequest(
            name: groupName,
            created_by: me.id,
            group_photo: selectedEmoji,
            is_public: isPublic
        )
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let group = try await GroupService.shared.createGroup(request)
                print("✅ Created group:", group)
                // PUSH into TravelPreferencesView by appending group.id to path
                path.append(group.id)
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
}

struct CreateGroupView_Previews: PreviewProvider {
    static var previews: some View {
        CreateGroupView()
            .environmentObject(AppRouter())
    }
}
