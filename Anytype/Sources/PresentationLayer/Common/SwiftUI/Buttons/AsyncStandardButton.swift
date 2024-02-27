import Foundation
import SwiftUI

struct AsyncStandardButton: View {
    
    let text: String
    let style: StandardButtonStyle
    let action: () async throws -> Void
    
    @State private var inProgress: Bool = false
    @State private var toast = ToastBarData.empty
    
    var body: some View {
        StandardButton(.text(text), inProgress: inProgress, style: style) {
            // Add delay
            inProgress = true
            Task {
                do {
                    try await action()
                } catch {
                    toast = ToastBarData(text: error.localizedDescription, showSnackBar: true, messageType: .failure)
                }
                inProgress = false
            }
        }
    }
}
