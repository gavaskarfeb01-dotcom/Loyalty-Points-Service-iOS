import Foundation

public enum LoginErrorMessage: String, Equatable, Sendable {
    case offline = "You appear to be offline. Check your connection and try again."
    case invalidCredentials = "Email or password is incorrect."
    case lockedOut = "Too many failed attempts. Please try again later."
    case unknown = "Something went wrong. Please try again."
}

public enum LoginNavigationEvent: Equatable, Sendable {
    case authenticated
}

public struct LoginState: Equatable, Sendable {
    public var email: String
    public var password: String
    public var rememberMe: Bool
    public var isLoading: Bool
    public var failureCount: Int
    public var errorMessage: LoginErrorMessage?
    public var navigationEvent: LoginNavigationEvent?

    public init(
        email: String = "",
        password: String = "",
        rememberMe: Bool = false,
        isLoading: Bool = false,
        failureCount: Int = 0,
        errorMessage: LoginErrorMessage? = nil,
        navigationEvent: LoginNavigationEvent? = nil
    ) {
        self.email = email
        self.password = password
        self.rememberMe = rememberMe
        self.isLoading = isLoading
        self.failureCount = failureCount
        self.errorMessage = errorMessage
        self.navigationEvent = navigationEvent
    }

    public var isLockedOut: Bool {
        failureCount >= 3
    }

    public var isEmailValid: Bool {
        email.contains("@") && email.contains(".")
    }

    public var isPasswordValid: Bool {
        password.count >= 6
    }

    public var canSubmit: Bool {
        isEmailValid && isPasswordValid && !isLoading && !isLockedOut
    }
}
