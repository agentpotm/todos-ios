import ComposableArchitecture
import Foundation
import Testing

@testable import TodosApp

@MainActor
struct LoginFeatureTests {
    @Test
    func emailAndPasswordUpdated() async {
        let store = TestStore(initialState: LoginFeature.State()) {
            LoginFeature()
        }
        await store.send(.emailChanged("user@example.com")) {
            $0.email = "user@example.com"
        }
        await store.send(.passwordChanged("secret123")) {
            $0.password = "secret123"
        }
    }

    @Test
    func successfulLoginSetsLoggedInAndSavesToken() async {
        let savedTokens = LockIsolated([String]())
        let store = TestStore(
            initialState: LoginFeature.State(email: "user@example.com", password: "password123")
        ) {
            LoginFeature()
        } withDependencies: {
            $0.apiClient.login = { _, _ in "auth-token-abc" }
            $0.keychainClient.saveToken = { token in savedTokens.withValue { $0.append(token) } }
        }
        await store.send(.loginButtonTapped) {
            $0.isLoading = true
        }
        await store.receive(\.loginSucceeded) {
            $0.isLoading = false
            $0.isLoggedIn = true
        }
        #expect(savedTokens.value == ["auth-token-abc"])
    }

    @Test
    func invalidCredentialsShowsError() async {
        let store = TestStore(
            initialState: LoginFeature.State(email: "user@example.com", password: "wrongpass")
        ) {
            LoginFeature()
        } withDependencies: {
            $0.apiClient.login = { _, _ in throw APIClientError.unauthorized }
        }
        await store.send(.loginButtonTapped) {
            $0.isLoading = true
        }
        await store.receive(\.loginFailed) {
            $0.isLoading = false
            $0.errorMessage = "Invalid email or password."
        }
    }

    @Test
    func networkErrorShowsGenericError() async {
        struct SomeError: Error {}
        let store = TestStore(
            initialState: LoginFeature.State(email: "user@example.com", password: "password123")
        ) {
            LoginFeature()
        } withDependencies: {
            $0.apiClient.login = { _, _ in throw SomeError() }
        }
        await store.send(.loginButtonTapped) {
            $0.isLoading = true
        }
        await store.receive(\.loginFailed) {
            $0.isLoading = false
            $0.errorMessage = "Login failed. Please try again."
        }
    }

    @Test
    func logoutClearsLoggedInAndDeletesToken() async {
        let deleteCalled = LockIsolated(false)
        let store = TestStore(
            initialState: LoginFeature.State(isLoggedIn: true)
        ) {
            LoginFeature()
        } withDependencies: {
            $0.keychainClient.deleteToken = { deleteCalled.setValue(true) }
        }
        await store.send(.logoutButtonTapped) {
            $0.isLoggedIn = false
        }
        await store.receive(\.logoutCompleted)
        #expect(deleteCalled.value == true)
    }

    @Test
    func changingFieldClearsError() async {
        let store = TestStore(
            initialState: LoginFeature.State(
                email: "user@example.com",
                password: "pass",
                errorMessage: "Invalid email or password."
            )
        ) {
            LoginFeature()
        }
        await store.send(.emailChanged("other@example.com")) {
            $0.email = "other@example.com"
            $0.errorMessage = nil
        }
    }
}
