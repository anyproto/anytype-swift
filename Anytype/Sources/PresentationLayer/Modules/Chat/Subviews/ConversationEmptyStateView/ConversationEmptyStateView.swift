import Foundation
import SwiftUI
import Services

struct ConversationEmptyStateView: View {
        
    let conversationType: ConversationType
    let participantPermissions: ParticipantPermissions?
    let action: (() -> Void)?
    
    var body: some View {
        switch conversationType {
        case .chat:
            chatEmptyStateView
        case .stream:
            streamEmptyStateView
        }
    }
    
    private var chatEmptyStateView: some View {
        switch participantPermissions {
        case .owner:
            emptyStateView(
                title: Loc.Chat.Empty.title,
                description: Loc.Chat.Empty.Owner.description,
                action: action
            )
        case .writer:
            emptyStateView(
                title: Loc.Chat.Empty.title,
                description: Loc.Chat.Empty.Editor.description,
                action: nil
            )
        case .reader, .noPermissions, .UNRECOGNIZED, nil:
            emptyStateView(
                title: Loc.Chat.Empty.title,
                description: "",
                action: nil
            )
        }
    }
    
    private var streamEmptyStateView: some View {
        switch participantPermissions {
        case .owner:
            emptyStateView(
                title: Loc.Stream.Empty.title,
                description: Loc.Stream.Empty.description,
                action: action
            )
        case .writer, .reader, .noPermissions, .UNRECOGNIZED, nil:
            emptyStateView(
                title: Loc.Stream.Empty.title,
                description: "",
                action: nil
            )
        }
    }
    
    private func emptyStateView(title: String, description: String, action: (() -> Void)?) -> some View {
        VStack(alignment: .center, spacing: 0) {
            Spacer()
            Image(asset: .Dialog.coffee)
            Spacer.fixedHeight(10)
            Text(title)
                .anytypeStyle(.bodyRegular)
                .foregroundStyle(Color.Text.primary)
            Text(description)
                .anytypeStyle(.bodyRegular)
                .foregroundStyle(Color.Control.transparentSecondary)
            if let action {
                Spacer.fixedHeight(10)
                StandardButton(
                    Loc.Chat.Empty.Button.title,
                    style: .transparentXSmall,
                    action: action
                )
            }
            Spacer()
        }
    }
}
