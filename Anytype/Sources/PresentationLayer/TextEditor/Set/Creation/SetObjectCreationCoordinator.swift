import Services
import AnytypeCore

enum SetObjectCreationMode {
    case `internal`
    case fullscreen
}

@MainActor
protocol SetObjectCreationCoordinatorProtocol {
    func startCreateObject(
        setDocument: some SetDocumentProtocol,
        mode: SetObjectCreationMode,
        setting: ObjectCreationSetting?,
        output: (any SetObjectCreationCoordinatorOutput)?,
        customAnalyticsRoute: AnalyticsEventsRouteKind?
    )
}

@MainActor
final class SetObjectCreationCoordinator: SetObjectCreationCoordinatorProtocol {
    
    @Injected(\.legacyNavigationContext)
    private var navigationContext: any NavigationContextProtocol
    @Injected(\.legacyToastPresenter)
    private var toastPresenter: any ToastPresenterProtocol
    @Injected(\.legacyCreateObjectModuleAssembly)
    private var createObjectModuleAssembly: any CreateObjectModuleAssemblyProtocol
    private weak var output: (any SetObjectCreationCoordinatorOutput)?
    private var customAnalyticsRoute: AnalyticsEventsRouteKind?
    
    @Injected(\.setObjectCreationHelper)
    private var objectCreationHelper: any SetObjectCreationHelperProtocol
    
    nonisolated init() {}
    
    func startCreateObject(
        setDocument: some SetDocumentProtocol,
        mode: SetObjectCreationMode,
        setting: ObjectCreationSetting?,
        output: (any SetObjectCreationCoordinatorOutput)?,
        customAnalyticsRoute: AnalyticsEventsRouteKind?
    ) {
        Task { @MainActor [weak self] in
            guard let self else { return }
            
            self.output = output
            self.customAnalyticsRoute = customAnalyticsRoute
            do {
                let action = try await objectCreationHelper.createObject(for: setDocument, setting: setting)
                handleAction(action, mode: mode, setDocument: setDocument)
            } catch {
                anytypeAssertionFailure("Cannot create object for set document", info: [
                    "error": error.localizedDescription
                ])
            }
        }
    }

    private func handleAction(_ action: SetObjectCreationAction, mode: SetObjectCreationMode, setDocument: some SetDocumentProtocol) {
        
        let analyticsRoute: AnalyticsEventsRouteKind = customAnalyticsRoute ?? (setDocument.isCollection() ? .collection : .set)
        
        switch action {
        case .showObject(let details, let titleInputType):
            switch mode {
            case .internal:
                showCreateObject(details: details, titleInputType: titleInputType)
            case .fullscreen:
                showObject(data: details.screenData())
            }
            AnytypeAnalytics.instance().logCreateObject(
                objectType: details.analyticsType,
                spaceId: details.spaceId,
                route: analyticsRoute
            )

        case .showBookmarkCreation(let spaceId, let collectionId):
            let screenData = ScreenData.alert(.bookmarkCreate(BookmarkCreateScreenData(spaceId: spaceId, collectionId: collectionId, analyticsRoute: analyticsRoute)))
            showObject(data: screenData)

        case .showChatCreation(let spaceId, let collectionId):
            let screenData = ScreenData.alert(.chatCreate(ChatCreateScreenData(spaceId: spaceId, collectionId: collectionId, analyticsRoute: analyticsRoute)))
            showObject(data: screenData)
        }
    }
    
    private func showCreateObject(details: ObjectDetails, titleInputType: CreateObjectTitleInputType) {
        let moduleViewController = createObjectModuleAssembly.makeCreateObject(objectId: details.id, titleInputType: titleInputType) { [weak self] in
            self?.navigationContext.dismissTopPresented()
            self?.showObject(data: details.screenData())
        } closeAction: { [weak self] in
            self?.navigationContext.dismissTopPresented()
        }

        navigationContext.present(moduleViewController)
    }

    private func showObject(data: ScreenData) {
        output?.showEditorScreen(data: data)
    }
}

extension SetObjectCreationCoordinatorProtocol {
    func startCreateObject(
        setDocument: some SetDocumentProtocol,
        mode: SetObjectCreationMode,
        output: (any SetObjectCreationCoordinatorOutput)?,
        customAnalyticsRoute: AnalyticsEventsRouteKind?
    ) {
        startCreateObject(setDocument: setDocument, mode: mode, setting: nil, output: output, customAnalyticsRoute: customAnalyticsRoute)
    }
}
