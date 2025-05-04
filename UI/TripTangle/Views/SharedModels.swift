//
//  SharedModels.swift
//  TripTangle
//
//  Created by Husen Abughosh on 04/05/2025.
//

// SharedModels.swift
import Foundation

/// Mirrors your backend’s User (minus the password)
public struct AuthenticatedUser: Codable, Identifiable, Hashable {
    public let id: Int
    public let username: String
    public let email: String
    public let bio: String?
    public let profile_pic: String?
    public let current_location: String?
}

/// What POST /users/login returns
public struct AuthLoginResponse: Codable {
    public let accessToken: String
    public let tokenType: String
    public let user: AuthenticatedUser

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType   = "token_type"
        case user
    }
}

/// What you send to POST /groups
public struct GroupCreateRequest: Codable {
    public let name: String
    public let created_by: Int
    public let group_photo: String
    public let is_public: Bool
}

/// What POST /groups returns
public struct GroupOut: Codable, Identifiable {
    public let id: Int
    public let name: String
    public let created_by: Int
    public let group_photo: String
    public let is_public: Bool
    public let created_date: String
}
