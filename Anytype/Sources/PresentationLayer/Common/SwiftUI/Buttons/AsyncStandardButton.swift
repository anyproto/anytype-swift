import Foundation
import SwiftUI

struct AsyncStandardButton: View {
    
    let text: String
    let style: StandardButtonStyle
    let action: () async throws -> Void
    
    @State private var inProgress: Bool = false
    
    var body: some View {
        StandardButton(.text(text), inProgress: inProgress, style: style) {
            // Add delay
            inProgress = true
            Task {
                do {
                    try await action()
                } catch {}
                inProgress = false
            }
        }
    }
}
