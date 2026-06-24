import SwiftUI

struct ChatActionPanelModel: Equatable {
    let showScrollToBottom: Bool
    let srollToBottomCounter: Int
    let showMentions: Bool
    let mentionsCounter: Int
    let showReactions: Bool
}

extension ChatActionPanelModel {
    static let hidden = ChatActionPanelModel(showScrollToBottom: false, srollToBottomCounter: 0, showMentions: false, mentionsCounter: 0, showReactions: false)
}

struct ChatActionPanelView: View {
    @Namespace private var glassNamespace

    let model: ChatActionPanelModel
    let onTapScrollToBottom: () -> Void
    let onTapMention: () -> Void
    let onTapReaction: () -> Void

    var body: some View {
        GlassEffectContainerIOS26(spacing: 6) {
            VStack(spacing: 12) {
                if model.showReactions {
                    button(systemName: "heart", count: 0) {
                        onTapReaction()
                    }
                    .glassEffectIDIOS26("reaction", in: glassNamespace)
                }

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
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    private func button(asset: ImageAsset, count: Int, action: @escaping () -> Void) -> some View {
        buttonContent(count: count, action: action) {
            Image(asset: asset)
                .frame(width: 40, height: 40)
        }
    }

    private func button(systemName: String, count: Int, action: @escaping () -> Void) -> some View {
        buttonContent(count: count, action: action) {
            Image(systemName: systemName)
                .font(.system(size: 18, weight: .medium))
                .frame(width: 40, height: 40)
        }
    }

    private func buttonContent<Label: View>(count: Int, action: @escaping () -> Void, @ViewBuilder label: () -> Label) -> some View {
        Button {
            action()
        } label: {
            label()
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

extension ChatActionPanelView: Equatable {
    // Re-render only when the panel's data changes; the tap closures are recreated
    // every parent body pass but are behaviourally stable, so they're excluded.
    nonisolated static func == (lhs: ChatActionPanelView, rhs: ChatActionPanelView) -> Bool {
        lhs.model == rhs.model
    }
}
