// SharedServices.swift
import Foundation

// ——— AuthService ———
public enum AuthError: LocalizedError {
    case invalidCredentials, serverError(String), unknown
    public var errorDescription: String? {
        switch self {
        case .invalidCredentials: return "Invalid email or password."
        case .serverError(let msg): return msg
        case .unknown: return "Unknown error."
        }
    }
}

public final class AuthService {
    public static let shared = AuthService()
    private let baseURL = URL(string: "http://127.0.0.1:8000")!
    private init() {}

    public func login(email: String, password: String) async throws -> AuthLoginResponse {
        let url = baseURL.appendingPathComponent("/users/login")
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONEncoder().encode(["email": email, "password": password])

        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse else { throw AuthError.unknown }
        switch http.statusCode {
        case 200:
            return try JSONDecoder().decode(AuthLoginResponse.self, from: data)
        case 401:
            throw AuthError.invalidCredentials
        default:
            let msg = String(data: data, encoding: .utf8) ?? "Server error"
            throw AuthError.serverError(msg)
        }
    }
}

// ——— UserService ———
public enum UserServiceError: LocalizedError {
    case missingAuth, serverError(String), unknown
    public var errorDescription: String? {
        switch self {
        case .missingAuth: return "Not logged in."
        case .serverError(let m): return m
        case .unknown: return "Unknown error."
        }
    }
}

public final class UserService {
    public static let shared = UserService()
    private let baseURL = URL(string: "http://127.0.0.1:8000")!
    private init() {}

    public func searchUsers(query: String, currentUserID: Int) async throws -> [AuthenticatedUser] {
        var comps = URLComponents(url: baseURL.appendingPathComponent("users/search/"), resolvingAgainstBaseURL: false)!
        comps.queryItems = [
            .init(name: "query", value: query),
            .init(name: "current_user_id", value: String(currentUserID))
        ]
        let (data, resp) = try await URLSession.shared.data(from: comps.url!)
        guard let http = resp as? HTTPURLResponse else { throw UserServiceError.unknown }
        switch http.statusCode {
        case 200:
            return try JSONDecoder().decode([AuthenticatedUser].self, from: data)
        default:
            let msg = String(data: data, encoding: .utf8) ?? "Server error"
            throw UserServiceError.serverError(msg)
        }
    }
}

// ——— GroupService ———
public enum GroupServiceError: LocalizedError {
    case missingAuth, serverError(String), decodingError, unknown
    public var errorDescription: String? {
        switch self {
        case .missingAuth: return "Not logged in."
        case .serverError(let m): return m
        case .decodingError: return "Bad server response."
        case .unknown: return "Unknown error."
        }
    }
}

public final class GroupService {
    public static let shared = GroupService()
    private let baseURL = URL(string: "http://127.0.0.1:8000")!
    private init() {}

    public func createGroup(_ reqBody: GroupCreateRequest) async throws -> GroupOut {
        guard let token = UserDefaults.standard.string(forKey: "authToken") else {
            throw GroupServiceError.missingAuth
        }
        var req = URLRequest(url: baseURL.appendingPathComponent("/groups/groups/"))
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        req.httpBody = try JSONEncoder().encode(reqBody)

        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse else { throw GroupServiceError.unknown }
        switch http.statusCode {
        case 200...299:
            return try JSONDecoder().decode(GroupOut.self, from: data)
        default:
            let msg = String(data: data, encoding: .utf8) ?? "Server error"
            throw GroupServiceError.serverError(msg)
        }
    }
}
