import Foundation
import SwiftUI

struct MessageView: View {
    let data: MessageViewData
    weak var output: (any MessageModuleOutput)?
    
    var body: some View {
        MessageInternalView(data: data, output: output)
            .id(data.message.id)
    }
}

private struct MessageInternalView: View {
        
    private let data: MessageViewData
    @StateObject private var model: MessageViewModel
    
    @State private var contentSize: CGSize = .zero
    @State private var headerSize: CGSize = .zero
    
    init(
        data: MessageViewData,
        output: (any MessageModuleOutput)? = nil
    ) {
        self.data = data
        self._model = StateObject(wrappedValue: MessageViewModel(data: data, output: output))
    }
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            leadingView
            content
            trailingView
        }
        .padding(.horizontal, 8)
        .onChange(of: data) {
            model.update(data: $0)
        }
    }
    
    private var messageBackgorundColor: Color {
        return model.isYourMessage ? Color.VeryLight.green : Color.VeryLight.grey
    }
    
    private var content: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 10) {
                Text(model.author)
                    .anytypeStyle(.previewTitle2Medium)
                    .foregroundColor(.Text.primary)
                    .lineLimit(1)
            
                Text(model.date)
                    .anytypeStyle(.caption1Regular)
                    .foregroundColor(.Text.secondary)
                    .lineLimit(1)
                    .offset(x: contentSize.width - headerSize.width)
            }
            .readSize {
                headerSize = $0
            }

            Text(model.message)
                .anytypeStyle(.bodyRegular)
                .foregroundColor(.Text.primary)
            
            if model.linkedObjects.isNotEmpty {
                Spacer.fixedHeight(8)
                MessageLinkViewContainer(objects: model.linkedObjects, isYour: model.isYourMessage)
            }
            
            if model.reactions.isNotEmpty {
                Spacer.fixedHeight(8)
                MessageReactionList(rows: model.reactions) { reaction in
                    try await model.onTapReaction(reaction)
                } onTapAdd: {
                    model.onTapAddReaction()
                }
            }
        }
        .readSize {
            contentSize = $0
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(messageBackgorundColor)
        .cornerRadius(24, style: .circular)
        .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 24, style: .circular))
        .contextMenu {
            contextMenu
        }
    }
    
    @ViewBuilder
    private var leadingView: some View {
        if model.isYourMessage {
            Spacer(minLength: 32)
        } else {
            IconView(icon: model.authorIcon)
                .frame(width: 32, height: 32)
        }
    }
    
    @ViewBuilder
    private var trailingView: some View {
        if model.isYourMessage {
            IconView(icon: model.authorIcon)
                .frame(width: 32, height: 32)
        } else {
            Spacer(minLength: 32)
        }
    }
    
    @ViewBuilder
    private var contextMenu: some View {
        Button {
            model.onTapAddReaction()
        } label: {
            Text(Loc.Message.Action.addReaction)
        }
    }
}
