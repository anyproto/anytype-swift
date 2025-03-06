import SwiftUI

struct ChatActionPanelModel {
    let showScrollToBottom: Bool
    let srollToBottomCounter: Int
    let showMentions: Bool
    let mentionsCounter: Int
}

extension ChatActionPanelModel {
    static let hidden = ChatActionPanelModel(showScrollToBottom: false, srollToBottomCounter: 0, showMentions: false, mentionsCounter: 0)
}

struct ChatActionPanelView: View {
    let model: ChatActionPanelModel
    let onTapScrollToBottom: () -> Void
    let onTapMention: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            
            if model.showMentions {
                button(asset: .X24.mention, text: "\(model.mentionsCounter)") {
                    onTapMention()
                }
            }
            
            if model.showScrollToBottom {
                button(asset: .X24.Arrow.down, text: "\(model.srollToBottomCounter)") {
                    onTapScrollToBottom()
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }
    
    private func button(asset: ImageAsset, text: String, action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            Image(asset: asset)
                .frame(width: 48, height: 48)
                .background(Color.Background.navigationPanel)
                .background(.ultraThinMaterial)
                .cornerRadius(16)
                .overlay(alignment: .topTrailing) {
                    Text(text)
                        .anytypeStyle(.caption1Regular)
                        .foregroundStyle(Color.Control.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 1)
                        .background(
                            Capsule()
                                .fill(Color.Control.transparentActive)
                                .background(.ultraThinMaterial)
                                .clipShape(Capsule()) // From iOS 17: Delete clip and use .fill for material
                        )
                        .offset(x: 6, y: -6)
                }
        }
    }
}
