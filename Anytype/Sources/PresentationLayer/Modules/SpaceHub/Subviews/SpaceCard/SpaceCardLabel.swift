import SwiftUI
import AnytypeCore

// SpaceCardLabel and SpaceCard are splitted for better SwiftUI diff.
struct SpaceCardLabel: View {

    let model: SpaceCardModel
    @Binding var draggedSpaceViewId: String?

    @Namespace private var namespace

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            IconView(icon: model.objectIconImage)
                .frame(width: 56, height: 56)
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text(model.nameWithPlaceholder)
                        .anytypeFontStyle(.bodySemibold)
                        .lineLimit(1)
                        .foregroundStyle(Color.Text.primary)
                    if model.isMuted {
                        Spacer.fixedWidth(8)
                        Image(asset: .X18.muted).foregroundColor(.Control.secondary)
                    }
                    Spacer(minLength: 8)
                    createdDate
                }
                HStack {
                    info
                    Spacer()
                    unreadCounters
                    pin
                }
                Spacer(minLength: 1)
            }
            .matchedGeometryEffect(id: "content", in: namespace, properties: .position, anchor: .topLeading)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        // Optimization for fast sizeThatFits
        .frame(height: 80)
        .background(Color.Background.primary)
        .contentShape([.dragPreview, .contextMenuPreview], RoundedRectangle(cornerRadius: 20, style: .continuous))
        .onDragIf(model.isPinned) {
            draggedSpaceViewId = model.spaceViewId
            return NSItemProvider()
        } preview: {
            EmptyView()
        }
    }

    private var info: some View {
        Group {
            if let lastMessage = model.lastMessage {
                SpaceCardLastMessageView(model: lastMessage)
            } else {
                Text(model.uxTypeName)
                    .anytypeStyle(.uxTitle2Regular)
                    .lineLimit(1)
            }
        }
        .foregroundStyle(Color.Text.secondary)
        .multilineTextAlignment(.leading)
    }


    @ViewBuilder
    private var createdDate: some View {
        if let lastMessage = model.lastMessage {
            Text(lastMessage.historyDate)
                .anytypeStyle(.relation2Regular)
                .foregroundStyle(Color.Control.transparentSecondary)
        }
    }

    private var unreadCounters: some View {
        HStack(spacing: 4) {
            if model.mentionCounter > 0 {
                MentionBadge(style: model.isMuted ? .muted : .highlighted)
            }
            if model.unreadCounter > 0 {
                CounterView(
                    count: model.unreadCounter,
                    style: model.isMuted ? .muted : .highlighted
                )
            }
        }
    }

    @ViewBuilder
    private var pin: some View {
        if !model.hasCounters && model.isPinned {
            Image(asset: .X18.pin)
                .foregroundStyle(Color.Control.secondary)
                .frame(width: 18, height: 18)
        }
    }
}
