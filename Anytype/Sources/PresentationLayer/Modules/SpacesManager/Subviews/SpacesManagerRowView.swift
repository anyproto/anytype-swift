import Foundation
import SwiftUI
import Services

struct SpacesManagerRowView: View {
    
    let model: ParticipantSpaceViewData
    let onDelete: @MainActor () async throws -> Void
    let onLeave: @MainActor () async throws -> Void
    let onCancelRequest: @MainActor () async throws -> Void
    let onArchive: @MainActor () async throws -> Void
    let onStopSharing: @MainActor () async throws -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            spaceInfo
            spaceStateInfo
        }
        .padding(.horizontal, 16)
        .background(Color.Background.primary)
        .border(12, color: .Shape.primary)
        .lineLimit(1)
    }
    
    private var spaceInfo: some View {
        HStack(spacing: 12) {
            IconView(icon: model.spaceView.iconImage)
                .frame(width: 48, height: 48)
            VStack(alignment: .leading, spacing: 0) {
                AnytypeText(model.spaceView.title, style: .uxTitle2Semibold)
                    .foregroundColor(.Text.primary)
                AnytypeText(model.participant?.permission.title, style: .relation2Regular)
                    .foregroundColor(.Text.secondary)
            }
            Spacer()
            menu
        }
        .frame(height: 80)
        .newDivider()
    }
    
    private var spaceStateInfo: some View {
        HStack(spacing: 0) {
            Circle()
                .fill(model.spaceView.accountStatus?.color ?? .black)
                .frame(width: 8, height: 8)
            Spacer.fixedWidth(6)
            AnytypeText(Loc.Spaces.Info.network, style: .relation3Regular)
                .foregroundColor(.Text.secondary)
            Spacer.fixedWidth(4)
            AnytypeText(model.spaceView.accountStatus?.name, style: .relation3Regular)
                .foregroundColor(.Text.primary)
            Spacer()
        }
        .frame(height: 44)
    }
    
    @ViewBuilder
    private var menu: some View {
        if model.canBeDeleted || model.canLeave || model.canCancelJoinRequest || model.canStopSharing || model.canBeArchived {
            Menu {
                if model.canBeDeleted {
                    AsyncButton(Loc.delete, role: .destructive, action: onDelete)
                }
                if model.canLeave {
                    AsyncButton(Loc.SpaceSettings.leaveButton, role: .destructive, action: onLeave)
                }
                if model.canCancelJoinRequest {
                    AsyncButton(Loc.SpaceManager.cancelRequest, role: .destructive, action: onCancelRequest)
                }
                if model.canStopSharing {
                    AsyncButton(Loc.SpaceShare.StopSharing.action, role: .destructive, action: onStopSharing)
                }
                if model.canBeArchived {
                    AsyncButton(Loc.export, action: onArchive)
                }
            } label: {
                IconView(icon: .asset(.X24.more))
                    .frame(width: 24, height: 24)
            }
        }
    }
}

private extension SpaceStatus {
    var color: Color {
        switch self {
        case .UNRECOGNIZED, .spaceJoining, .loading:
            return .Pure.orange
        case .error, .missing, .remoteDeleted, .remoteWaitingDeletion, .spaceDeleted, .spaceRemoving:
            return .Pure.red
        case .unknown, .ok, .spaceActive:
            return .Pure.green
        }
    }
}
