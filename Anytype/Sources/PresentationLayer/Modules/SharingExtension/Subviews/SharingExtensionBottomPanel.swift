import SwiftUI
import Loc

struct SharingExtensionBottomPanel: View {
    
    @Binding var comment: String
    let commentLimit: Int
    let commentWarningLimit: Int
    let onTapSend: () async throws -> Void
    
    var body: some View {
        VStack(spacing: 10) {
            MultilineLimitTextField(
                placeholder: Loc.Sharing.inputPlaceholder,
                limit: commentLimit,
                warningLimit: commentWarningLimit,
                text: $comment
            )
            AsyncStandardButton(Loc.send, style: .primaryLarge) {
                try await onTapSend()
            }
            .disabled(comment.count > commentLimit)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.Background.secondary)
    }
}
