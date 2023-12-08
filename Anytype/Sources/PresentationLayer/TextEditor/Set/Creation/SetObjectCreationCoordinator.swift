import Services

@MainActor
protocol SetObjectCreationCoordinatorProtocol {
    func startCreateObject(
        setDocument: SetDocumentProtocol,
        setting: ObjectCreationSetting?,
        output: SetObjectCreationCoordinatorOutput?,
        customAnalyticsRoute: AnalyticsEventsRouteKind?
    )
}

@MainActor
final class SetObjectCreationCoordinator: SetObjectCreationCoordinatorProtocol {
    
    private let navigationContext: NavigationContextProtocol
    private let toastPresenter: ToastPresenterProtocol
    private let objectCreationHelper: SetObjectCreationHelperProtocol
    private let createObjectModuleAssembly: CreateObjectModuleAssemblyProtocol
    private weak var output: SetObjectCreationCoordinatorOutput?
    private var customAnalyticsRoute: AnalyticsEventsRouteKind?
    
    nonisolated init(
        navigationContext: NavigationContextProtocol,
        toastPresenter: ToastPresenterProtocol,
        objectCreationHelper: SetObjectCreationHelperProtocol,
        createObjectModuleAssembly: CreateObjectModuleAssemblyProtocol
    ) {
        self.navigationContext = navigationContext
        self.toastPresenter = toastPresenter
        self.objectCreationHelper = objectCreationHelper
        self.createObjectModuleAssembly = createObjectModuleAssembly
    }
    
    func startCreateObject(
        setDocument: SetDocumentProtocol,
        setting: ObjectCreationSetting?,
        output: SetObjectCreationCoordinatorOutput?,
        customAnalyticsRoute: AnalyticsEventsRouteKind?
    ) {
        self.output = output
        self.customAnalyticsRoute = customAnalyticsRoute
        objectCreationHelper.createObject(for: setDocument, setting: setting) { [weak self] details, blockId in
            self?.handleCreatedObjectIfNeeded(details, blockId: blockId, setDocument: setDocument)
        }
    }
    
    private func handleCreatedObjectIfNeeded(_ details: ObjectDetails?, blockId: String?, setDocument: SetDocumentProtocol) {
        if let details {
            showCreateObject(details: details, blockId: blockId)
            AnytypeAnalytics.instance().logCreateObject(
                objectType: details.analyticsType,
                route: customAnalyticsRoute ?? (setDocument.isCollection() ? .collection : .set)
            )
        } else {
            showCreateBookmarkObject(setDocument: setDocument)
        }
    }
    
    private func showCreateObject(details: ObjectDetails, blockId: String?) {
        let moduleViewController = createObjectModuleAssembly.makeCreateObject(objectId: details.id, blockId: blockId) { [weak self] in
            self?.navigationContext.dismissTopPresented()
            self?.showPage(data: details.editorScreenData())
        } closeAction: { [weak self] in
            self?.navigationContext.dismissTopPresented()
        }
        
        navigationContext.present(moduleViewController)
    }
    
    private func showCreateBookmarkObject(setDocument: SetDocumentProtocol) {
        let moduleViewController = createObjectModuleAssembly.makeCreateBookmark(
            spaceId: setDocument.spaceId,
            collectionId: setDocument.isCollection() ? setDocument.objectId : nil,
            closeAction: { [weak self] details in
                self?.navigationContext.dismissTopPresented(animated: true) {
                    guard details.isNil else { return }
                    self?.toastPresenter.showFailureAlert(message: Loc.Set.Bookmark.Error.message)
                }
            }
        )
        
        navigationContext.present(moduleViewController)
    }
    
    private func showPage(data: EditorScreenData) {
        output?.showEditorScreen(data: data)
    }
}

extension SetObjectCreationCoordinatorProtocol {
    func startCreateObject(
        setDocument: SetDocumentProtocol, 
        output: SetObjectCreationCoordinatorOutput?,
        customAnalyticsRoute: AnalyticsEventsRouteKind?
    ) {
        startCreateObject(setDocument: setDocument, setting: nil, output: output, customAnalyticsRoute: customAnalyticsRoute)
    }
}
