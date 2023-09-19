import UIKit
import Services
import SafariServices
import SwiftUI
import FloatingPanel
import AnytypeCore

final class EditorRouter: NSObject, EditorRouterProtocol, ObjectSettingsCoordinatorOutput {
    private weak var rootController: EditorBrowserController?
    private weak var viewController: UIViewController?
    private let navigationContext: NavigationContextProtocol
    private let fileCoordinator: FileDownloadingCoordinator
    private let addNewRelationCoordinator: AddNewRelationCoordinatorProtocol
    private let document: BaseDocumentProtocol
    private let templatesCoordinator: TemplatesCoordinator
    private let templateSelectionCoordinator: TemplateSelectionCoordinatorProtocol
    private let urlOpener: URLOpenerProtocol
    private let relationValueCoordinator: RelationValueCoordinatorProtocol
    private let editorPageCoordinator: EditorPageCoordinatorProtocol
    private let linkToObjectCoordinator: LinkToObjectCoordinatorProtocol
    private let objectCoverPickerModuleAssembly: ObjectCoverPickerModuleAssemblyProtocol
    private let objectIconPickerModuleAssembly: ObjectIconPickerModuleAssemblyProtocol
    private let objectSettingCoordinator: ObjectSettingsCoordinatorProtocol
    private let searchModuleAssembly: SearchModuleAssemblyProtocol
    private let toastPresenter: ToastPresenterProtocol
    private let codeLanguageListModuleAssembly: CodeLanguageListModuleAssemblyProtocol
    private let newSearchModuleAssembly: NewSearchModuleAssemblyProtocol
    private let textIconPickerModuleAssembly: TextIconPickerModuleAssemblyProtocol
    private let alertHelper: AlertHelper
    private let pageService: PageRepositoryProtocol
    private let templateService: TemplatesServiceProtocol
    
    init(
        rootController: EditorBrowserController?,
        viewController: UIViewController,
        navigationContext: NavigationContextProtocol,
        document: BaseDocumentProtocol,
        addNewRelationCoordinator: AddNewRelationCoordinatorProtocol,
        templatesCoordinator: TemplatesCoordinator,
        templateSelectionCoordinator: TemplateSelectionCoordinatorProtocol,
        urlOpener: URLOpenerProtocol,
        relationValueCoordinator: RelationValueCoordinatorProtocol,
        editorPageCoordinator: EditorPageCoordinatorProtocol,
        linkToObjectCoordinator: LinkToObjectCoordinatorProtocol,
        objectCoverPickerModuleAssembly: ObjectCoverPickerModuleAssemblyProtocol,
        objectIconPickerModuleAssembly: ObjectIconPickerModuleAssemblyProtocol,
        objectSettingCoordinator: ObjectSettingsCoordinatorProtocol,
        searchModuleAssembly: SearchModuleAssemblyProtocol,
        toastPresenter: ToastPresenterProtocol,
        codeLanguageListModuleAssembly: CodeLanguageListModuleAssemblyProtocol,
        newSearchModuleAssembly: NewSearchModuleAssemblyProtocol,
        textIconPickerModuleAssembly: TextIconPickerModuleAssemblyProtocol,
        alertHelper: AlertHelper,
        pageService: PageRepositoryProtocol,
        templateService: TemplatesServiceProtocol
    ) {
        self.rootController = rootController
        self.viewController = viewController
        self.navigationContext = navigationContext
        self.document = document
        self.fileCoordinator = FileDownloadingCoordinator(viewController: viewController)
        self.addNewRelationCoordinator = addNewRelationCoordinator
        self.templatesCoordinator = templatesCoordinator
        self.templateSelectionCoordinator = templateSelectionCoordinator
        self.urlOpener = urlOpener
        self.relationValueCoordinator = relationValueCoordinator
        self.editorPageCoordinator = editorPageCoordinator
        self.linkToObjectCoordinator = linkToObjectCoordinator
        self.objectCoverPickerModuleAssembly = objectCoverPickerModuleAssembly
        self.objectIconPickerModuleAssembly = objectIconPickerModuleAssembly
        self.objectSettingCoordinator = objectSettingCoordinator
        self.searchModuleAssembly = searchModuleAssembly
        self.toastPresenter = toastPresenter
        self.codeLanguageListModuleAssembly = codeLanguageListModuleAssembly
        self.newSearchModuleAssembly = newSearchModuleAssembly
        self.textIconPickerModuleAssembly = textIconPickerModuleAssembly
        self.alertHelper = alertHelper
        self.pageService = pageService
        self.templateService = templateService
    }

    func showPage(objectId: String) {
        guard let details = document.detailsStorage.get(id: objectId) else {
            anytypeAssertionFailure("Details not found")
            return
        }
        guard !details.isDeleted else { return }
        
        showPage(data: details.editorScreenData())
    }
    
    func showPage(data: EditorScreenData) {
        editorPageCoordinator.startFlow(data: data, replaceCurrentPage: false)
    }

    func replaceCurrentPage(with data: EditorScreenData) {
        editorPageCoordinator.startFlow(data: data, replaceCurrentPage: true)
    }
    
    func showAlert(alertModel: AlertModel) {
        let alertController = AlertsFactory.alertController(from: alertModel)
        navigationContext.present(alertController)
    }
    
    func showLinkContextualMenu(inputParameters: TextBlockURLInputParameters) {
        let contextualMenuView = EditorContextualMenuView(
            options: [.pasteAsLink, .createBookmark, .pasteAsText],
            optionTapHandler: { [weak self] option in
                self?.navigationContext.dismissTopPresented(animated: false)
                inputParameters.optionHandler(option)
            }
        )

        let hostViewController = UIHostingController(rootView: contextualMenuView)
        hostViewController.modalPresentationStyle = .popover

        hostViewController.preferredContentSize = hostViewController
            .sizeThatFits(in: hostViewController.view.bounds.size)

        if let popoverPresentationController = hostViewController.popoverPresentationController {
            popoverPresentationController.sourceRect = inputParameters.rect
            popoverPresentationController.sourceView = inputParameters.textView
            popoverPresentationController.delegate = self
            popoverPresentationController.permittedArrowDirections = [.up, .down]
            navigationContext.present(hostViewController)
        }
    }
    
    func openUrl(_ url: URL) {
        urlOpener.openUrl(url)
    }
    
    func showBookmarkBar(completion: @escaping (AnytypeURL) -> ()) {
        showURLInputViewController { url in
            guard let url = url else { return }
            completion(url)
        }
    }
    
    func showLinkMarkup(url: AnytypeURL?, completion: @escaping (AnytypeURL?) -> Void) {
        showURLInputViewController(url: url, completion: completion)
    }
    
    func showFilePicker(model: Picker.ViewModel) {
        let vc = Picker(model)
        navigationContext.present(vc)
    }
    
    func showImagePicker(contentType: MediaPickerContentType, onSelect: @escaping (NSItemProvider?) -> Void) {
        let vc = UIHostingController(
            rootView: MediaPickerView(
                contentType: contentType,
                onSelect: onSelect
            )
        )
        navigationContext.present(vc)
    }
    
    func saveFile(fileURL: URL, type: FileContentType) {
        fileCoordinator.downloadFileAt(fileURL, withType: type)
    }
    
    func showCodeLanguage(blockId: BlockId, selectedLanguage: CodeLanguage) {
        if FeatureFlags.newCodeLanguages {
            let module = codeLanguageListModuleAssembly.make(document: document, blockId: blockId, selectedLanguage: selectedLanguage)
            navigationContext.present(module)
        } else {
            let moduleViewController = codeLanguageListModuleAssembly.makeLegacy(document: document, blockId: blockId)
            navigationContext.present(moduleViewController)
        }
    }
    
    func showStyleMenu(
        informations: [BlockInformation],
        restrictions: BlockRestrictions,
        didShow: @escaping (UIView) -> Void,
        onDismiss: @escaping () -> Void
    ) {
        let infos = informations.compactMap { document.infoContainer.get(id: $0.id) }
        guard
            let controller = viewController,
            let rootController = rootController,
            infos.isNotEmpty
        else { return }
        guard let controller = controller as? EditorPageController else {
            anytypeAssertionFailure("Not supported type of controller", info: ["controller": "\(controller)"])
            return
        }

        let popup = BottomSheetsFactory.createStyleBottomSheet(
            parentViewController: rootController,
            infos: infos,
            actionHandler: controller.viewModel.actionHandler,
            restrictions: restrictions,
            showMarkupMenu: { [weak controller, weak rootController, weak self] styleView, viewDidClose in
                guard let self = self else { return }
                guard let controller = controller else { return }
                guard let rootController = rootController else { return }

                BottomSheetsFactory.showMarkupBottomSheet(
                    parentViewController: rootController,
                    styleView: styleView,
                    document: self.document,
                    blockIds: infos.map { $0.id },
                    actionHandler: controller.viewModel.actionHandler,
                    linkToObjectCoordinator: self.linkToObjectCoordinator,
                    viewDidClose: viewDidClose
                )
            },
            onDismiss: onDismiss
        )

        guard let popup = popup else {
            return
        }

        popup.addPanel(toParent: controller, animated: true) {
            didShow(popup.surfaceView)
        }
    }
    
    func showMoveTo(onSelect: @escaping (ObjectDetails) -> ()) {
        
        let moveToView = newSearchModuleAssembly.blockObjectsSearchModule(
            title: Loc.moveTo,
            excludedObjectIds: [document.objectId],
            excludedTypeIds: [
                ObjectTypeId.bundled(.set).rawValue,
                ObjectTypeId.bundled(.collection).rawValue
            ]
        ) { [weak self] details in
            onSelect(details)
            self?.navigationContext.dismissTopPresented()
        }

        navigationContext.presentSwiftUIView(view: moveToView, model: nil)
    }

    func showLinkTo(onSelect: @escaping (ObjectDetails) -> ()) {
        let moduleView = newSearchModuleAssembly.blockObjectsSearchModule(
            title: Loc.linkTo,
            excludedObjectIds: [document.objectId],
            excludedTypeIds: []
        ) { [weak self] details in
            onSelect(details)
            self?.navigationContext.dismissTopPresented()
        }

        navigationContext.presentSwiftUIView(view: moduleView)
    }

    func showTextIconPicker(contextId: BlockId, objectId: BlockId) {
        let moduleView = textIconPickerModuleAssembly.make(
            contextId: contextId,
            objectId: objectId,
            onDismiss: { [weak self] in
                self?.navigationContext.dismissTopPresented()
            }
        )

        navigationContext.presentSwiftUIView(view: moduleView, model: nil)
    }
    
    func showSearch(onSelect: @escaping (EditorScreenData) -> ()) {
        let module = searchModuleAssembly.makeObjectSearch(title: nil) { data in
            onSelect(data.editorScreenData)
        }
        navigationContext.present(module)
    }
    
    func showTypes(selectedObjectId: BlockId?, onSelect: @escaping (BlockId) -> ()) {
        showTypesSearch(
            title: Loc.changeType,
            selectedObjectId: selectedObjectId,
            showBookmark: false,
            showSetAndCollection: false,
            onSelect: onSelect
        )
    }
    
    func showTypesForEmptyObject(
        selectedObjectId: BlockId?,
        onSelect: @escaping (BlockId) -> ()
    ) {
        showTypesSearch(
            title: Loc.changeType,
            selectedObjectId: selectedObjectId,
            showBookmark: false,
            showSetAndCollection: true,
            onSelect: onSelect
        )
    }
    
    func showWaitingView(text: String) {
        let popup = PopupViewBuilder.createWaitingPopup(text: text)
        navigationContext.present(popup)
    }

    func hideWaitingView() {
        navigationContext.dismissTopPresented()
    }
    
    func closeEditor() {
        guard let viewController else { return }
        rootController?.popIfPresent(viewController)
    }
    
    func presentSheet(_ vc: UIViewController) {
        if #available(iOS 15.0, *) {
            if let sheet = vc.sheetPresentationController {
                sheet.detents = [.medium(), .large()]
                sheet.selectedDetentIdentifier = .medium
            }
        }
        navigationContext.present(vc)
    }
    
    func presentFullscreen(_ vc: UIViewController) {
        navigationContext.present(vc)
    }
    
    @MainActor
    func showObjectPreview(
        blockLinkState: BlockLinkState,
        onSelect: @escaping (BlockLink.Appearance) -> Void
    ) {
        let router = ObjectPreviewRouter(viewController: viewController)
        let viewModel = ObjectPreviewViewModel(
            blockLinkState: blockLinkState,
            router: router,
            onSelect: onSelect
        )

        let contentView = ObjectPreviewView(viewModel: viewModel)
        let popup = AnytypePopup(contentView: contentView)

        navigationContext.present(popup)

    }

    func showTemplatesPopupIfNeeded(
        document: BaseDocumentProtocol,
        templatesTypeId: ObjectTypeId,
        onShow: (() -> Void)?
    ) {
        templatesCoordinator.showTemplatesPopupIfNeeded(
            document: document,
            templatesTypeId: .dynamic(templatesTypeId.rawValue),
            onShow: onShow
        )
    }
    
    func showTemplatesPopupWithTypeCheckIfNeeded(
        document: BaseDocumentProtocol,
        templatesTypeId: ObjectTypeId,
        onShow: (() -> Void)?
    ) {
        templatesCoordinator.showTemplatesPopupWithTypeCheckIfNeeded(
            document: document,
            templatesTypeId: .dynamic(templatesTypeId.rawValue),
            onShow: onShow
        )
    }
    
    // MARK: - Settings
    func showSettings() {
        objectSettingCoordinator.startFlow(objectId: document.objectId, delegate: self, output: self)
    }
    
    func showCoverPicker() {
        let moduleViewController = objectCoverPickerModuleAssembly.make(document: document, objectId: document.objectId)
        navigationContext.present(moduleViewController)
    }
    
    func showIconPicker() {
        let moduleViewController = objectIconPickerModuleAssembly.make(document: document, objectId: document.objectId)
        navigationContext.present(moduleViewController)
    }

    func showColorPicker(
        onColorSelection: @escaping (ColorView.ColorItem) -> Void,
        selectedColor: UIColor?,
        selectedBackgroundColor: UIColor?
    ) {
        guard let rootController = rootController else { return }

        let styleColorViewController = StyleColorViewController(
            selectedColor: selectedColor,
            selectedBackgroundColor: selectedBackgroundColor,
            onColorSelection: onColorSelection) { viewController in
                viewController.removeFromParentEmbed()
            }

        rootController.embedChild(styleColorViewController)

        styleColorViewController.view.pinAllEdges(to: rootController.view)
        styleColorViewController.colorView.containerView.layoutUsing.anchors {
            $0.width.equal(to: 260)
            $0.height.equal(to: 176)
            $0.centerX.equal(to: rootController.view.centerXAnchor, constant: 10)
            $0.bottom.equal(to: rootController.view.bottomAnchor, constant: -50)
        }
        UISelectionFeedbackGenerator().selectionChanged()
    }

    func showMarkupBottomSheet(
        selectedBlockIds: [BlockId],
        viewDidClose: @escaping () -> Void
    ) {
        guard let controller = viewController,
            let rootController = rootController else { return }
        guard let controller = controller as? EditorPageController else {
            anytypeAssertionFailure("Not supported type of controller", info: ["controller": "\(controller)"])
            return
        }
        
        let viewModel = MarkupViewModel(
            document: document,
            blockIds: selectedBlockIds,
            actionHandler: controller.viewModel.actionHandler,
            linkToObjectCoordinator: linkToObjectCoordinator
        )
        let viewController = MarkupsViewController(
            viewModel: viewModel,
            viewDidClose: viewDidClose
        )

        viewModel.view = viewController

        rootController.embedChild(viewController)

        viewController.view.pinAllEdges(to: rootController.view)
        viewController.containerShadowView.layoutUsing.anchors {
            $0.width.equal(to: 240)
            $0.height.equal(to: 158)
            $0.centerX.equal(to: rootController.view.centerXAnchor, constant: 10)
            $0.bottom.equal(to: rootController.view.bottomAnchor, constant: -50)
        }
    }
    
    func showFailureToast(message: String) {
        toastPresenter.showFailureAlert(message: message)
    }
    
    // MARK: - Private
    
    private func showURLInputViewController(
        url: AnytypeURL? = nil,
        completion: @escaping(AnytypeURL?) -> Void
    ) {
        let controller = URLInputViewController(url: url, didSetURL: completion)
        controller.modalPresentationStyle = .overCurrentContext
        navigationContext.present(controller, animated: false)
    }
    
    private func showTypesSearch(
        title: String,
        selectedObjectId: BlockId?,
        showBookmark: Bool,
        showSetAndCollection: Bool,
        onSelect: @escaping (BlockId) -> ()
    ) {
        let view = newSearchModuleAssembly.objectTypeSearchModule(
            title: title,
            selectedObjectId: selectedObjectId,
            excludedObjectTypeId: document.details?.type,
            showBookmark: showBookmark,
            showSetAndCollection: showSetAndCollection,
            browser: rootController
        ) { [weak self] type in
            self?.navigationContext.dismissTopPresented()
            onSelect(type.id)
        }
        
        navigationContext.presentSwiftUIView(view: view)
    }
}

extension EditorRouter: AttachmentRouterProtocol {
    func openImage(_ imageContext: FilePreviewContext) {
        let previewController = AnytypePreviewController(with: [imageContext.file], sourceView: imageContext.sourceView, onContentChanged: imageContext.onDidEditFile)

        navigationContext.present(previewController) { [weak previewController] in
            previewController?.didFinishTransition = true
        }
    }
}

// MARK: - Relations
extension EditorRouter {
    func showRelationValueEditingView(key: String) {
        let relation = document.parsedRelations.installed.first { $0.key == key }
        guard let relation = relation else { return }
        
        showRelationValueEditingView(objectId: document.objectId, relation: relation)
    }
    
    func showRelationValueEditingView(objectId: BlockId, relation: Relation) {
        guard let objectDetails = document.detailsStorage.get(id: objectId) else {
            anytypeAssertionFailure("Details not found")
            return
        }
        relationValueCoordinator.startFlow(objectDetails: objectDetails, relation: relation, analyticsType: .block, output: self)
    }

    func showAddNewRelationView(
        document: BaseDocumentProtocol,
        onSelect: ((RelationDetails, _ isNew: Bool) -> Void)?
    ) {
        addNewRelationCoordinator.showAddNewRelationView(
            document: document,
            excludedRelationsIds: document.parsedRelations.installed.map(\.id),
            target: .object,
            onCompletion: onSelect
        )
    }
}

extension EditorRouter: RelationValueCoordinatorOutput {
    func openObject(screenData: EditorScreenData) {
        navigationContext.dismissAllPresented()
        showPage(data: screenData)
    }
}

extension EditorRouter: ObjectSettingsModuleDelegate {
    func didCreateLinkToItself(selfName: String, data: EditorScreenData) {
        UIApplication.shared.hideKeyboard()
        toastPresenter.showObjectName(selfName, middleAction: Loc.Editor.Toast.linkedTo, secondObjectId: data.objectId) { [weak self] in
            self?.showPage(data: data)
        }
    }
    
    func didCreateTemplate(templateId: BlockId) {
        templateSelectionCoordinator.showTemplateEditing(blockId: templateId) { [weak self] templateSelection in
            Task { @MainActor [weak self] in
                do {
                    guard let type = self?.document.details?.type,
                          let objectDetails = try await self?.pageService.createPage(
                            name: "",
                            type: type,
                            shouldDeleteEmptyObject: true,
                            shouldSelectType: false,
                            shouldSelectTemplate: false,
                            templateId: templateSelection
                          ) else {
                        return
                    }
                    
                    self?.openObject(screenData: .init(details: objectDetails, shouldShowTemplatesOptions: false))
                } catch {
                    print(error.localizedDescription)
                }
            }
        } onSetAsDefaultTempalte: { [weak self] templateId in
            self?.didTapUseTemplateAsDefault(templateId: templateId)
        }
    }
    
    func didTapUseTemplateAsDefault(templateId: BlockId) {
        Task { @MainActor in
            try? await templateService.setTemplateAsDefaultForType(templateId: templateId)
            navigationContext.dismissTopPresented(animated: true, completion: nil)
            toastPresenter.show(message: Loc.Templates.Popup.default)
        }
    }
}


// MARK: - UIPopoverPresentationControllerDelegate

extension EditorRouter: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }

    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {

    }

    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        return true
    }
}
