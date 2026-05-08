import SwiftUI
import AnytypeCore
import Services

struct HomeWidgetData: Hashable, Identifiable {
    let spaceId: String

    var id: String { spaceId }
}

enum WidgetScreenContext {
    case navigation
    case overlay

    var navigationButtonType: NavigationHeaderButtonType {
        switch self {
        case .navigation: return .back
        case .overlay: return .dismiss
        }
    }

    var showEmbeddedBottomPanel: Bool {
        switch self {
        case .navigation: return false
        case .overlay: return true
        }
    }
}

struct HomeWidgetsCoordinatorView: View {
    let data: HomeWidgetData
    let context: WidgetScreenContext

    var body: some View {
        SpaceLoadingContainerView(spaceId: data.spaceId, showBackground: true) { info in
            HomeWidgetsDocumentsLoaderView(info: info) { channelDoc, personalDoc in
                HomeWidgetsCoordinatorInternalView(
                    info: info,
                    channelWidgetsObject: channelDoc,
                    personalWidgetsObject: personalDoc,
                    context: context
                )
            }
        }
    }
}

private struct HomeWidgetsCoordinatorInternalView: View {

    @State private var model: HomeWidgetsCoordinatorViewModel
    @Environment(\.pageNavigation) private var pageNavigation
    @Environment(\.dismiss) private var dismiss

    let channelWidgetsObject: any BaseDocumentProtocol
    let personalWidgetsObject: any BaseDocumentProtocol
    let context: WidgetScreenContext

    init(
        info: AccountInfo,
        channelWidgetsObject: any BaseDocumentProtocol,
        personalWidgetsObject: any BaseDocumentProtocol,
        context: WidgetScreenContext
    ) {
        self._model = State(wrappedValue: HomeWidgetsCoordinatorViewModel(info: info))
        self.channelWidgetsObject = channelWidgetsObject
        self.personalWidgetsObject = personalWidgetsObject
        self.context = context
    }

    var body: some View {
        HomeWidgetsView(
            info: model.spaceInfo,
            channelWidgetsObject: channelWidgetsObject,
            personalWidgetsObject: personalWidgetsObject,
            context: context,
            output: model
        )
            .onAppear {
                model.pageNavigation = pageNavigation
            }
            .onChange(of: model.shouldDismissOverlay) {
                if model.shouldDismissOverlay {
                    dismiss()
                }
            }
            .task {
                if !FeatureFlags.fixChannelHomeBackNavigation {
                    await model.startPendingShareRetryTask()
                }
            }
            .task {
                await model.startSpaceViewTask()
            }
            .sheet(item: $model.showChangeTypeData) {
                WidgetTypeChangeView(data: $0)
            }
            .sheet(item: $model.showGlobalSearchData) {
                GlobalSearchView(data: $0)
            }
            .sheet(item: $model.spaceShareData) {
                SpaceShareCoordinatorView(data: $0)
            }
            .anytypeSheet(item: $model.createTypeData) {
                CreateObjectTypeView(data: $0)
            }
            .anytypeSheet(item: $model.deleteSystemWidgetConfirmationData) {
                DeleteSystemWidgetConfirmation(data: $0)
            }
            .anytypeSheet(item: $model.qrCodeInviteData) {
                QrCodeView(title: Loc.joinSpace, data: $0.value.absoluteString, analyticsType: .inviteSpace, route: .inviteLink)
            }
            .sheet(isPresented: $model.showManageSections) {
                ManageSectionsView(spaceId: model.spaceInfo.accountSpaceId)
            }
            .sheet(isPresented: $model.showHomeChangePicker) {
                HomepageSettingsPickerView(
                    spaceId: model.spaceInfo.accountSpaceId,
                    onHomepageSet: FeatureFlags.fixChannelHomeBackNavigation
                        ? { spaceId, homeData in
                            pageNavigation.replaceHome(spaceId, homeData)
                            model.shouldDismissOverlay = true
                        }
                        : nil
                )
            }
            .sheet(isPresented: $model.showHomepagePicker) {
                HomepageCreatePickerView(spaceId: model.spaceInfo.accountSpaceId) { result in
                    model.onHomepagePickerFinished(result: result)
                }
                .interactiveDismissDisabled(true)
            }
            .overlay {
                if model.showHomepagePicker {
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .ignoresSafeArea()
                        .transition(.asymmetric(
                            insertion: .identity,
                            removal: .opacity.animation(.easeInOut(duration: 0.3))
                        ))
                }
            }
    }
}
