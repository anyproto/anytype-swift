import SwiftUI
import AnytypeCore


struct SpaceHubCoordinatorView: View {
    @Environment(\.keyboardDismiss) private var keyboardDismiss
    @Environment(\.dismissAllPresented) private var dismissAllPresented
    
    @StateObject private var model = SpaceHubCoordinatorViewModel()
    
    var body: some View {
        NavigationStack {
            content
        }
        .onAppear {
            model.keyboardDismiss = keyboardDismiss
            model.dismissAllPresented = dismissAllPresented
        }
        .task {
            await model.startDeepLinkTask()
        }
        .task {
            await model.startHandleWorkspaceInfo()
        }
        .sheet(item: $model.sharingSpaceId) {
            ShareCoordinatorView(spaceId: $0.value)
        }
        .sheet(item: $model.showGalleryImport) { data in
            GalleryInstallationCoordinatorView(data: data)
        }
        .sheet(isPresented: $model.showSpaceManager) {
            SpacesManagerView()
        }
        .sheet(isPresented: $model.showSpaceShareTip) {
            SpaceShareTipView()
        }
        .sheet(item: $model.membershipTierId) { tierId in
            MembershipCoordinator(initialTierId: tierId.value)
        }
        .sheet(item: $model.showSpaceSwitchData) {
            SpaceSwitchCoordinatorView(data: $0)
        }
        .anytypeSheet(item: $model.spaceJoinData) {
            SpaceJoinView(data: $0, onManageSpaces: {
                model.onManageSpacesSelected()
            })
        }
    }
    
    private var content: some View {        
        SpaceHubView(sceneId: model.sceneId)
            .navigationDestination(isPresented: $model.showSpace) {
                HomeCoordinatorView(sceneId: model.sceneId, spaceInfo: model.spaceInfo ?? .empty, showSpace: $model.showSpace)
                    .navigationBarBackButtonHidden()
                    .onChange(of: model.showSpace) {
                        if !$0 { model.spaceInfo = nil }
                    }
            }
    }
}

#Preview {
    SpaceHubCoordinatorView()
}
