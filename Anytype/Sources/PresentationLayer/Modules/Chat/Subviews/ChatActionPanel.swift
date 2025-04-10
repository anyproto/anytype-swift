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
                button(asset: .X24.mention, count: model.mentionsCounter) {
                    onTapMention()
                }
            }
            
            if model.showScrollToBottom {
                button(asset: .X24.Arrow.down, count: model.srollToBottomCounter) {
                    onTapScrollToBottom()
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }
    
    private func button(asset: ImageAsset, count: Int, action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            Image(asset: asset)
                .frame(width: 48, height: 48)
                .background(Color.Background.navigationPanel)
                .background(.ultraThinMaterial)
                .cornerRadius(16)
                .overlay(alignment: .topTrailing) {
                    if count > 0 {
                        CounterView(count: count)
                            .offset(x: 6, y: -6)
                    }
                }
        }
        .buttonStyle(.plain)
    }
}
