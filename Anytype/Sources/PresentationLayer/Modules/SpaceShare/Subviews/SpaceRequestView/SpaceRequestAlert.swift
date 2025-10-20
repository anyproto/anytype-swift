import Foundation
import SwiftUI
import Services


struct SpaceRequestAlertData: Identifiable {
    let id = UUID()
    let spaceId: String
    let spaceName: String
    let participantIdentity: String
    let participantName: String
    let participantIcon: ObjectIcon?
    let route: ScreenInviteConfirmRoute
}

struct SpaceRequestAlert: View {
    
    @StateObject private var model: SpaceRequestAlertModel
    @Environment(\.dismiss) private var dismiss
    
    init(data: SpaceRequestAlertData, onMembershipUpgradeTap: @escaping (MembershipUpgradeReason) -> (), onReject: (() -> Void)? = nil) {
        _model = StateObject(wrappedValue: SpaceRequestAlertModel(
            data: data,
            onMembershipUpgradeTap: onMembershipUpgradeTap,
            onReject: onReject
        ))
    }
    
    var body: some View {
        BottomAlertView(
            title: model.title,
            headerView: {
                ObjectIconView(icon: model.icon)
                    .frame(width: 64, height: 64)
                    .padding(.top, 15)
                    .padding(.bottom, 4)
            }, bodyView: {
                EmptyView()
            }, buttons: {
                switch model.membershipLimitsExceeded {
                case nil:
                    defaultActions
                case .numberOfSpaceEditors:
                    editorsLimitActions
                }
            }
        )
        .throwingTask {
            try await model.onAppear()
        }
    }
    
    private var defaultActions: [BottomAlertButton] {
        [
            BottomAlertButton(text: Loc.SpaceShare.ViewRequest.viewAccess, style: .secondary) {
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

    private var editorsLimitActions: [BottomAlertButton] {
        [
            BottomAlertButton(text: Loc.SpaceShare.ViewRequest.viewAccess, style: .secondary) {
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
