import Foundation
import SwiftUI

struct MessageView: View {
    
    private enum Constants {
        static let gridSize: CGFloat = 250
        static let gridPadding: CGFloat = 4
    }
    
    private let data: MessageViewData
    private weak var output: (any MessageModuleOutput)?
    
    @State private var contentSize: CGSize = .zero
    @State private var headerSize: CGSize = .zero
    
    init(
        data: MessageViewData,
        output: (any MessageModuleOutput)? = nil
    ) {
        self.data = data
        self.output = output
    }
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            leadingView
            content
            trailingView
        }
        .padding(.horizontal, 12)
        .padding(.bottom, data.nextSpacing.height)
    }
    
    private var content: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
                
            if let reply = data.replyModel {
                MessageReplyView(model: reply)
                    .padding(4)
                    .onTapGesture {
                        output?.didSelectReplyMessage(message: data)
                    }
            }
            
            if !data.messageString.isEmpty {
                if !data.showHeader && data.replyModel.isNil {
                    Spacer.fixedHeight(12)
                }
                Text(data.messageString)
                    .anytypeStyle(.previewTitle1Regular)
                    .padding(.horizontal, 12)
            }
            
            if let objects = data.linkedObjects {
                switch objects {
                case .list(let items):
                    MessageListAttachmentsViewContainer(objects: items) {
                        output?.didSelectAttachment(data: data, details: $0)
                    }
                    .padding(4)
                case .grid(let items):
                    MessageGridAttachmentsContainer(objects: items, oneSide: Constants.gridSize, spacing: 4) {
                        output?.didSelectAttachment(data: data, details: $0)
                    }
                    .padding(Constants.gridPadding)
                }
            }
            
            if data.reactions.isNotEmpty {
                MessageReactionList(
                    rows: data.reactions,
                    canAddReaction: data.canAddReaction,
                    isYourMessage: data.isYourMessage,
                    onTapRow: { reaction in
                        try await output?.didTapOnReaction(data: data, reaction: reaction)
                    },
                    onLongTapRow: { reaction in
                        output?.didLongTapOnReaction(data: data, reaction: reaction)
                    },
                    onTapAdd: {
                        output?.didSelectAddReaction(messageId: data.message.id)
                    }
                )
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
            }
            
            if data.reactions.isEmpty && data.linkedObjects == nil {
                Spacer.fixedHeight(12)
            }
        }
        .if(data.linkedObjects?.isGrid ?? false) {
            $0.frame(width: Constants.gridSize + Constants.gridPadding * 2)
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
        if data.isYourMessage {
            horizontalBubbleSpacing
        } else {
            authorIcon
        }
    }
    
    @ViewBuilder
    private var trailingView: some View {
        if data.isYourMessage {
            authorIcon
        } else {
            horizontalBubbleSpacing
        }
    }
    
    @ViewBuilder
    private var authorIcon: some View {
        switch data.authorMode {
        case .show:
            IconView(icon: data.authorIcon)
                .frame(width: 32, height: 32)
        case .empty:
            Spacer.fixedWidth(32)
        case .hidden:
            EmptyView()
        }
    }
    
    @ViewBuilder
    private var horizontalBubbleSpacing: some View {
        switch data.authorMode {
        case .show, .empty:
            Spacer(minLength: 32)
        case .hidden:
            Spacer(minLength: 64)
        }
    }
    
    @ViewBuilder
    private var header: some View {
        if data.showHeader {
            HStack(spacing: 10) {
                Text(data.authorName)
                    .anytypeStyle(.previewTitle2Medium)
                    .foregroundColor(textColor)
                    .lineLimit(1)
            
                Text(data.createDate)
                    .anytypeStyle(.caption1Regular)
                    .foregroundColor(timeColor)
                    .lineLimit(1)
                    .offset(x: contentSize.width - headerSize.width)
            }
            // Height is required for prevent change cell height if participant not loaded. For empty text
            .frame(height: 20)
            .padding(.horizontal, 12)
            .padding(.top, 12)
            .readSize {
                headerSize = $0
            }
        }
    }
    
    @ViewBuilder
    private var contextMenu: some View {
        if data.canAddReaction {
            Button {
                output?.didSelectAddReaction(messageId: data.message.id)
            } label: {
                Label(Loc.Message.Action.addReaction, systemImage: "face.smiling")            
            }
        }
        
        Divider()
        
        Button {
            output?.didSelectReplyTo(message: data)
        } label: {
            Label(Loc.Message.Action.reply, systemImage: "arrowshape.turn.up.left")
        }
        
        if data.canEdit {
            AsyncButton {
                await output?.didSelectEditMessage(message: data)
            } label: {
                Label(Loc.edit, systemImage: "pencil")
            }
        }
        
        if data.canDelete {
            Button(role: .destructive) {
                output?.didSelectDeleteMessage(message: data)
            } label: {
                Label(Loc.delete, systemImage: "trash")
            }
        }
    }
    
    private var messageBackgorundColor: Color {
        return data.isYourMessage ? .Control.transparentActive : .Background.navigationPanel
    }
    
    private var textColor: Color {
        return MessageTextBuilder.textColor(data.isYourMessage)
    }
    
    private var timeColor: Color {
        return data.isYourMessage ? .Text.white : .Text.secondary
    }
}
