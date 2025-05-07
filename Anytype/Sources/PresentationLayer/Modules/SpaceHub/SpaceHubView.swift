import SwiftUI
import AnytypeCore

struct SpaceHubView: View {
    @StateObject private var model: SpaceHubViewModel
    
    @State private var draggedSpace: ParticipantSpaceViewDataWithPreview?
    @State private var draggedInitialIndex: Int?
    
    init(output: (any SpaceHubModuleOutput)?) {
        _model = StateObject(wrappedValue: SpaceHubViewModel(output: output))
    }
    
    var body: some View {
        content
            .onAppear { model.onAppear() }
            .task { await model.startSubscriptions() }
            
            .sheet(isPresented: $model.showSettings) {
                SettingsCoordinatorView()
            }
            .anytypeSheet(item: $model.spaceIdToLeave) {
                SpaceLeaveAlert(spaceId: $0.value)
            }
            .anytypeSheet(item: $model.spaceIdToDelete) {
                SpaceDeleteAlert(spaceId: $0.value)
            }
            .homeBottomPanelHidden(true)
    }
    
    var content: some View {
        VStack(spacing: 0) {
            navBar
            HomeUpdateSubmoduleView().padding(8)
            
            if let spaces = model.spaces {
                VStack(spacing: 8) {
                    ScrollView {
                        Spacer.fixedHeight(4)
                        if #available(iOS 17.0, *) {
                            if FeatureFlags.anyAppBetaTip {
                                HomeAnyAppWidgetTipView()
                                    .padding(.horizontal, 8)
                            }
                        }
                        ForEach(spaces) {
                            spaceCard($0)
                        }
                        if model.createSpaceAvailable {
                            plusButton
                        }
                        Spacer.fixedHeight(40)
                    }
                    .scrollIndicators(.never)
                }
            }
            
            Spacer()
        }
        .ignoresSafeArea(edges: .bottom)
        .animation(.default, value: model.spaces)
    }
    
    private var plusButton: some View {
        Button {
            model.onTapCreateSpace()
        } label: {
            HStack(alignment: .center) {
                Spacer()
                Image(asset: .X32.plus)
                Spacer()
            }
            .padding(.vertical, 32)
            .background(Color.Shape.tertiary)
            .cornerRadius(20, style: .continuous)
            .padding(.horizontal, 8)
        }
    }
    
    private var navBar: some View {
        HStack(alignment: .center, spacing: 0) {
            Spacer()
            AnytypeText(FeatureFlags.spaceHubNewTitle ? Loc.myChannels : Loc.mySpaces, style: .uxTitle1Semibold)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .overlay(alignment: .leading) {
            Button(
                action: {
                    model.showSettings = true
                },
                label: {
                    IconView(icon: model.profileIcon)
                        .foregroundStyle(Color.Control.active)
                        .frame(width: 28, height: 28)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 16)
                }
            )
        }
        .if(model.showPlusInNavbar) {
            $0.overlay(alignment: .trailing) {
                Button(
                    action: {
                        model.onTapCreateSpace()
                    },
                    label: {
                        Image(asset: .X32.plus)
                            .foregroundStyle(Color.Control.active)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 14)
                    }
                )
            }
        }
    }
    
    private func spaceCard(_ space: ParticipantSpaceViewDataWithPreview) -> some View {
        SpaceCard(
            spaceData: space,
            wallpeper: model.wallpapers[space.spaceView.targetSpaceId] ?? .default,
            draggedSpace: $draggedSpace,
            onTap: {
                model.onSpaceTap(spaceId: space.spaceView.targetSpaceId)
            },
            onTapCopy: {
                model.copySpaceInfo(spaceView: space.spaceView)
            },
            onTapLeave: {
                model.leaveSpace(spaceId: space.spaceView.targetSpaceId)
            },
            onTapDelete: {
                try await model.deleteSpace(spaceId: space.spaceView.targetSpaceId)
            }
        )
        .equatable()
        .onDrop(
            of: [.text],
            delegate:  SpaceHubDropDelegate(
                destinationItem: space,
                allSpaces: $model.spaces,
                draggedItem: $draggedSpace,
                initialIndex: $draggedInitialIndex
            )
        )
    }
}

#Preview {
    SpaceHubView(output: nil)
}
