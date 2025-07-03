import SwiftUI
import AnytypeCore

struct OldSpaceHubView: View {
    @StateObject private var model: SpaceHubViewModel
    
    @State private var draggedSpace: ParticipantSpaceViewData?
    @State private var draggedInitialIndex: Int?
    
    init(output: (any SpaceHubModuleOutput)?) {
        _model = StateObject(wrappedValue: SpaceHubViewModel(output: output, showOnlyChats: false))
    }
    
    var body: some View {
        content
            .onAppear { model.onAppear() }
            .taskWithMemoryScope { await model.startSubscriptions() }
            
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
            
            if let allSpaces = model.allSpaces {
                VStack(spacing: 8) {
                    ScrollView {
                        Spacer.fixedHeight(4)
                        if #available(iOS 17.0, *) {
                            if FeatureFlags.anyAppBetaTip {
                                HomeAnyAppWidgetTipView()
                                    .padding(.horizontal, 8)
                            }
                        }
                        ForEach(allSpaces) {
                            spaceCard($0.space)
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
        .animation(.default, value: model.allSpaces)
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
            AnytypeText(Loc.mySpaces, style: .uxTitle1Semibold)
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
    
    private func spaceCard(_ space: ParticipantSpaceViewData) -> some View {
        OldSpaceCard(
            space: space,
            wallpeper: model.wallpapers[space.spaceView.targetSpaceId] ?? .default,
            draggedSpace: $draggedSpace,
            onTap: {
                model.onSpaceTap(spaceId: space.spaceView.targetSpaceId, presentation: .widgets)
            },
            onTapCopy: {
                model.copySpaceInfo(spaceView: space.spaceView)
            },
            onTapPin: {
                // Pin functionality not available in new model
            },
            onTapUnpin: {
                // Unpin functionality not available in new model
            },
            onTapLeave: {
                model.leaveSpace(spaceId: space.spaceView.targetSpaceId)
            },
            onTapDelete: {
                try await model.deleteSpace(spaceId: space.spaceView.targetSpaceId)
            }
        )
        .equatable()
    }
}

#Preview {
    OldSpaceHubView(output: nil)
}
