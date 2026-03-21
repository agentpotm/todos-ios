import ComposableArchitecture
import SwiftUI

public struct LoginView: View {
    let store: StoreOf<LoginFeature>

    public init(store: StoreOf<LoginFeature>) {
        self.store = store
    }

    public var body: some View {
        Form {
            Section {
                TextField("Email", text: Binding(
                    get: { store.email },
                    set: { store.send(.emailChanged($0)) }
                ))
                #if os(iOS)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
                #endif
                .autocorrectionDisabled()

                SecureField("Password", text: Binding(
                    get: { store.password },
                    set: { store.send(.passwordChanged($0)) }
                ))
            }

            if let errorMessage = store.errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }

            Section {
                Button(action: { store.send(.loginButtonTapped) }) {
                    HStack {
                        Spacer()
                        if store.isLoading {
                            ProgressView()
                        } else {
                            Text("Sign In")
                        }
                        Spacer()
                    }
                }
                .disabled(store.isLoading || store.email.isEmpty || store.password.isEmpty)
            }
        }
        .navigationTitle("Sign In")
    }
}

#Preview {
    NavigationStack {
        LoginView(
            store: Store(initialState: LoginFeature.State()) {
                LoginFeature()
            }
        )
    }
}
