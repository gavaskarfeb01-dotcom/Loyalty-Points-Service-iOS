import XCTest
@testable import LoyaltyPointsServiceIOS

@MainActor
final class LoginViewModelTests: XCTestCase {
    func testValidationEnablesAndDisablesSubmit() {
        let viewModel = makeViewModel()

        XCTAssertFalse(viewModel.state.canSubmit)

        viewModel.updateEmail("bad-email")
        viewModel.updatePassword("123")
        XCTAssertFalse(viewModel.state.canSubmit)

        viewModel.updateEmail("traveler@example.com")
        viewModel.updatePassword("secret1")
        XCTAssertTrue(viewModel.state.canSubmit)
    }

    func testSuccessEmitsNavigationEvent() async {
        let auth = MockAuthService(result: .success(AuthToken(value: "token-123")))
        let viewModel = makeViewModel(authService: auth)
        viewModel.updateEmail("traveler@example.com")
        viewModel.updatePassword("secret1")

        await viewModel.login()

        XCTAssertEqual(viewModel.state.navigationEvent, .authenticated)
        XCTAssertEqual(await auth.callCount, 1)
    }

    func testErrorIncrementsFailureCount() async {
        let auth = MockAuthService(result: .failure(AuthError.invalidCredentials))
        let viewModel = makeViewModel(authService: auth)
        viewModel.updateEmail("traveler@example.com")
        viewModel.updatePassword("wrong1")

        await viewModel.login()

        XCTAssertEqual(viewModel.state.failureCount, 1)
        XCTAssertEqual(viewModel.state.errorMessage, .invalidCredentials)
    }

    func testLockoutAfterThreeFailures() async {
        let auth = MockAuthService(result: .failure(AuthError.invalidCredentials))
        let viewModel = makeViewModel(authService: auth)
        viewModel.updateEmail("traveler@example.com")
        viewModel.updatePassword("wrong1")

        await viewModel.login()
        await viewModel.login()
        await viewModel.login()

        XCTAssertTrue(viewModel.state.isLockedOut)
        XCTAssertFalse(viewModel.state.canSubmit)
        XCTAssertEqual(viewModel.state.errorMessage, .lockedOut)
        XCTAssertEqual(await auth.callCount, 3)

        await viewModel.login()
        XCTAssertEqual(await auth.callCount, 3, "Locked out users must not trigger another service call")
    }

    func testOfflineShowsMessageAndDoesNotCallService() async {
        let auth = MockAuthService(result: .success(AuthToken(value: "token-123")))
        let viewModel = makeViewModel(
            authService: auth,
            networkMonitor: MockNetworkMonitor(isOnline: false)
        )
        viewModel.updateEmail("traveler@example.com")
        viewModel.updatePassword("secret1")

        await viewModel.login()

        XCTAssertEqual(viewModel.state.errorMessage, .offline)
        XCTAssertEqual(await auth.callCount, 0)
    }

    func testRememberMePersistsToken() async {
        let tokenStore = InMemoryTokenStore()
        let viewModel = makeViewModel(
            authService: MockAuthService(result: .success(AuthToken(value: "token-123"))),
            tokenStore: tokenStore
        )
        viewModel.updateEmail("traveler@example.com")
        viewModel.updatePassword("secret1")
        viewModel.setRememberMe(true)

        await viewModel.login()

        XCTAssertEqual(await tokenStore.savedToken(), AuthToken(value: "token-123"))
    }

    private func makeViewModel(
        authService: MockAuthService = MockAuthService(result: .success(AuthToken(value: "token-123"))),
        networkMonitor: MockNetworkMonitor = MockNetworkMonitor(isOnline: true),
        tokenStore: InMemoryTokenStore = InMemoryTokenStore()
    ) -> LoginViewModel {
        LoginViewModel(
            authService: authService,
            networkMonitor: networkMonitor,
            tokenStore: tokenStore
        )
    }
}

private actor MockAuthService: AuthService {
    private let result: Result<AuthToken, Error>
    private(set) var callCount = 0

    init(result: Result<AuthToken, Error>) {
        self.result = result
    }

    func login(email: String, password: String) async throws -> AuthToken {
        callCount += 1
        return try result.get()
    }
}

private actor MockNetworkMonitor: NetworkMonitor {
    private let online: Bool

    init(isOnline: Bool) {
        self.online = isOnline
    }

    var isOnline: Bool {
        online
    }
}

private actor InMemoryTokenStore: TokenStore {
    private var token: AuthToken?

    func save(token: AuthToken) async {
        self.token = token
    }

    func savedToken() async -> AuthToken? {
        token
    }
}
