import Combine
import Foundation

@MainActor
public final class LoginViewModel: ObservableObject {
    @Published public private(set) var state: LoginState

    private let authService: AuthService
    private let networkMonitor: NetworkMonitor
    private let tokenStore: TokenStore

    public init(
        state: LoginState = LoginState(),
        authService: AuthService,
        networkMonitor: NetworkMonitor,
        tokenStore: TokenStore
    ) {
        self.state = state
        self.authService = authService
        self.networkMonitor = networkMonitor
        self.tokenStore = tokenStore
    }

    public func updateEmail(_ email: String) {
        state.email = email.trimmingCharacters(in: .whitespacesAndNewlines)
        state.errorMessage = nil
    }

    public func updatePassword(_ password: String) {
        state.password = password
        state.errorMessage = nil
    }

    public func setRememberMe(_ rememberMe: Bool) {
        state.rememberMe = rememberMe
    }

    public func consumeNavigationEvent() {
        state.navigationEvent = nil
    }

    public func login() async {
        guard !state.isLockedOut else {
            state.errorMessage = .lockedOut
            return
        }

        guard state.canSubmit else {
            return
        }

        guard await networkMonitor.isOnline else {
            state.errorMessage = .offline
            return
        }

        state.isLoading = true
        state.errorMessage = nil

        do {
            let token = try await authService.login(email: state.email, password: state.password)
            state.isLoading = false
            state.failureCount = 0
            if state.rememberMe {
                await tokenStore.save(token: token)
            }
            state.navigationEvent = .authenticated
        } catch AuthError.invalidCredentials {
            recordFailure(message: .invalidCredentials)
        } catch {
            recordFailure(message: .unknown)
        }
    }

    private func recordFailure(message: LoginErrorMessage) {
        state.isLoading = false
        state.failureCount += 1
        state.errorMessage = state.isLockedOut ? .lockedOut : message
    }
}
