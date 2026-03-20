import ComposableArchitecture
import Testing

@testable import TodosApp

@MainActor
struct AppFeatureTests {
    @Test
    func initialState() {
        let store = TestStore(initialState: AppFeature.State()) {
            AppFeature()
        }
        #expect(store.state.isAuthenticated == false)
    }

    @Test
    func authenticationChanged() async {
        let store = TestStore(initialState: AppFeature.State()) {
            AppFeature()
        }
        await store.send(.authenticationChanged(true)) {
            $0.isAuthenticated = true
        }
    }
}
