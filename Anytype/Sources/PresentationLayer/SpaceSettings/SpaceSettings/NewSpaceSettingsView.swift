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
            .anytypeSheet(isPresented: $model.showInfoView) {
                SpaceSettingsInfoView(info: model.info)
            }
            .membershipUpgrade(reason: $model.membershipUpgradeReason)
    }
    
    private var content: some View {
        VStack(spacing: 0) {
            header
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    
                    spaceDetailsButton
                    
                    spaceSection
                    
                    SectionHeaderView(title: Loc.preferences)
                    
                    SettingsSectionItemView(
                        name: Loc.personalization,
                        imageAsset: .Settings.personalization,
                        onTap: { model.onPersonalizationTap() }
                    )
                    
                    if model.allowRemoteStorage {
                        SectionHeaderView(title: Loc.Settings.dataManagement)
                        SettingsSectionItemView(
                            name: Loc.SpaceSettings.remoteStorage,
                            imageAsset: .Settings.fileStorage,
                            onTap: { model.onStorageTap() }
                        )
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    private var header: some View {
        NavigationHeaderContainer(spacing: 20, leftView: {
            Button {
                dismiss()
            } label: {
                IconView(asset: .X24.close)
                    .foregroundStyle(Color.Control.active)
                    .frame(width: 24, height: 24)
                    .padding()
            }
        }, titleView: {
            EmptyView()
        }, rightView: {
            Menu {
                Button(Loc.SpaceSettings.info) {
                    model.onInfoTap()
                }
                
                if model.allowDelete {
                    Button(Loc.SpaceSettings.deleteButton, role: .destructive) {
                        model.onDeleteTap()
                    }
                }
                if model.allowLeave {
                    Button(Loc.SpaceSettings.leaveButton, role: .destructive) {
                        model.onLeaveTap()
                    }
                }
            } label: {
                IconView(asset: .X24.more)
                    .foregroundStyle(Color.Control.active)
                    .frame(width: 24, height: 24)
                    .padding()
            }
        })
    }
    
    private var spaceDetailsButton: some View {
        Button {
            model.onSpaceDetailsTap()
        } label: {
            HStack(spacing: 0) {
                if let icon = model.spaceIcon {
                    IconView(icon: icon)
                        .frame(width: 56, height: 56)
                }
                
                Spacer.fixedWidth(12)
                
                VStack(alignment: .leading, spacing: 0) {
                    AnytypeText(model.spaceDisplayName, style: .bodySemibold)
                    Spacer.fixedHeight(2)
                    AnytypeText(model.spaceDisplayDescription, style: .uxTitle2Regular)
                        .foregroundColor(.Text.secondary)
                }
                
                Spacer.fixedWidth(12)
                
                Spacer()
                
                if model.allowEditSpace {
                    IconView(asset: .X24.Arrow.right)
                        .frame(width: 24, height: 24)
                }
            }
            .padding(16)
            .border(16, color: .Shape.primary, lineWidth: 0.5)
        }
        .disabled(!model.allowEditSpace)
    }
    
    @ViewBuilder
    private var spaceSection: some View {
        SectionHeaderView(title: Loc.collaboration)
        
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
                    decoration: .none,
                    onTap: {  }
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

