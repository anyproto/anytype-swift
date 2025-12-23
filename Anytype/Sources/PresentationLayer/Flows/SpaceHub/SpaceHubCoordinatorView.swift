import SwiftUI
import AnytypeCore
import Services


struct SpaceHubCoordinatorView: View {
    @Environment(\.keyboardDismiss) private var keyboardDismiss
    @Environment(\.dismissAllPresented) private var dismissAllPresented
    
    @State private var model = SpaceHubCoordinatorViewModel()
    
    @Namespace private var namespace
    
    var body: some View {
        content
            .onAppear {
                model.keyboardDismiss = keyboardDismiss
                model.dismissAllPresented = dismissAllPresented
            }
            .onChange(of: model.navigationPath) { model.onPathChange() }
        
            .taskWithMemoryScope { await model.setup() }
            .task(id: model.currentSpaceId) {
                await model.startSpaceSubscription()
            }
            .handleSharingTip()
            .updateShortcuts(spaceId: model.fallbackSpaceId)
            .snackbar(toastBarData: $model.toastBarData)
            
            .sheet(item: $model.showGalleryImport) { data in
                GalleryInstallationCoordinatorView(data: data)
            }
            .sheet(isPresented: $model.showSpaceManager) {
                SpacesManagerView()
            }
            .sheet(item: $model.membershipTierId) { tierId in
                MembershipCoordinator(initialTierId: tierId.value)
            }
            .sheet(item: $model.membershipNameFinalizationData) {
                MembershipNameFinalizationView(tier: $0)
            }
            .sheet(item: $model.showGlobalSearchData) {
                GlobalSearchView(data: $0)
            }
            .sheet(item: $model.typeSearchForObjectCreationSpaceId) {
                model.typeSearchForObjectCreationModule(spaceId: $0.value)
            }
            .anytypeSheet(item: $model.spaceJoinData) {
                SpaceJoinView(data: $0, onManageSpaces: {
                    model.onManageSpacesSelected()
                })
            }
            .anytypeSheet(item: $model.userWarningAlert, dismissOnBackgroundView: false) {
                UserWarningAlertCoordinatorView(alert: $0)
            }
            .anytypeSheet(isPresented: $model.showObjectIsNotAvailableAlert) {
                ObjectIsNotAvailableAlert()
            }
            .sheet(item: $model.showSpaceShareData) {
                SpaceShareCoordinatorView(data: $0)
                    .pageNavigation(model.pageNavigation)
            }
            .sheet(item: $model.showSpaceMembersData) {
                SpaceMembersView(data: $0)
                    .pageNavigation(model.pageNavigation)
            }
            .anytypeSheet(item: $model.profileData) {
                ProfileView(info: $0)
                    .pageNavigation(model.pageNavigation)
            }
            .anytypeSheet(item: $model.spaceProfileData) {
                SpaceProfileView(info: $0)
            }
            .safariBookmarkObject($model.bookmarkScreenData) {
                model.onOpenBookmarkAsObject($0)
            }
            .sheet(item: $model.spaceCreateData) {
                SpaceCreateCoordinatorView(data: $0)
            }
            .sheet(item: $model.chatCreateData) { data in
                ChatCreateView(data: data)
                    .pageNavigation(model.pageNavigation)
            }
            .sheet(item: $model.overlayWidgetsData) { data in
                HomeWidgetsCoordinatorView(data: data)
                    .pageNavigation(model.pageNavigation)
            }
            .sheet(isPresented: $model.showSpaceTypeForCreate) {
                SpaceCreateTypePickerView(onSelectSpaceType: { type in
                    model.onSpaceTypeSelected(type)
                }, onSelectQrCodeScan: {
                    model.onSelectQrCodeScan()
                })
                .navigationZoomTransition(sourceID: "SpaceCreateTypePickerView", in: namespace)
            }
            .qrCodeScanner(shouldScan: $model.shouldScanQrCode)
            .sheet(isPresented: $model.showSharingExtension) {
                SharingExtensionCoordinatorView()
            }
            .sheet(isPresented: $model.showAppSettings) {
                SettingsCoordinatorView()
                    .pageNavigation(model.pageNavigation)
            }
        
            // load photos
            .photosPicker(isPresented: $model.showPhotosPicker, selection: $model.photosItems)
            .onChange(of: model.photosItems) {
                model.photosPickerFinished()
            }
        
            // load from camera
            .cameraAccessFullScreenCover(item: $model.cameraData) {
                SimpleCameraView(data: $0)
            }
            
            // load files
            .fileImporter(
                isPresented: $model.showFilesPicker,
                allowedContentTypes: [.data],
                allowsMultipleSelection: true
            ) { result in
                model.fileImporterFinished(result: result)
            }
    }
    
    private var content: some View {
        ZStack {
            Color.Background.primary

            HomeBottomPanelContainer(
                path: $model.navigationPath,
                content: {
                    AnytypeNavigationView(path: $model.navigationPath, pathChanging: $model.pathChanging) { builder in
//                        builder.appendBuilder(for: HomeWidgetData.self) { data in
//                            HomeWidgetsCoordinatorView(data: data)
//                        }
                        builder.appendBuilder(for: EditorScreenData.self) { data in
                            EditorCoordinatorView(data: data)
                        }
                        builder.appendBuilder(for: SpaceHubNavigationItem.self) { _ in
                            SpaceHubView(output: model, namespace: namespace)
                        }
                        builder.appendBuilder(for: SpaceChatCoordinatorData.self) {
                            SpaceChatCoordinatorView(data: $0)
                        }
                        builder.appendBuilder(for: ChatCoordinatorData.self) {
                            ChatCoordinatorView(data: $0)
                        }
                        builder.appendBuilder(for: SpaceInitialStateData.self) { stateData in
                            Rectangle().foregroundStyle(Color.Pure.orange).ignoresSafeArea()
                                .navigationTitle("emptyState")
                                .navigationBarTitleDisplayMode(.large)
                                .overlay(alignment: .center) {
                                    AnytypeText("EMPTY STATE FOLKS!", style: .title)
                                }
                                .onAppear {
                                    model.pageNavigation.open(.alert(.widget(.init(spaceId: stateData.spaceId))))
                                }
                        }
                        builder.appendBuilder(for: SpaceInfoScreenData.self) { data in
                            switch data {
                            case .settings(let spaceId):
                                SpaceSettingsCoordinator(spaceId: spaceId)
                            case .typeLibrary(let spaceId):
                                ObjectTypesLibraryView(spaceId: spaceId)
                            case .propertiesLibrary(let spaceId):
                                ObjectPropertiesLibraryView(spaceId: spaceId)
                            }
                        }
                     }
                },
                bottomPanel: {
                    if let spaceInfo = model.spaceInfo {
                        HomeBottomNavigationPanelView(homePath: model.navigationPath, info: spaceInfo, output: model)
                    }
                }
            )

            NotificationCoordinatorView()
        }
        .animation(.easeInOut, value: model.spaceInfo)
        .pageNavigation(model.pageNavigation)
        .chatActionProvider($model.chatProvider)
    }
}

#Preview {
    SpaceHubCoordinatorView()
}
