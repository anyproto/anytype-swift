import UIKit
import Services
import SafariServices
import SwiftUI
import FloatingPanel
import AnytypeCore

final class EditorRouter: NSObject, EditorRouterProtocol, ObjectSettingsCoordinatorOutput {
    private weak var viewController: UIViewController?
    @Injected(\.legacyNavigationContext)
    private var navigationContext: any NavigationContextProtocol
    private let fileCoordinator: FileDownloadingCoordinator
    private let document: any BaseDocumentProtocol
    @Injected(\.legacyTemplatesCoordinator)
    private var templatesCoordinator: any TemplatesCoordinatorProtocol
    @Injected(\.legacySetObjectCreationSettingsCoordinator)
    private var setObjectCreationSettingsCoordinator: any SetObjectCreationSettingsCoordinatorProtocol
    @Injected(\.legacyToastPresenter)
    private var toastPresenter: any ToastPresenterProtocol
    private weak var output: (any EditorPageModuleOutput)?
    
    @Injected(\.templatesService)
    private var templateService: any TemplatesServiceProtocol

    init(
        viewController: UIViewController,
        document: some BaseDocumentProtocol,
        output: (any EditorPageModuleOutput)?
    ) {
        self.viewController = viewController
        self.document = document
        self.fileCoordinator = FileDownloadingCoordinator(viewController: viewController)
        self.output = output
        
        super.init()
    }

    func showObject(objectId: String, forceOpenObject: Bool) {
        guard let details = document.detailsStorage.get(id: objectId) else {
            anytypeAssertionFailure("Details not found")
            return
        }
        guard !details.isDeleted else { return }
        
        showEditorScreen(data: details.screenData(openBookmarkAsObject: forceOpenObject))
    }
    
    func showObject(objectId: String) {
        showObject(objectId: objectId, forceOpenObject: false)
    }
    
    func showEditorScreen(data: ScreenData) {
        Task { @MainActor in
            output?.showEditorScreen(data: data)
        }
    }

    func replaceCurrentPage(with data: EditorScreenData) {
        Task { @MainActor in
            output?.replaceEditorScreen(data: data)
        }
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
    
    func showBookmarkBar(completion: @escaping (AnytypeURL) -> ()) {
        showURLInputViewController { url in
            guard let url = url else { return }
            completion(url)
        }
    }
    
    func showLinkMarkup(url: AnytypeURL?, completion: @escaping (AnytypeURL?) -> Void) {
        showURLInputViewController(url: url, completion: completion)
    }
    
    func showFilePicker(model: AnytypePicker.ViewModel) {
        let vc = AnytypePicker(model)
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
        fileCoordinator.downloadFileAt(fileURL, withType: type, spaceId: document.spaceId)
    }
        
    @MainActor
    func showStyleMenu(
        informations: [BlockInformation],
        restrictions: any BlockRestrictions,
        didShow: @escaping (UIView) -> Void,
        onDismiss: @escaping () -> Void
    ) {
        let infos = informations.compactMap { document.infoContainer.get(id: $0.id) }
        guard
            let controller = viewController,
            infos.isNotEmpty
        else { return }
        guard let controller = controller as? EditorPageController else {
            anytypeAssertionFailure("Not supported type of controller", info: ["controller": "\(controller)"])
            return
        }

        let popup = BottomSheetsFactory.createStyleBottomSheet(
            parentViewController: controller,
            infos: infos,
            actionHandler: controller.viewModel.actionHandler,
            restrictions: restrictions,
            showMarkupMenu: { [weak controller, weak self] styleView, viewDidClose in
                guard let self = self else { return }
                guard let controller = controller else { return }

                BottomSheetsFactory.showMarkupBottomSheet(
                    parentViewController: controller,
                    styleView: styleView,
                    document: self.document,
                    blockIds: infos.map { $0.id },
                    actionHandler: controller.viewModel.actionHandler,
                    viewDidClose: viewDidClose,
                    openLinkToObject: { [weak self] data in
                        self?.output?.showLinkToObject(data: data)
                    }
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
        let excludedLayouts = DetailsLayout.fileAndMediaLayouts + DetailsLayout.listLayouts
        let data = BlockObjectSearchData(
            title: Loc.moveTo,
            spaceId: document.spaceId,
            excludedObjectIds: [document.objectId],
            excludedLayouts: excludedLayouts,
            onSelect: onSelect
        )
        output?.showBlockObjectSearch(data: data)
    }

    func showLinkTo(onSelect: @escaping (ObjectDetails) -> ()) {
        let data = BlockObjectSearchData(
            title: Loc.linkTo,
            spaceId: document.spaceId,
            excludedObjectIds: [document.objectId],
            excludedLayouts: [],
            onSelect: onSelect
        )
        output?.showBlockObjectSearch(data: data)
    }

    func showTextIconPicker(contextId: String, objectId: String) {
        // In feature space id should be read from blockInfo, when we will create "link to" between sapces
        output?.showTextIconPicker(data: TextIconPickerData(contextId: contextId, objectId: objectId, spaceId: document.spaceId))
    }
    
    func showTypes(selectedObjectId: String?, onSelect: @escaping (ObjectType) -> ()) {
        let view = ObjectTypeSearchView(
            title: Loc.changeType,
            spaceId: document.spaceId,
            settings: .editorChangeType
        ) { [weak self] type in
            self?.navigationContext.dismissTopPresented()
            onSelect(type)
        }
        
        navigationContext.presentSwiftUIView(view: view)
    }
    
    func showTypeSearchForObjectCreation(
        selectedObjectId: String?,
        onSelect: @escaping (TypeSelectionResult) -> ()
    ) {
        let view = ObjectTypeSearchView(
            title: Loc.changeType,
            spaceId: document.spaceId,
            settings: .newObjectCreation
        ) { [weak self] result in
            self?.navigationContext.dismissTopPresented()
            onSelect(result)
        }
        
        navigationContext.presentSwiftUIView(view: view)
    }
    
    func showWaitingView(text: String) {
        let popup = PopupViewBuilder.createWaitingPopup(text: text)
        navigationContext.present(popup)
    }

    func hideWaitingView() {
        navigationContext.dismissTopPresented()
    }
    
    func closeEditor() {
        Task { @MainActor in
            output?.closeEditor()
        }
    }
    
    func presentSheet(_ vc: UIViewController) {
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.selectedDetentIdentifier = .medium
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

    // MARK: - Settings
    func showSettings() {
        showSettings(output: self)
    }
    
    func showSettings(output settingsOutput: any ObjectSettingsCoordinatorOutput) {
        output?.showObectSettings(output: settingsOutput)
    }
    
    func showIconPicker(document: some BaseDocumentProtocol) {
        output?.showIconPicker(document: document)
    }

    func showColorPicker(
        onColorSelection: @escaping (ColorView.ColorItem) -> Void,
        selectedColor: UIColor?,
        selectedBackgroundColor: UIColor?
    ) {
        guard let viewController = viewController else { return }

        let styleColorViewController = StyleColorViewController(
            selectedColor: selectedColor,
            selectedBackgroundColor: selectedBackgroundColor,
            onColorSelection: onColorSelection) { viewController in
                viewController.removeFromParentEmbed()
            }

        viewController.embedChild(styleColorViewController)

        styleColorViewController.view.pinAllEdges(to: viewController.view)
        styleColorViewController.colorView.containerView.layoutUsing.anchors {
            $0.width.equal(to: 260)
            $0.height.equal(to: 176)
            $0.centerX.equal(to: viewController.view.centerXAnchor, constant: 10)
            $0.bottom.equal(to: viewController.view.bottomAnchor, constant: -50)
        }
        UISelectionFeedbackGenerator().selectionChanged()
    }

    @MainActor
    func showMarkupBottomSheet(
        selectedBlockIds: [String],
        viewDidClose: @escaping () -> Void
    ) {
        guard let controller = viewController else { return }
        guard let controller = controller as? EditorPageController else {
            anytypeAssertionFailure("Not supported type of controller", info: ["controller": "\(controller)"])
            return
        }
        
        let viewModel = MarkupViewModel(
            document: document,
            blockIds: selectedBlockIds,
            actionHandler: controller.viewModel.actionHandler,
            openLinkToObject: { [weak self] data in
                self?.output?.showLinkToObject(data: data)
            }
        )
        let viewController = MarkupsViewController(
            viewModel: viewModel,
            viewDidClose: viewDidClose
        )

        viewModel.view = viewController

        controller.embedChild(viewController)

        viewController.view.pinAllEdges(to: controller.view)
        viewController.containerShadowView.layoutUsing.anchors {
            $0.width.equal(to: 240)
            $0.height.equal(to: 158)
            $0.centerX.equal(to: controller.view.centerXAnchor, constant: 10)
            $0.bottom.equal(to: controller.view.bottomAnchor, constant: -50)
        }
    }
    
    @MainActor
    func showTemplatesPicker() {
        templatesCoordinator.showTemplatesPicker(
            document: document,
            onSetAsDefaultTempalte: { [weak self] templateId in
                self?.didTapUseTemplateAsDefault(templateId: templateId)
            }
        )
    }
    
    func didUndoRedo() {
        output?.didUndoRedo()
    }
    
    func versionRestored(_ text: String) {
        output?.versionRestored(text)
    }
    
    func showDatePicker(onDateSelection: @escaping (Date) -> Void) {
        let view = CalendarConfirmationDateView(
            date: Date(),
            onApply: { newDate in
                onDateSelection(newDate)
            }
        )
        navigationContext.presentSwiftUIView(view: view)
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
}

// MARK: - Relations
extension EditorRouter {
    @MainActor
    func showRelationValueEditingView(key: String) {
        let relation = document.parsedRelations.installed.first { $0.key == key }
        guard let relation = relation else { return }
        
        output?.showRelationValueEditingView(document: document, relation: relation)
    }

    @MainActor
    func showAddRelationInfoView(document: some BaseDocumentProtocol, onSelect: @escaping (RelationDetails, _ isNew: Bool) -> Void) {
        output?.showAddRelationInfoView(document: document, onSelect: onSelect)
    }
}

extension EditorRouter: RelationValueCoordinatorOutput {
    func openObject(screenData: ScreenData) {
        navigationContext.dismissAllPresented()
        showEditorScreen(data: screenData)
    }
}

extension EditorRouter {
    func didCreateLinkToItself(selfName: String, data: ScreenData) {
        guard let objectId = data.objectId else { return }
        UIApplication.shared.hideKeyboard()
        toastPresenter.showObjectName(selfName, middleAction: Loc.Editor.Toast.linkedTo, secondObjectId: objectId, spaceId: data.spaceId) { [weak self] in
            self?.showEditorScreen(data: data)
        }
    }
    
    @MainActor
    func didCreateTemplate(templateId: String) {
        guard let objectType = document.details?.objectType else { return }
        let setting = ObjectCreationSetting(objectTypeId: objectType.id, spaceId: document.spaceId, templateId: templateId)
        setObjectCreationSettingsCoordinator.showTemplateEditing(
            setting: setting,
            onTemplateSelection: nil,
            onSetAsDefaultTempalte: { [weak self] templateId in
                self?.didTapUseTemplateAsDefault(templateId: templateId)
            },
            completion: { [weak self] in
                self?.toastPresenter.showObjectCompositeAlert(
                    prefixText: Loc.Templates.Popup.wasAddedTo,
                    objectId: objectType.id,
                    spaceId: objectType.spaceId,
                    tapHandler: { }
                )
            }
        )
    }
    
    func didTapUseTemplateAsDefault(templateId: String) {
        guard let objectTypeId = document.details?.objectType.id else { return }
        Task { @MainActor in
            try? await templateService.setTemplateAsDefaultForType(objectTypeId: objectTypeId, templateId: templateId)
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
