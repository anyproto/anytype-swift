import Foundation
import SwiftUI
import Services

struct ConversationEmptyStateView: View {

    let conversationType: ConversationType
    let participantPermissions: ParticipantPermissions?
    let addMembersAction: (() -> Void)?
    let qrCodeAction: (() -> Void)?
    
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
                addMembersAction: addMembersAction,
                qrCodeAction: qrCodeAction
            )
        case .writer:
            emptyStateView(
                title: Loc.Chat.Empty.title,
                addMembersAction: nil,
                qrCodeAction: nil
            )
        case .reader, .noPermissions, .UNRECOGNIZED, nil:
            emptyStateView(
                title: Loc.Chat.Empty.title,
                addMembersAction: nil,
                qrCodeAction: nil
            )
        }
    }
    
    private var streamEmptyStateView: some View {
        switch participantPermissions {
        case .owner:
            emptyStateView(
                title: Loc.Stream.Empty.title,
                addMembersAction: addMembersAction,
                qrCodeAction: qrCodeAction
            )
        case .writer, .reader, .noPermissions, .UNRECOGNIZED, nil:
            emptyStateView(
                title: Loc.Stream.Empty.title,
                addMembersAction: nil,
                qrCodeAction: nil
            )
        }
    }
    
    private func emptyStateView(title: String, addMembersAction: (() -> Void)?, qrCodeAction: (() -> Void)?) -> some View {
        VStack(alignment: .center, spacing: 0) {
            Spacer()
            Text(title)
                .anytypeStyle(.bodySemibold)
                .foregroundStyle(Color.Text.primary)
            Spacer.fixedHeight(20)
            featureRow(icon: "infinity", text: Loc.Chat.Empty.Feature.yoursForever)
            Spacer.fixedHeight(12)
            featureRow(icon: "wifi.slash", text: Loc.Chat.Empty.Feature.availableOffline)
            Spacer.fixedHeight(12)
            featureRow(icon: "key.fill", text: Loc.Chat.Empty.Feature.privateEncrypted)
            Spacer.fixedHeight(25)
            HStack(alignment: .center, spacing: 8) {
                Spacer()
                if let addMembersAction {
                    StandardButton(
                        Loc.Chat.Empty.Button.addMembers,
                        style: .primaryXSmall,
                        action: addMembersAction
                    )
                }
                if let qrCodeAction {
                    StandardButton(
                        Loc.SpaceShare.Qr.button,
                        style: .primaryXSmall,
                        action: qrCodeAction
                    )
                }
                Spacer()
            }
            Spacer()
        }
    }

    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .frame(width: 24, height: 24)
                .foregroundStyle(Color.Control.transparentSecondary)
            Text(text)
                .anytypeStyle(.relation3Regular)
            Spacer()
        }
        .padding(.horizontal, 45)
    }
}
