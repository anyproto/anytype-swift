import Foundation
import SwiftUI
import Services

struct SpaceShareView: View {

    @StateObject private var model: SpaceShareViewModel

    init(data: SpaceShareData, output: (any NewInviteLinkModuleOutput)?) {
        self._model = StateObject(wrappedValue: SpaceShareViewModel(data: data, output: output))
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
                    NewInviteLinkView(data: model.data, notifyUpdateLinkView: $model.notifyUpdateLinkView, canChangeInvite: model.canChangeInvite, hasReachedSharedSpacesLimit: model.hasReachedSharedSpacesLimit, output: model.output)

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
