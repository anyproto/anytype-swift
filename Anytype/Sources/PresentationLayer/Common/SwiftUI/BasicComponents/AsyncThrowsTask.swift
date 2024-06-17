import Foundation
import SwiftUI

fileprivate struct AsyncThrowsTaskModifier: ViewModifier {
    
    let action: @Sendable () async throws -> Void
    @State private var toast: ToastBarData = .empty
    
    func body(content: Content) -> some View {
        content
            .task {
                do {
                    try await action()
                } catch {
                    toast = ToastBarData(text: error.localizedDescription, showSnackBar: true, messageType: .failure)
                }
            }
    }
}

fileprivate struct AsyncThrowsIdTaskModifier<T: Equatable>: ViewModifier {
    
    let id: T
    let action: @Sendable () async throws -> Void
    @State private var toast: ToastBarData = .empty
    
    func body(content: Content) -> some View {
        content
            .task(id: id) {
                do {
                    try await action()
                } catch {
                    toast = ToastBarData(text: error.localizedDescription, showSnackBar: true, messageType: .failure)
                }
            }
    }
}

extension View {
    func throwingTask(_ action: @escaping @Sendable () async throws -> Void) -> some View {
        modifier(AsyncThrowsTaskModifier(action: action))
    }
    
    func throwingTask<T: Equatable>(id: T, _ action: @escaping @Sendable () async throws -> Void) -> some View {
        modifier(AsyncThrowsIdTaskModifier(id: id, action: action))
    }
}
