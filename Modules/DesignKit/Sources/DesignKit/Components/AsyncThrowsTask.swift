import Foundation
import SwiftUI

fileprivate struct AsyncThrowsTaskModifier: ViewModifier {
    
    let action: @Sendable @MainActor () async throws -> Void
    @State private var toast: ToastBarData?
    
    func body(content: Content) -> some View {
        content
            .task {
                do {
                    try await action()
                } catch {
                    toast = ToastBarData(error.localizedDescription, type: .failure)
                }
            }
    }
}

fileprivate struct AsyncThrowsIdTaskModifier<T: Equatable>: ViewModifier {
    
    let id: T
    let action: @Sendable () async throws -> Void
    @State private var toast: ToastBarData?
    
    func body(content: Content) -> some View {
        content
            .task(id: id) {
                do {
                    try await action()
                } catch {
                    toast = ToastBarData(error.localizedDescription, type: .failure)
                }
            }
    }
}

public extension View {
    func throwingTask(_ action: @escaping @Sendable @MainActor () async throws -> Void) -> some View {
        modifier(AsyncThrowsTaskModifier(action: action))
    }
    
    func throwingTask<T: Equatable>(id: T, _ action: @escaping @Sendable @MainActor () async throws -> Void) -> some View {
        modifier(AsyncThrowsIdTaskModifier(id: id, action: action))
    }
    
    func task<Item: Equatable>(item: Item?, _ action: @escaping @Sendable (Item) async -> Void) -> some View {
        self.task(id: item) {
            guard let item else { return }
            await action(item)
        }
    }
}
