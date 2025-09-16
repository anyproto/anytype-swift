import Foundation
import SwiftUI
import Services

struct NewSpaceShareView: View {
    
    @StateObject private var model: NewSpaceShareViewModel
    
    init(data: SpaceShareData, output: (any NewInviteLinkModuleOutput)?) {
        self._model = StateObject(wrappedValue: NewSpaceShareViewModel(data: data, output: output))
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
                    try await model.onReject()
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
            .membershipUpgrade(reason: $model.membershipUpgradeReason)
            .ignoresSafeArea()
    }
    
    private var content: some View {
        VStack(spacing: 0) {
            DragIndicator()
            TitleView(title: Loc.SpaceShare.members)
            
            ScrollView {
                VStack(spacing: 0) {
                    
                    SectionHeaderView(title: Loc.SpaceShare.Invite.title)
                    NewInviteLinkView(data: model.data, notifyUpdateLinkView: $model.notifyUpdateLinkView, canChangeInvite: model.canChangeInvite, output: model.output)
                    
                    SectionHeaderView(title: Loc.SpaceShare.members)
                    if let reason = model.upgradeTooltipData {
                        SpaceShareUpgradeView(reason: reason) {
                            model.onUpgradeTap(reason: reason, route: .spaceSettings)
                        }
                    }
                    ForEach(model.rows) { participant in
                        SpaceShareParticipantView(participant: participant)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .background(Color.Background.primary)
        .animation(.default, value: model.upgradeTooltipData)
    }
}
