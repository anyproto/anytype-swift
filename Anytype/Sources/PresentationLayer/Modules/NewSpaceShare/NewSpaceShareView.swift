import Foundation
import SwiftUI
import Services

struct NewSpaceShareView: View {
    
    @StateObject private var model: NewSpaceShareViewModel
    
    init(data: SpaceShareData, output: (any NewSpaceShareModuleOutput)?) {
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
            TitleView(title: Loc.SpaceShare.title) {
                rightNavigationButton
            }
            
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(spacing: 0) {
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
                .safeAreaInset(edge: .bottom) {
                    NewInviteLinkView(data: model.data, output: model.output)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 36)
                }
            }
        }
        .animation(.default, value: model.upgradeTooltipData)
    }
    
    private var rightNavigationButton: some View {
        Menu {
            Button(Loc.moreInfo) {
                model.onMoreInfoTap()
            }
            Button(Loc.SpaceShare.StopSharing.action, role: .destructive) {
                model.onStopSharing()
            }
            .disabled(!model.canStopShare)
        } label: {
            IconView(icon: .asset(.X24.more))
                .frame(width: 24, height: 24)
        }
    }
}
