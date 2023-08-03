import Foundation
import SwiftUI
import AnytypeCore

struct HomeWidgetsView: View {
    
    @StateObject var model: HomeWidgetsViewModel
    @State var dndState = DragState()
    
    var body: some View {
        ZStack {
            DashboardWallpaper()
            VerticalScrollViewWithOverlayHeader {
                HomeTopShadow()
            } content: {
                VStack(spacing: 12) {
                    ForEach(model.models) { rowModel in
                        rowModel.provider.view
                    }
                    HomeEditButton(text: Loc.Widgets.Actions.editWidgets) {
                        model.onEditButtonTap()
                    }
                    .opacity(model.hideEditButton ? 0 : 1)
                    .animation(.default, value: model.hideEditButton)
                    // Temporary buttons. For test without design
                    if FeatureFlags.multiSpace {
                        HomeEditButton(text: "Create space") {
                            model.onCreateSpaceTap()
                        }
                        HomeEditButton(text: "Delete space") {
                            model.onDeleteSpaceTap()
                        }
                        HomeEditButton(text: "Switch space") {
                            model.onSwitchSapceTap()
                        }
                    }
                }
                .padding(.horizontal, 20)
                .opacity(model.dataLoaded ? 1 : 0)
                .animation(.default.delay(0.3), value: model.dataLoaded)
                .fitIPadToReadableContentGuide()
            }
            .animation(.default, value: model.models.count)
        }
        .safeAreaInset(edge: .bottom, spacing: 20) {
            model.bottomPanelProvider.view
                .fitIPadToReadableContentGuide()
        }
        .onAppear {
            model.onAppear()
        }
        .onDisappear {
            model.onDisappear()
        }
        .navigationBarHidden(true)
        .anytypeStatusBar(style: .lightContent)
        .ignoresSafeArea(.all, edges: .bottom)
        .anytypeVerticalDrop(data: model.models, state: $dndState) { from, to in
            model.dropUpdate(from: from, to: to)
        } dropFinish: { from, to in
            model.dropFinish(from: from, to: to)
        }
        // Temporary
        .confirmationDialog("Switch space", isPresented: $model.showWorkspacesSwitchList) {
            ForEach(model.workspaces, id:\.id) { details in
                Button(details.title) {
                    model.onTapSwitchWorkspace(details: details)
                }
            }
            Button("Cancel", role: .cancel) {}
        }
        // Temporary
        .confirmationDialog("Delete space", isPresented: $model.showWorkspacesDeleteList) {
            ForEach(model.workspaces, id:\.id) { details in
                Button(details.title) {
                    model.onTapDeleteWorkspace(details: details)
                }
            }
            Button("Cancel", role: .cancel) {}
        }
    }
}
