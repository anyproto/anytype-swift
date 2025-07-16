import Foundation
import SwiftUI

public struct AsyncButton<Label> : View where Label : View {
    
    let action: @Sendable () async throws -> Void
    let label: Label
    let role: ButtonRole?
    
    @State private var taskId: UUID?
    @State private var disable = false
    
    public init(role: ButtonRole? = nil, action: @Sendable @escaping @MainActor () async throws -> Void, @ViewBuilder label: () -> Label) {
        self.action = action
        self.role = role
        self.label = label()
    }
    
    public var body: some View {
        Button(role: role) {
            taskId = UUID()
        } label: {
            label
        }
        .throwingTask(id: taskId) {
            guard taskId.isNotNil else { return }
            defer { taskId = nil }
            do {
                disable = true
                defer { disable = false }
                try await action()
            } catch {
                throw error
            }
        }
        .disabled(disable)
    }
}

public extension AsyncButton where Label == Text {
    init(_ titleKey: String, role: ButtonRole? = nil, action: @Sendable @escaping @MainActor () async throws -> Void) {
        self = AsyncButton(role: role, action: action, label: {
            Text(titleKey)
        })
    }
}
