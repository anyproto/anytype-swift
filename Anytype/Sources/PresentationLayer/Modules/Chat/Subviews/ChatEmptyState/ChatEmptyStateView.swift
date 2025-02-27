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
                description: Loc.Chat.Empty.description,
                action: action
            )
        case .writer:
            emptyStateView(
                title: Loc.Chat.Empty.Default.title,
                description: Loc.Chat.Empty.Default.description,
                action: nil
            )
        case .reader, .noPermissions, .UNRECOGNIZED, nil:
            emptyStateView(
                title: Loc.Chat.Empty.Default.title,
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
            Text(title)
                .anytypeStyle(.bodyRegular)
                .foregroundStyle(Color.Text.primary)
            Text(description)
                .anytypeStyle(.bodyRegular)
                .foregroundStyle(Color.Control.transparentActive)
            if let action {
                Spacer.fixedHeight(10)
                StandardButton(
                    Loc.Chat.Empty.Button.title,
                    style: .secondarySmall,
                    action: action
                )
            }
            Spacer()
        }
    }
}
