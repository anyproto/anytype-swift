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

extension View {
    func throwTask(_ action: @escaping @Sendable () async -> Void) -> some View {
        modifier(AsyncThrowsTaskModifier(action: action))
    }
}
