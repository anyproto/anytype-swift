import Foundation
import SwiftUI
import AnytypeCore
import Services

struct NewSpaceSettingsView: View {
    
    @StateObject private var model: NewSpaceSettingsViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(workspaceInfo: AccountInfo, output: (any SpaceSettingsModuleOutput)?) {
        _model = StateObject(wrappedValue: NewSpaceSettingsViewModel(workspaceInfo: workspaceInfo, output: output))
    }
    
    var body: some View {
        content
            .snackbar(toastBarData: $model.snackBarData)
            .onAppear {
                model.onAppear()
            }
            .task {
                await model.startJoiningTask()
            }
            .task {
                await model.startParticipantTask()
            }
            .onChange(of: model.dismiss) { _ in
                dismiss()
            }
            .anytypeSheet(isPresented: $model.showSpaceDeleteAlert) {
                SpaceDeleteAlert(spaceId: model.workspaceInfo.accountSpaceId)
            }
            .anytypeSheet(isPresented: $model.showSpaceLeaveAlert) {
                SpaceLeaveAlert(spaceId: model.workspaceInfo.accountSpaceId)
            }
            .membershipUpgrade(reason: $model.membershipUpgradeReason)
    }
    
    private var content: some View {
        VStack(spacing: 0) {
            DragIndicator()
            TitleView(title: Loc.SpaceSettings.title)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    
                    SettingsObjectHeader(name: $model.spaceName, nameTitle: Loc.Settings.spaceName, iconImage: model.spaceIcon, onTap: {
                        model.onChangeIconTap()
                    })
                    .disabled(!model.allowEditSpace)
                    
                    spaceSection
                    
                    SectionHeaderView(title: Loc.settings)
                    
                    if model.allowRemoteStorage {
                        SettingsSectionItemView(
                            name: Loc.SpaceSettings.remoteStorage,
                            imageAsset: .Settings.fileStorage,
                            onTap: { model.onStorageTap() }
                        )
                    }
                    
                    SettingsSectionItemView(
                        name: Loc.personalization,
                        imageAsset: .Settings.personalization,
                        onTap: { model.onPersonalizationTap() }
                    )
                    
                    SectionHeaderView(title: Loc.SpaceSettings.info)
                    
                    ForEach(0..<model.info.count, id:\.self) { index in
                        SettingsInfoBlockView(model: model.info[index])
                    }
                    
                    VStack(spacing: 10) {
                        if model.allowDelete {
                            StandardButton(Loc.SpaceSettings.deleteButton, style: .warningLarge) {
                                model.onDeleteTap()
                            }
                        }
                        if model.allowLeave {
                            StandardButton(Loc.SpaceSettings.leaveButton, style: .warningLarge) {
                                model.onLeaveTap()
                            }
                        }
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 10)
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    @ViewBuilder
    private var spaceSection: some View {
        SectionHeaderView(title: Loc.Settings.spaceType)
        
        switch model.shareSection {
        case .personal:
            SettingsSectionItemView(name: model.spaceAccessType, decoration: nil, onTap: {})
        case let .private(state):
            privateSpaceSetting(state: state)
        case .owner(let joiningCount):
            SettingsSectionItemView(
                name: model.spaceAccessType,
                decoration: .arrow(text: joiningCount > 0 ? Loc.SpaceShare.requestsCount(joiningCount) : Loc.SpaceShare.manage),
                onTap: { model.onShareTap() }
            )
        case .member:
            SettingsSectionItemView(
                name: model.spaceAccessType,
                decoration: .arrow(text: Loc.SpaceShare.members),
                onTap: { model.onMembersTap() }
            )
        }
    }
    
    func privateSpaceSetting(state: PrivateSpaceSettingsShareSection) -> some View {
        Group {
            switch state {
            case .unshareable:
                SettingsSectionItemView(
                    name: model.spaceAccessType,
                    decoration: .arrow(text: Loc.share),
                    onTap: { model.onShareTap() }
                )
                .disabled(true)
            case .shareable:
                SettingsSectionItemView(
                    name: model.spaceAccessType,
                    decoration: .arrow(text: Loc.share),
                    onTap: { model.onShareTap() }
                )
            case .reachedSharesLimit(let limit):
                VStack(alignment: .leading, spacing: 0) {
                    SettingsSectionItemView(
                        name: model.spaceAccessType,
                        decoration: .arrow(text: Loc.share),
                        showDivider: false,
                        onTap: { model.onShareTap() }
                    )
                    .disabled(true)
                    
                    AnytypeText(Loc.Membership.Upgrade.spacesLimit(limit), style: .caption1Regular)
                        .foregroundColor(.Text.primary)
                    Spacer.fixedHeight(10)
                    StandardButton("\(MembershipConstants.membershipSymbol.rawValue) \(Loc.Membership.Upgrade.moreSpaces)", style: .upgradeBadge) {
                        model.onMembershipUpgradeTap()
                    }
                }
            }
        }
    }
}

