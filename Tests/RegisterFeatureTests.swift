import ComposableArchitecture
import Foundation
import Testing

@testable import TodosApp

@MainActor
struct RegisterFeatureTests {
    @Test
    func emailAndPasswordUpdated() async {
        let store = TestStore(initialState: RegisterFeature.State()) {
            RegisterFeature()
        }
        await store.send(.emailChanged("user@example.com")) {
            $0.email = "user@example.com"
        }
        await store.send(.passwordChanged("secret123")) {
            $0.password = "secret123"
        }
    }

    @Test
    func passwordTooShortShowsError() async {
        let store = TestStore(
            initialState: RegisterFeature.State(email: "user@example.com", password: "short")
        ) {
            RegisterFeature()
        }
        await store.send(.registerButtonTapped) {
            $0.errorMessage = "Password must be at least 8 characters."
        }
    }

    @Test
    func successfulRegistrationShowsConfirmation() async {
        let store = TestStore(
            initialState: RegisterFeature.State(email: "user@example.com", password: "password123")
        ) {
            RegisterFeature()
        } withDependencies: {
            $0.apiClient.register = { _, _ in }
        }
        await store.send(.registerButtonTapped) {
            $0.isLoading = true
        }
        await store.receive(\.registerSucceeded) {
            $0.isLoading = false
            $0.isRegistered = true
        }
    }

    @Test
    func duplicateEmailShowsError() async {
        let store = TestStore(
            initialState: RegisterFeature.State(email: "existing@example.com", password: "password123")
        ) {
            RegisterFeature()
        } withDependencies: {
            $0.apiClient.register = { _, _ in throw APIClientError.duplicateEmail }
        }
        await store.send(.registerButtonTapped) {
            $0.isLoading = true
        }
        await store.receive(\.registerFailed) {
            $0.isLoading = false
            $0.errorMessage = "An account with this email already exists."
        }
    }

    @Test
    func networkErrorShowsGenericError() async {
        struct SomeError: Error {}
        let store = TestStore(
            initialState: RegisterFeature.State(email: "user@example.com", password: "password123")
        ) {
            RegisterFeature()
        } withDependencies: {
            $0.apiClient.register = { _, _ in throw SomeError() }
        }
        await store.send(.registerButtonTapped) {
            $0.isLoading = true
        }
        await store.receive(\.registerFailed) {
            $0.isLoading = false
            $0.errorMessage = "Registration failed. Please try again."
        }
    }

    @Test
    func dismissSuccessClearsRegisteredFlag() async {
        let store = TestStore(
            initialState: RegisterFeature.State(isRegistered: true)
        ) {
            RegisterFeature()
        }
        await store.send(.dismissSuccess) {
            $0.isRegistered = false
        }
    }

    @Test
    func changingFieldClearsError() async {
        let store = TestStore(
            initialState: RegisterFeature.State(
                email: "user@example.com",
                password: "short",
                errorMessage: "Password must be at least 8 characters."
            )
        ) {
            RegisterFeature()
        }
        await store.send(.passwordChanged("newpassword")) {
            $0.password = "newpassword"
            $0.errorMessage = nil
        }
    }
}
