import SwiftUI

struct AuthView: View {
    @ObservedObject var viewModel: AuthViewModel

    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var mode: Mode = .login
    @State private var localErrorMessage: String?

    private enum Mode {
        case login
        case signup

        var title: String {
            switch self {
            case .login:
                return "Log in"
            case .signup:
                return "Create account"
            }
        }

        var secondaryActionLabel: String {
            switch self {
            case .login:
                return "Need an account? Sign up"
            case .signup:
                return "Already have an account? Log in"
            }
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Iran Briefings")
                    .font(.largeTitle.bold())

                VStack(spacing: 12) {
                    TextField("Email", text: $email)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                        .padding(12)
                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 10))

                    SecureField("Password", text: $password)
                        .textContentType(mode == .signup ? .newPassword : .password)
                        .padding(12)
                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 10))

                    if mode == .signup {
                        SecureField("Confirm password", text: $confirmPassword)
                            .textContentType(.newPassword)
                            .padding(12)
                            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 10))
                    }
                }

                if let message = localErrorMessage ?? viewModel.errorMessage {
                    Text(message)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                }

                Button {
                    Task {
                        await handlePrimaryAction()
                    }
                } label: {
                    if viewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text(mode.title)
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.isLoading)

                Button(mode.secondaryActionLabel) {
                    toggleMode()
                }
                .buttonStyle(.plain)
            }
            .padding()
            .navigationTitle("Authentication")
        }
    }

    private func toggleMode() {
        mode = mode == .login ? .signup : .login
        localErrorMessage = nil
        viewModel.errorMessage = nil
        password = ""
        confirmPassword = ""
    }

    private func handlePrimaryAction() async {
        localErrorMessage = nil

        if mode == .signup {
            guard password == confirmPassword else {
                localErrorMessage = "Passwords do not match."
                return
            }
            await viewModel.signUp(email: email, password: password)
            return
        }

        await viewModel.signIn(email: email, password: password)
    }
}

