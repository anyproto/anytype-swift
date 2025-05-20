import SwiftUI
import AsyncAlgorithms

extension View {
    func taskWithMemoryScope(_ action: @escaping @Sendable () async -> Void) -> some View {
        modifier(TaskWithMemoryScopeModifier(action: action))
    }
}

private struct TaskWithMemoryScopeModifier: ViewModifier {
    
    @StateObject private var model: TaskWithMemoryScopeViewModel
    
    init(action: @Sendable @escaping () async -> Void) {
        self._model = StateObject(wrappedValue: TaskWithMemoryScopeViewModel(action: action))
    }
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                model.startIfNeeded()
            }
    }
}

@MainActor
private final class TaskWithMemoryScopeViewModel: ObservableObject {
    
    private var task: Task<Void, Never>?
    private let action: @Sendable () async -> Void
    
    init(action: @Sendable @escaping () async -> Void) {
        self.action = action
    }
    
    // Don't use init. Need to call a method, otherwise viewModel won't be created
    func startIfNeeded() {
        guard task.isNil else { return }
        task = Task { [action] in
            await action()
        }
    }
    
    deinit {
        task?.cancel()
    }
}
