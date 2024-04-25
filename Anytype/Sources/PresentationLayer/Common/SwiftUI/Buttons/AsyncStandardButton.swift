import Foundation
import SwiftUI

struct AsyncStandardButton: View {
    
    let text: String
    let style: StandardButtonStyle
    let action: () async throws -> Void
    
    @State private var inProgress: Bool = false
    @State private var toast = ToastBarData.empty
    @Environment(\.standardButtonGroupDisable) @Binding private var groupDisable
    
    var body: some View {
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
                    toast = ToastBarData(text: error.localizedDescription, showSnackBar: true, messageType: .failure)
                }
                inProgress = false
                groupDisable = false
            }
        }
        .disabled(groupDisable && !inProgress)
        .snackbar(toastBarData: $toast)
    }
}
