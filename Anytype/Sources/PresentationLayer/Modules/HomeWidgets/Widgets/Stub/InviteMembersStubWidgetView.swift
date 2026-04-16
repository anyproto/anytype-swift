import SwiftUI
import Assets

struct InviteMembersStubWidgetView: View {

    @State private var model: InviteMembersStubWidgetViewModel

    init(spaceId: String, output: (any HomeWidgetsModuleOutput)?) {
        self._model = State(initialValue: InviteMembersStubWidgetViewModel(spaceId: spaceId, output: output))
    }

    var body: some View {
        Group {
            if model.showInviteMembers {
                inviteMembersRow
                    .padding(.bottom, 12)
            }
        }
        .animation(.default, value: model.showInviteMembers)
        .task {
            await model.startSubscription()
        }
    }

    private var inviteMembersRow: some View {
        HStack(spacing: 0) {
            Button(action: { model.onInviteMembersTap() }) {
                HStack(spacing: 0) {
                    Spacer.fixedWidth(16)
                    Image(asset: .X24.addMembers)
                        .resizable()
                        .renderingMode(.template)
                        .frame(width: 20, height: 20)
                        .foregroundStyle(Color.Pure.red)
                    Spacer.fixedWidth(12)
                    AnytypeText(Loc.Chat.inviteMembers, style: .previewTitle2Medium)
                        .foregroundStyle(Color.Text.primary)
                        .lineLimit(1)
                    Spacer()
                }
                .frame(height: 52)
            }

            Button(action: { model.onInviteMembersClose() }) {
                Image(asset: .X24.close)
                    .foregroundStyle(Color.Control.secondary)
                    .padding(.horizontal, 14)
            }
        }
        .background(Color.Background.widget)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}
