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
    @Namespace private var glassNamespace

    let model: ChatActionPanelModel
    let onTapScrollToBottom: () -> Void
    let onTapMention: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            if model.showMentions {
                button(asset: .X24.mention, count: model.mentionsCounter) {
                    onTapMention()
                }
                .glassEffectIDIOS26("mention", in: glassNamespace)
            }

            if model.showScrollToBottom {
                button(asset: .X24.Arrow.down, count: model.srollToBottomCounter) {
                    onTapScrollToBottom()
                }
                .glassEffectIDIOS26("scroll", in: glassNamespace)
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
                .frame(width: 40, height: 40)
        }
        .frame(width: 40, height: 40)
        .glassEffectInteractiveIOS26(in: Circle())
        .overlay(alignment: .top) {
            if count > 0 {
                CounterView(count: count)
                    .offset(y: -10)
            }
        }
    }
}
