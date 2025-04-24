import Foundation
import SwiftUI

public struct AsyncStandardButton: View {
    
    let text: String
    let style: StandardButtonStyle
    let action: () async throws -> Void
    
    @State private var inProgress: Bool = false
    @State private var toast: ToastBarData?
    @Environment(\.standardButtonGroupDisable) @Binding private var groupDisable
    
    public init(
        _ text: String,
        style: StandardButtonStyle,
        action: @escaping () async throws -> Void
    ) {
        self.text = text
        self.style = style
        self.action = action
    }
    
    public var body: some View {
        StandardButton(.text(text), inProgress: inProgress, style: style) {
            // Add delay
            inProgress = true
            groupDisable = true
            Task {
                do {
                    UISelectionFeedbackGenerator().selectionChanged()
                    try await action()
                } catch {
                    UINotificationFeedbackGenerator().notificationOccurred(.error)
                    toast = ToastBarData(error.localizedDescription, type: .failure)
                }
                inProgress = false
                groupDisable = false
            }
        }
        .disabled(groupDisable && !inProgress)
        .snackbar(toastBarData: $toast)
    }
}
