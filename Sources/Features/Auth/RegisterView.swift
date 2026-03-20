import ComposableArchitecture
import SwiftUI

public struct RegisterView: View {
    let store: StoreOf<RegisterFeature>

    public init(store: StoreOf<RegisterFeature>) {
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
                Button(action: { store.send(.registerButtonTapped) }) {
                    HStack {
                        Spacer()
                        if store.isLoading {
                            ProgressView()
                        } else {
                            Text("Create Account")
                        }
                        Spacer()
                    }
                }
                .disabled(store.isLoading || store.email.isEmpty || store.password.isEmpty)
            }
        }
        .navigationTitle("Create Account")
        .alert("Registration Successful", isPresented: Binding(
            get: { store.isRegistered },
            set: { if !$0 { store.send(.dismissSuccess) } }
        )) {
            Button("OK") { store.send(.dismissSuccess) }
        } message: {
            Text("Your account has been created. You can now sign in.")
        }
    }
}

#Preview {
    NavigationStack {
        RegisterView(
            store: Store(initialState: RegisterFeature.State()) {
                RegisterFeature()
            }
        )
    }
}
