import Foundation
import SwiftUI
import Services

struct SpaceShareView: View {

    @State private var model: SpaceShareViewModel

    init(data: SpaceShareData, output: (any NewInviteLinkModuleOutput)?) {
        self._model = State(wrappedValue: SpaceShareViewModel(data: data, output: output))
    }
    
    var body: some View {
        content
            .task {
                await model.startParticipantsTask()
            }
            .task {
                await model.startSpaceViewTask()
            }
            .snackbar(toastBarData: $model.toastBarData)
            .anytypeSheet(item: $model.requestAlertModel) { alertModel in
                SpaceRequestAlert(data: alertModel) { reason in
                    model.onUpgradeTap(reason: reason, route: .confirmInvite)
                } onReject: {
                    model.onReject()
                }
            }
            .anytypeSheet(item: $model.changeAccessAlertModel) { model in
                SpaceChangeAccessView(model: model)
            }
            .anytypeSheet(item: $model.removeParticipantAlertModel) { model in
                SpaceParticipantRemoveView(model: model)
            }
            .anytypeSheet(isPresented: $model.showStopSharingAlert) {
                StopSharingAlert(spaceId: model.spaceId) {}
            }
            .anytypeSheet(isPresented: $model.showMakePrivateAlert) {
                MakePrivateAlert {
                    try await model.onMakePrivateConfirm()
                }
            }
            .anytypeSheet(item: $model.participantInfo) {
                ProfileView(info: $0)
            }
            .anytypeSheet(isPresented: $model.showStopSharingAnEmptySpaceAlert) {
                StopSharingAnEmptySpaceAlert()
            }
            .membershipUpgrade(reason: $model.membershipUpgradeReason)
            .ignoresSafeArea()
    }
    
    private var content: some View {
        VStack(spacing: 0) {
            DragIndicator()
            TitleView(title: Loc.SpaceShare.members)
                .overlay(alignment: .trailing) {
                    if model.linkViewModel.shareLink != nil {
                        Menu {
                            Button {
                                model.linkViewModel.onCopyLink(route: .menu)
                            } label: {
                                Text(Loc.copyLink)
                                Spacer()
                                Image(systemName: "link")
                            }
                            Button {
                                model.linkViewModel.onShareInvite()
                            } label: {
                                Text(Loc.SpaceShare.Share.link)
                                Spacer()
                                Image(systemName: "square.and.arrow.up")
                            }
                            Button {
                                model.linkViewModel.onShowQrCode()
                            } label: {
                                Text(Loc.SpaceShare.Qr.button)
                                Spacer()
                                Image(systemName: "qrcode")
                            }
                            if model.canStopShare {
                                Divider()
                                Button {
                                    model.onMakePrivateTapped()
                                } label: {
                                    Text(Loc.SpaceShare.MakePrivate.action)
                                    Spacer()
                                    Image(systemName: "lock")
                                }
                            }
                        } label: {
                            IconView(icon: .asset(.X24.more))
                                .frame(width: 24, height: 24)
                        }
                        .menuOrder(.fixed)
                        .padding(.trailing, 16)
                    }
                }

            ScrollView {
                VStack(spacing: 0) {
                    if let bannerData = model.limitBannerData {
                        SpaceLimitBannerView(
                            limitType: bannerData,
                            onManageSpaces: { model.onManageSpaces() },
                            onUpgrade: { model.onUpgradeTap(reason: bannerData.upgradeReason, route: .incentiveBanner) }
                        )
                    }

                    SectionHeaderView(title: Loc.SpaceShare.Invite.title)
                    NewInviteLinkView(model: model.linkViewModel, canChangeInvite: model.canChangeInvite, hasReachedSharedSpacesLimit: model.hasReachedSharedSpacesLimit)

                    SectionHeaderView(title: Loc.SpaceShare.members)
                    ForEach(model.rows) { participant in
                        SpaceShareParticipantView(participant: participant)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .background(Color.Background.primary)
    }
}
