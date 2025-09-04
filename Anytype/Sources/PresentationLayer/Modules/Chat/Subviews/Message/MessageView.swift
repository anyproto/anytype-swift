import Foundation
import SwiftUI
import AnytypeCore

//struct MessageView: View {
//    
//    private enum Constants {
//        static let attachmentsPadding: CGFloat = 4
//        static let messageHorizontalPadding: CGFloat = 12
//        static let coordinateSpace = "MessageViewCoordinateSpace"
//        static let emoji = ["👍🏻", "️️❤️", "😂"]
//    }
//    
//    private let data: MessageViewData
//    private weak var output: (any MessageModuleOutput)?
//    
//    @State private var bubbleCenterOffsetY: CGFloat = 0
//    
//    @Environment(\.messageYourBackgroundColor) private var messageYourBackgroundColor
//    
//    init(
//        data: MessageViewData,
//        output: (any MessageModuleOutput)? = nil
//    ) {
//        self.data = data
//        self.output = output
//    }
//    
//    var body: some View {
//        MessageReplyActionView(
//            isEnabled: FeatureFlags.swipeToReply && data.canReply,
//            contentHorizontalPadding: Constants.messageHorizontalPadding,
//            centerOffsetY: $bubbleCenterOffsetY,
//            content: {
//                alignedСontent
//            },
//            action: {
////                output?.didSelectReplyTo(data: data)
//            }
//        )
//        .id(data.id)
//    }
//    
//    private var alignedСontent: some View {
//        HStack(alignment: .bottom, spacing: 6) {
//            leadingView
//            content
//            trailingView
//        }
//        .padding(.horizontal, Constants.messageHorizontalPadding)
//        .padding(.bottom, data.nextSpacing.height)
//        .fixTappableArea()
//        .coordinateSpace(name: Constants.coordinateSpace)
//    }
//    
//    private var content: some View {
//        VStack(alignment: data.position.isRight ? .trailing : .leading, spacing: 4) {
//            reply
//            author
//            bubble
//            reactions
//        }
//        .if(UIDevice.isPad) {
//            $0.frame(maxWidth: 350, alignment: data.position.isRight ? .trailing : .leading)
//        }
//    }
//    
//    @ViewBuilder
//    private var reply: some View {
//    }
//    
//    @ViewBuilder
//    private var author: some View {
//        if data.showAuthorName {
//            Text(data.authorName.isNotEmpty ? data.authorName : " ") // Safe height if participant is not loaded
//                .anytypeStyle(.caption1Medium)
//                .lineLimit(1)
//                .foregroundStyle(Color.Text.primary)
//                .padding(.horizontal, 12)
//        }
//    }
//    
//    private var bubble: some View {
//        VStack(alignment: .leading, spacing: 0) {
//            
//            linkedObjectsForTop
//            
//            if !data.messageString.isEmpty {
//                // Add spacing for date
//                (Text(data.messageString) + infoForSpacing)
//                    .anytypeStyle(.chatText)
//                    .padding(.horizontal, 12)
//                    .alignmentGuide(.timeVerticalAlignment) { $0[.bottom] }
//                    .padding(.vertical, 4)
//            }
//            
//            linkedObjectsForBottom
//        }
//        .overlay(alignment: Alignment(horizontal: .trailing, vertical: .timeVerticalAlignment)) {
//            if !data.messageString.isEmpty {
//                infoView
//                    .padding(.horizontal, 12)
//            }
//        }
//        .messageFlashBackground(id: data.id)
//        .background(messageBackgorundColor)
//        .cornerRadius(16, style: .continuous)
//        .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 16, style: .circular))
//        .contextMenu {
//            contextMenu
//        }
//        .readFrame(space: .named(Constants.coordinateSpace)) {
//            bubbleCenterOffsetY = $0.midY
//        }
//    }
//    
//    @ViewBuilder
//    private var linkedObjectsForTop: some View {
//    }
//    
//    @ViewBuilder
//    private var linkedObjectsForBottom: some View {
//    }
//    
//    @ViewBuilder
//    private var attachmentFreeSpacing: some View {
//        if !data.messageString.isEmpty {
//            Spacer.fixedHeight(4)
//        } else {
//            EmptyView()
//        }
//    }
//    
//    private var infoView: some View {
//        Text(messageBottomInfo: data)
//            .foregroundColor(messageTimeColor)
//            .lineLimit(1)
//    }
//    
//    private var infoForSpacing: Text {
//        Text(messageBottomInfo: data)
//            .foregroundColor(.clear)
//    }
//
//    private var messageBackgorundColor: Color {
//        return data.position.isRight ? messageYourBackgroundColor : .Background.Chat.bubbleSomeones
//    }
//    
//    private var messageTimeColor: Color {
//        return data.position.isRight ? Color.Background.Chat.whiteTransparent : Color.Control.transparentSecondary
//    }
//}
//
//private struct TimeVerticalAlignment: AlignmentID {
//    static func defaultValue(in context: ViewDimensions) -> CGFloat {
//        return context[.bottom]
//    }
//}
//
//private extension VerticalAlignment {
//    static let timeVerticalAlignment = VerticalAlignment(TimeVerticalAlignment.self)
//}
