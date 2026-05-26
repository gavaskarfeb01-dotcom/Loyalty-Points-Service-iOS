import Foundation

public struct AuthToken: Equatable, Sendable {
    public let value: String

    public init(value: String) {
        self.value = value
    }
}

public enum AuthError: Error, Equatable, Sendable {
    case invalidCredentials
    case serviceUnavailable
}

public protocol AuthService: Sendable {
    func login(email: String, password: String) async throws -> AuthToken
}

public protocol TokenStore: Sendable {
    func save(token: AuthToken) async
    func savedToken() async -> AuthToken?
}

public actor UserDefaultsTokenStore: TokenStore {
    private let defaults: UserDefaults
    private let key: String

    public init(defaults: UserDefaults = .standard, key: String = "loyalty.auth.token") {
        self.defaults = defaults
        self.key = key
    }

    public func save(token: AuthToken) async {
        defaults.set(token.value, forKey: key)
    }

    public func savedToken() async -> AuthToken? {
        guard let value = defaults.string(forKey: key), !value.isEmpty else {
            return nil
        }
        return AuthToken(value: value)
    }
}
