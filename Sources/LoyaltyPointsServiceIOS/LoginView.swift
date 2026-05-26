import SwiftUI

public struct LoginView: View {
    @ObservedObject private var viewModel: LoginViewModel
    private let onAuthenticated: () -> Void

    public init(viewModel: LoginViewModel, onAuthenticated: @escaping () -> Void) {
        self.viewModel = viewModel
        self.onAuthenticated = onAuthenticated
    }

    public var body: some View {
        VStack(spacing: 16) {
            Text("Loyalty Login")
                .font(.title.bold())

            TextField("Email", text: Binding(
                get: { viewModel.state.email },
                set: { viewModel.updateEmail($0) }
            ))
            .autocorrectionDisabled()
            .textFieldStyle(.roundedBorder)

            SecureField("Password", text: Binding(
                get: { viewModel.state.password },
                set: { viewModel.updatePassword($0) }
            ))
            .textFieldStyle(.roundedBorder)

            Toggle("Remember me", isOn: Binding(
                get: { viewModel.state.rememberMe },
                set: { viewModel.setRememberMe($0) }
            ))

            if let errorMessage = viewModel.state.errorMessage {
                Text(errorMessage.rawValue)
                    .foregroundStyle(.red)
                    .font(.footnote)
                    .accessibilityIdentifier("login-error-message")
            }

            Button {
                Task { await viewModel.login() }
            } label: {
                if viewModel.state.isLoading {
                    ProgressView()
                } else {
                    Text(viewModel.state.isLockedOut ? "Locked" : "Login")
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(!viewModel.state.canSubmit)
            .accessibilityIdentifier("login-submit-button")
        }
        .padding()
        .onChange(of: viewModel.state.navigationEvent) { event in
            if event == .authenticated {
                onAuthenticated()
                viewModel.consumeNavigationEvent()
            }
        }
    }
}
