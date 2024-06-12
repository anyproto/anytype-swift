import Foundation
import SwiftUI

struct SpaceRequestAlertData: Identifiable {
    let id = UUID()
    let spaceId: String
    let spaceName: String
    let participantIdentity: String
    let participantName: String
    let route: ScreenInviteConfirmRoute
}

struct SpaceRequestAlert: View {
    
    @StateObject private var model: SpaceRequestAlertModel
    @Environment(\.dismiss) private var dismiss
    
    init(data: SpaceRequestAlertData, onMembershipUpgradeTap: @escaping (MembershipUpgradeReason) -> ()) {
        _model = StateObject(wrappedValue: SpaceRequestAlertModel(
            data: data,
            onMembershipUpgradeTap: onMembershipUpgradeTap
        ))
    }
    
    var body: some View {
        BottomAlertView(title: model.title, message: "") {
            switch model.membershipLimitsExceeded {
            case nil:
                defaultActions
            case .numberOfSpaceReaders:
                readersLimitActions
            case .numberOfSpaceEditors:
                editorsLimitActions
            }
        }
        .throwTask {
            try await model.onAppear()
        }
    }
    
    private var defaultActions: [BottomAlertButton] {
        [
            BottomAlertButton(text: Loc.SpaceShare.ViewRequest.viewAccess, style: .secondary, disable: !model.canAddReaded) {
                try await model.onViewAccess()
                dismiss()
            },
            BottomAlertButton(text: Loc.SpaceShare.ViewRequest.editAccess, style: .secondary, disable: !model.canAddWriter) {
                try await model.onEditAccess()
                dismiss()
            },
            BottomAlertButton(text: Loc.SpaceShare.ViewRequest.reject, style: .warning) {
                try await model.onReject()
                dismiss()
            }
        ]
    }
    
    private var readersLimitActions: [BottomAlertButton] {
        [
            BottomAlertButton(
                text: "\(MembershipConstants.membershipSymbol.rawValue) \(Loc.Membership.Upgrade.moreMembers)",
                style: .primary
            ) {
                model.onMembershipUpgrade(reason: .numberOfSpaceReaders)
                dismiss()
            },
            BottomAlertButton(text: Loc.SpaceShare.ViewRequest.reject, style: .warning) {
                try await model.onReject()
                dismiss()
            }
        ]
    }
    
    private var editorsLimitActions: [BottomAlertButton] {
        [
            BottomAlertButton(text: Loc.SpaceShare.ViewRequest.viewAccess, style: .secondary, disable: !model.canAddReaded) {
                try await model.onViewAccess()
                dismiss()
            },
            BottomAlertButton(
                text: "\(MembershipConstants.membershipSymbol.rawValue) \(Loc.SpaceShare.ViewRequest.editAccess)",
                style: .secondary
            ) {
                model.onMembershipUpgrade(reason: .numberOfSpaceEditors)
                dismiss()
            },
            BottomAlertButton(text: Loc.SpaceShare.ViewRequest.reject, style: .warning) {
                try await model.onReject()
                dismiss()
            }
        ]
    }
}
