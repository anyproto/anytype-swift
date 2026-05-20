import SwiftUI
import Services


struct ProfileView: View {
    @State private var model: ProfileViewModel
    @Environment(\.pageNavigation) private var pageNavigation

    init(info: ObjectInfo) {
        _model = State(initialValue: ProfileViewModel(info: info))
    }

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        mainContent
            .onAppear {
                model.pageNavigation = pageNavigation
                model.onParticipantRemoved = { dismiss() }
            }
            .task {
                await model.setupSubscriptions()
            }
            .sheet(isPresented: $model.showSettings) {
                SettingsCoordinatorView()
            }
            .anytypeSheet(item: $model.removeAlertModel) { model in
                SpaceParticipantRemoveView(model: model)
            }
    }

    @ViewBuilder
    private var mainContent: some View {
        if let details = model.details {
            content(details)
        } else {
            emptyView
        }
    }

    private var emptyView: some View {
        Spacer.fixedHeight(300)
            .background(Color.Background.secondary)
    }
    
    private func content(_ details: ObjectDetails) -> some View {
        VStack(spacing: 0) {
            DragIndicator()
            actionRow
            
            if details.description.isNotEmpty {
                viewWithDescription(details)
            } else {
                viewWithoutDescription(details)
            }
            
        }
        .padding(.horizontal, 16)
        .background(Color.Background.secondary)
    }
    
    @ViewBuilder
    private var actionRow: some View {
        if model.isOwner || model.canRemoveMember {
            HStack(spacing: 12) {
                Spacer()
                if model.isOwner {
                    Button {
                        model.showSettings.toggle()
                    } label: {
                        IconView(asset: .X32.edit).frame(width: 32, height: 32)
                    }
                }
                if model.canRemoveMember {
                    Menu {
                        Button(role: .destructive) {
                            model.onRemoveMember()
                        } label: {
                            HStack {
                                AnytypeText(Loc.SpaceShare.RemoveMember.title, style: .uxCalloutRegular)
                                Spacer()
                                Image(asset: .X24.close)
                            }
                        }
                    } label: {
                        Image(asset: .X24.more)
                            .foregroundStyle(Color.Control.primary)
                            .frame(width: NavigationHeaderConstants.buttonSize, height: NavigationHeaderConstants.buttonSize)
                    }
                    .glassEffectInteractiveIOS26(in: Circle())
                }
            }
        } else {
            Spacer.fixedHeight(32)
        }
    }
    
    private func viewWithDescription(_ details: ObjectDetails) -> some View {
        Group {
            Spacer.fixedHeight(30)
            IconView(icon: details.objectIconImage).frame(width: 112, height: 112)
            Spacer.fixedHeight(12)
            AnytypeText(details.name, style: .heading).lineLimit(1)
            Spacer.fixedHeight(4)
            AnytypeText(details.displayName, style: .caption1Regular).foregroundStyle(Color.Text.secondary).lineLimit(1)
            Spacer.fixedHeight(4)
            AnytypeText(details.description, style: .previewTitle2Regular)
            connectButton
            Spacer.fixedHeight(32)
        }
    }

    private func viewWithoutDescription(_ details: ObjectDetails) -> some View {
        Group {
            Spacer.fixedHeight(30)
            IconView(icon: details.objectIconImage).frame(width: 184, height: 184)
            Spacer.fixedHeight(12)
            AnytypeText(details.name, style: .heading).lineLimit(1)
            Spacer.fixedHeight(4)
            AnytypeText(details.displayName, style: .caption1Regular).foregroundStyle(Color.Text.secondary).lineLimit(1)
            connectButton
            Spacer.fixedHeight(32)
        }
    }

    @ViewBuilder
    private var connectButton: some View {
        if !model.isOwner {
            Spacer.fixedHeight(24)
            AsyncStandardButton(Loc.sendMessage, style: .primaryLarge) {
                try await model.onConnect()
            }
        } else {
            Spacer.fixedHeight(52)
        }
    }
}

#Preview {
    ProfileView(info: ObjectInfo(objectId: "", spaceId: ""))
}
