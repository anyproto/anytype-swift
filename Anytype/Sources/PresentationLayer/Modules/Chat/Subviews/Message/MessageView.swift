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
        .padding(.horizontal, 12)
        .onChange(of: data) {
            model.update(data: $0)
        }
        .onAppear {
            model.onAppear()
        }
        .onDisappear {
            model.onDisappear()
        }
        .padding(.bottom, model.nextSpacing.height)
    }
    
    private var content: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
                
            if let reply = model.reply {
                MessageReplyView(model: reply)
                    .padding(4)
                    .onTapGesture {
                        model.onTapReplyMessage()
                    }
            }
            
            if !model.message.isEmpty {
                if !model.showHeader && model.reply.isNil {
                    Spacer.fixedHeight(12)
                }
                Text(model.message)
                    .anytypeStyle(.previewTitle1Regular)
                    .foregroundColor(textColor)
                    .padding(.horizontal, 12)
            }
            
            if let objects = model.linkedObjects {
                switch objects {
                case .list(let items):
                    MessageListAttachmentsViewContainer(objects: items) {
                        model.onTapObject(details: $0)
                    }
                    .padding(4)
                case .grid(let items):
                    MessageGridAttachmentsContainer(objects: items) {
                        model.onTapObject(details: $0)
                    }
                    .padding(4)
                }
            }
            
            if model.reactions.isNotEmpty {
                MessageReactionList(
                    rows: model.reactions,
                    onTapRow: { reaction in
                        try await model.onTapReaction(reaction)
                    },
                    onLongTapRow: { reaction in
                        model.onLongTapReaction(reaction)
                    },
                    onTapAdd: {
                        model.onTapAddReaction()
                    }
                )
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
            }
            
            if model.reactions.isEmpty && model.linkedObjects == nil {
                Spacer.fixedHeight(12)
            }
        }
        .readSize {
            contentSize = $0
        }
        .background(messageBackgorundColor)
        .cornerRadius(20, style: .circular)
        .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 20, style: .circular))
        .contextMenu {
            contextMenu
        }
    }
    
    @ViewBuilder
    private var leadingView: some View {
        if model.isYourMessage {
            horizontalBubbleSpacing
        } else {
            authorIcon
        }
    }
    
    @ViewBuilder
    private var trailingView: some View {
        if model.isYourMessage {
            authorIcon
        } else {
            horizontalBubbleSpacing
        }
    }
    
    @ViewBuilder
    private var authorIcon: some View {
        switch model.authorMode {
        case .show:
            IconView(icon: model.authorIcon)
                .frame(width: 32, height: 32)
        case .empty:
            Spacer.fixedWidth(32)
        case .hidden:
            EmptyView()
        }
    }
    
    @ViewBuilder
    private var horizontalBubbleSpacing: some View {
        switch model.authorMode {
        case .show, .empty:
            Spacer(minLength: 32)
        case .hidden:
            Spacer(minLength: 64)
        }
    }
    
    @ViewBuilder
    private var header: some View {
        if model.showHeader {
            HStack(spacing: 10) {
                Text(model.author)
                    .anytypeStyle(.previewTitle2Medium)
                    .foregroundColor(textColor)
                    .lineLimit(1)
            
                Text(model.date)
                    .anytypeStyle(.caption1Regular)
                    .foregroundColor(timeColor)
                    .lineLimit(1)
                    .offset(x: contentSize.width - headerSize.width)
            }
            .padding(.horizontal, 12)
            .padding(.top, 12)
            .readSize {
                headerSize = $0
            }
        }
    }
    
    @ViewBuilder
    private var contextMenu: some View {
        Button {
            model.onTapAddReaction()
        } label: {
            Label(Loc.Message.Action.addReaction, systemImage: "face.smiling")            
        }
        
        Divider()
        
        Button {
            model.onTapReplyTo()
        } label: {
            Label(Loc.Message.Action.reply, systemImage: "arrowshape.turn.up.left")
        }
    }
    
    private var messageBackgorundColor: Color {
        return model.isYourMessage ? .Control.navPanelIcon : .Background.navigationPanel
    }
    
    private var textColor: Color {
        return model.isYourMessage ? .Text.white : .Text.primary
    }
    
    private var timeColor: Color {
        return model.isYourMessage ? .Text.white : .Text.secondary
    }
}
