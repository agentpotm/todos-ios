import ComposableArchitecture
import SwiftUI

public struct AppView: View {
    let store: StoreOf<AppFeature>

    public init(store: StoreOf<AppFeature>) {
        self.store = store
    }

    public var body: some View {
        Group {
            if store.isAuthenticated {
                Text("Dashboard")
                    .navigationTitle("Todos")
            } else {
                Text("Login")
                    .navigationTitle("Sign In")
            }
        }
        .onAppear {
            store.send(.onAppear)
        }
    }
}

#Preview {
    AppView(
        store: Store(initialState: AppFeature.State()) {
            AppFeature()
        }
    )
}
