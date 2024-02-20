import Foundation
import Combine
import Services
import UIKit
import FloatingPanel
import SwiftUI

enum ObjectSettingsAction {
    case cover(ObjectCoverPickerAction)
    case icon(ObjectIconPickerAction)
}

@MainActor
protocol ObjectSettingsModelOutput: AnyObject, ObjectHeaderRouterProtocol {
    func undoRedoAction(document: BaseDocumentProtocol)
    func layoutPickerAction(document: BaseDocumentProtocol)
    func relationsAction(document: BaseDocumentProtocol)
    func openPageAction(screenData: EditorScreenData)
    func linkToAction(document: BaseDocumentProtocol, onSelect: @escaping (String) -> ())
    func closeEditorAction()
}

@MainActor
final class ObjectSettingsViewModel: ObservableObject {
   
    var onDismiss: () -> Void = {} {
        didSet {
            objectActionsViewModel.dismissSheet = onDismiss
        }
    }
    
    var settings: [ObjectSetting] {
        guard let details = document.details else { return [] }
        return settingsBuilder.build(
            details: details,
            restrictions: objectActionsViewModel.objectRestrictions,
            isReadonly: document.isLocked || document.isArchived
        )
    }
    
    let objectActionsViewModel: ObjectActionsViewModel

    private let document: BaseDocumentProtocol
    private let objectDetailsService: DetailsServiceProtocol
    private let settingsBuilder = ObjectSettingBuilder()
    private let settingsActionHandler: (ObjectSettingsAction) -> Void
    
    private var subscription: AnyCancellable?
    private var onLinkItselfToObjectHandler: ((EditorScreenData) -> Void)?
    
    private weak var output: ObjectSettingsModelOutput?
    private weak var delegate: ObjectSettingsModuleDelegate?
    init(
        document: BaseDocumentProtocol,
        objectDetailsService: DetailsServiceProtocol,
        objectActionsService: ObjectActionsServiceProtocol,
        blockService: BlockServiceProtocol,
        templatesService: TemplatesServiceProtocol,
        output: ObjectSettingsModelOutput,
        delegate: ObjectSettingsModuleDelegate,
        blockWidgetService: BlockWidgetServiceProtocol,
        activeWorkpaceStorage: ActiveWorkpaceStorageProtocol,
        settingsActionHandler: @escaping (ObjectSettingsAction) -> Void,
        documentsProvider: DocumentsProviderProtocol
    ) {
        self.document = document
        self.objectDetailsService = objectDetailsService
        self.output = output
        self.delegate = delegate
        self.settingsActionHandler = settingsActionHandler
        
        self.objectActionsViewModel = ObjectActionsViewModel(
            objectId: document.objectId,
            service: objectActionsService,
            blockService: blockService,
            templatesService: templatesService,
            documentsProvider: documentsProvider,
            blockWidgetService: blockWidgetService,
            activeWorkpaceStorage: activeWorkpaceStorage,
            undoRedoAction: { [weak output] in
                output?.undoRedoAction(document: document)
            },
            openPageAction: { [weak output] screenData in
                output?.openPageAction(screenData: screenData)
            },
            closeEditorAction: { [weak output] in
                output?.closeEditorAction()
            }
        )
        
        objectActionsViewModel.onNewTemplateCreation = { [weak delegate] templateId in
            DispatchQueue.main.async {
                delegate?.didCreateTemplate(templateId: templateId)
            }
        }
        
        objectActionsViewModel.onLinkItselfToObjectHandler = { [weak delegate] data in
            guard let documentName = document.details?.name else { return }
            delegate?.didCreateLinkToItself(selfName: documentName, data: data)
        }

        objectActionsViewModel.onLinkItselfAction = { [weak output] onSelect in
            output?.linkToAction(document: document, onSelect: onSelect)
        }
        
        objectActionsViewModel.onTemplateMakeDefault = { [weak delegate] templateId in
            delegate?.didTapUseTemplateAsDefault(templateId: templateId)
        }
        
        setupSubscription()
        onDocumentUpdate()
    }

    func onTapLayoutPicker() {
        output?.layoutPickerAction(document: document)
    }
    
    func onTapIconPicker() {
        output?.showIconPicker(document: document) { [weak self] action in
            self?.settingsActionHandler(.icon(action))
        }
    }
    
    func onTapCoverPicker() {
        output?.showCoverPicker(document: document) { [weak self] action in
            self?.settingsActionHandler(.cover(action))
        }
    }
    
    func onTapRelations() {
        output?.relationsAction(document: document)
    }
    
    // MARK: - Private
    private func setupSubscription() {
        subscription = document.syncPublisher.sink { [weak self] in
            self?.onDocumentUpdate()
        }
    }
    
    private func onDocumentUpdate() {
        objectWillChange.send()
        if let details = document.details {
            objectActionsViewModel.details = details
        }
        objectActionsViewModel.isLocked = document.isLocked
        objectActionsViewModel.isArchived = document.isArchived
        objectActionsViewModel.objectRestrictions = document.objectRestrictions
    }
}
