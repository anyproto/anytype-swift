import Foundation
import SwiftUI

public struct AsyncButton<Label> : View where Label : View {
    
    let action: () async throws -> Void
    let label: Label
    let role: ButtonRole?
    
    @State private var toast: ToastBarData?
    
    public init(role: ButtonRole? = nil, action: @escaping () async throws -> Void, @ViewBuilder label: () -> Label) {
        self.action = action
        self.role = role
        self.label = label()
    }
    
    public var body: some View {
        Button(role: role) {
            Task {
                do {
                    try await action()
                } catch {
                    toast = ToastBarData(error.localizedDescription, type: .failure)
                }
            }
        } label: {
            label
        }
        .snackbar(toastBarData: $toast)
    }
}

public extension AsyncButton where Label == Text {
    init(_ titleKey: String, role: ButtonRole? = nil, action: @escaping () async throws -> Void) {
        self = AsyncButton(role: role, action: action, label: {
            Text(titleKey)
        })
    }
}
