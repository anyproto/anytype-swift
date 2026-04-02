import SwiftUI
import Assets

struct StubWidgetsView: View {

    @State private var model: StubWidgetsViewModel

    init(spaceId: String, output: (any HomeWidgetsModuleOutput)?) {
        self._model = State(initialValue: StubWidgetsViewModel(spaceId: spaceId, output: output))
    }

    var body: some View {
        VStack(spacing: 12) {
            if model.showCreateHome {
                stubWidgetRow(
                    icon: .CustomIcons.home,
                    iconColor: Color.Control.accent100,
                    title: Loc.HomepagePicker.title,
                    onTap: { model.onCreateHomeTap() },
                    onClose: { model.onCreateHomeClose() }
                )
            }
            if model.showInviteMembers {
                stubWidgetRow(
                    icon: .X24.addMembers,
                    iconColor: Color.Pure.red,
                    title: Loc.Chat.inviteMembers,
                    onTap: { model.onInviteMembersTap() },
                    onClose: { model.onInviteMembersClose() }
                )
            }
        }
        .animation(.default, value: model.showCreateHome)
        .animation(.default, value: model.showInviteMembers)
        .task {
            await model.startSubscriptions()
        }
    }

    private func stubWidgetRow(
        icon: ImageAsset,
        iconColor: Color,
        title: String,
        onTap: @escaping () -> Void,
        onClose: @escaping () -> Void
    ) -> some View {
        HStack(spacing: 0) {
            Button(action: onTap) {
                HStack(spacing: 0) {
                    Spacer.fixedWidth(16)
                    Image(asset: icon)
                        .resizable()
                        .renderingMode(.template)
                        .frame(width: 20, height: 20)
                        .foregroundStyle(iconColor)
                    Spacer.fixedWidth(12)
                    AnytypeText(title, style: .bodySemibold)
                        .foregroundStyle(Color.Text.primary)
                        .lineLimit(1)
                    Spacer(minLength: 8)
                }
                .fixTappableArea()
            }
            .buttonStyle(.plain)
            Button(action: onClose) {
                Image(asset: .X24.close)
                    .foregroundStyle(Color.Control.secondary)
                    .frame(width: 48, height: 48)
            }
            .buttonStyle(.plain)
        }
        .frame(height: 48)
        .background(Color.Background.primary)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}
