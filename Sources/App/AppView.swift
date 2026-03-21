import ComposableArchitecture
import SwiftUI

public struct AppView: View {
    let store: StoreOf<AppFeature>

    public init(store: StoreOf<AppFeature>) {
        self.store = store
    }

    public var body: some View {
        NavigationStack {
            if store.isAuthenticated {
                Text("Dashboard")
                    .navigationTitle("Todos")
                    .toolbar {
                        ToolbarItem(placement: .automatic) {
                            Button("Sign Out") {
                                store.send(.login(.logoutButtonTapped))
                            }
                        }
                    }
            } else {
                LoginView(store: store.scope(state: \.login, action: \.login))
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
