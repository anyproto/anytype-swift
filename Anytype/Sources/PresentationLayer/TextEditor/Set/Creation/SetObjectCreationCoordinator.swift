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
    
    @Injected(\.legacyNavigationContext)
    private var navigationContext: NavigationContextProtocol
    @Injected(\.legacyToastPresenter)
    private var toastPresenter: ToastPresenterProtocol
    @Injected(\.legacyCreateObjectModuleAssembly)
    private var createObjectModuleAssembly: CreateObjectModuleAssemblyProtocol
    private weak var output: SetObjectCreationCoordinatorOutput?
    private var customAnalyticsRoute: AnalyticsEventsRouteKind?
    
    @Injected(\.setObjectCreationHelper)
    private var objectCreationHelper: SetObjectCreationHelperProtocol
    
    nonisolated init() {}
    
    func startCreateObject(
        setDocument: SetDocumentProtocol,
        setting: ObjectCreationSetting?,
        output: SetObjectCreationCoordinatorOutput?,
        customAnalyticsRoute: AnalyticsEventsRouteKind?
    ) {
        Task { @MainActor [weak self] in
            guard let self else { return }
            
            self.output = output
            self.customAnalyticsRoute = customAnalyticsRoute
            let result = try await objectCreationHelper.createObject(for: setDocument, setting: setting)
            self.handleCreatedObjectIfNeeded(result.details, titleInputType: result.titleInputType, setDocument: setDocument)
        }
    }
    
    private func handleCreatedObjectIfNeeded(_ details: ObjectDetails?, titleInputType: CreateObjectTitleInputType, setDocument: SetDocumentProtocol) {
        if let details {
            showCreateObject(details: details, titleInputType: titleInputType)
            AnytypeAnalytics.instance().logCreateObject(
                objectType: details.analyticsType,
                spaceId: details.spaceId,
                route: customAnalyticsRoute ?? (setDocument.isCollection() ? .collection : .set)
            )
        } else {
            showCreateBookmarkObject(setDocument: setDocument)
        }
    }
    
    private func showCreateObject(details: ObjectDetails, titleInputType: CreateObjectTitleInputType) {
        let moduleViewController = createObjectModuleAssembly.makeCreateObject(objectId: details.id, titleInputType: titleInputType) { [weak self] in
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
                    guard details.isNil else {
                        if #available(iOS 17.0, *) {
                            SharingTip.didCopyText = true
                        }
                        return
                    }
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
