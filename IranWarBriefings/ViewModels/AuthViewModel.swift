import Foundation
import FirebaseAuth

final class AuthViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private var authStateHandle: AuthStateDidChangeListenerHandle?

    init() {
        currentUser = Auth.auth().currentUser
        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.currentUser = user
            }
        }
    }

    deinit {
        if let authStateHandle {
            Auth.auth().removeStateDidChangeListener(authStateHandle)
        }
    }

    func signIn(email: String, password: String) async {
        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalizedEmail.isEmpty, !password.isEmpty else {
            await MainActor.run {
                errorMessage = "Please enter both email and password."
            }
            return
        }

        await setLoadingState(true)
        do {
            _ = try await Auth.auth().signIn(withEmail: normalizedEmail, password: password)
            await MainActor.run {
                errorMessage = nil
            }
        } catch {
            await MainActor.run {
                errorMessage = message(for: error)
            }
        }
        await setLoadingState(false)
    }

    func signUp(email: String, password: String) async {
        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalizedEmail.isEmpty, !password.isEmpty else {
            await MainActor.run {
                errorMessage = "Please enter both email and password."
            }
            return
        }

        await setLoadingState(true)
        do {
            _ = try await Auth.auth().createUser(withEmail: normalizedEmail, password: password)
            await MainActor.run {
                errorMessage = nil
            }
        } catch {
            await MainActor.run {
                errorMessage = message(for: error)
            }
        }
        await setLoadingState(false)
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            errorMessage = nil
        } catch {
            errorMessage = message(for: error)
        }
    }

    private func setLoadingState(_ isLoading: Bool) async {
        await MainActor.run {
            self.isLoading = isLoading
            if isLoading {
                errorMessage = nil
            }
        }
    }

    private func message(for error: Error) -> String {
        let nsError = error as NSError
        guard let code = AuthErrorCode(rawValue: nsError.code) else {
            return "Something went wrong. Please try again."
        }

        switch code {
        case .invalidEmail:
            return "Please enter a valid email address."
        case .wrongPassword, .userNotFound, .invalidCredential:
            return "Incorrect email or password."
        case .emailAlreadyInUse:
            return "This email is already in use."
        case .weakPassword:
            return "Password should be at least 6 characters."
        case .networkError:
            return "Network error. Check your connection and try again."
        default:
            return "Something went wrong. Please try again."
        }
    }
}
