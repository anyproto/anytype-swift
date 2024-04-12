import Foundation
import Combine
import Services
import UIKit
import FloatingPanel
import SwiftUI
import DeepLinks

enum ObjectSettingsAction {
    case cover(ObjectCoverPickerAction)
    case icon(ObjectIconPickerAction)
}

@MainActor
protocol ObjectSettingsModelOutput: AnyObject, ObjectHeaderRouterProtocol, ObjectHeaderModuleOutput {
    func undoRedoAction(document: BaseDocumentProtocol)
    func layoutPickerAction(document: BaseDocumentProtocol)
    func relationsAction(document: BaseDocumentProtocol)
    func openPageAction(screenData: EditorScreenData)
    func linkToAction(document: BaseDocumentProtocol, onSelect: @escaping (String) -> ())
    func closeEditorAction()
}

@MainActor
final class ObjectSettingsViewModel: ObservableObject {
    
    var settings: [ObjectSetting] {
        guard let details = document.details else { return [] }
        return settingsBuilder.build(
            details: details,
            permissions: document.permissions
        )
    }
    
    let objectActionsViewModel: ObjectActionsViewModel

    private let document: BaseDocumentProtocol
    private let settingsBuilder = ObjectSettingBuilder()
    private let settingsActionHandler: (ObjectSettingsAction) -> Void
    
    private var subscription: AnyCancellable?
    private var onLinkItselfToObjectHandler: ((EditorScreenData) -> Void)?
    
    private weak var output: ObjectSettingsModelOutput?
    private weak var delegate: ObjectSettingsModuleDelegate?
    init(
        document: BaseDocumentProtocol,
        objectActionsService: ObjectActionsServiceProtocol,
        blockService: BlockServiceProtocol,
        templatesService: TemplatesServiceProtocol,
        output: ObjectSettingsModelOutput,
        delegate: ObjectSettingsModuleDelegate,
        blockWidgetService: BlockWidgetServiceProtocol,
        activeWorkpaceStorage: ActiveWorkpaceStorageProtocol,
        deepLinkParser: DeepLinkParserProtocol,
        settingsActionHandler: @escaping (ObjectSettingsAction) -> Void,
        documentsProvider: DocumentsProviderProtocol
    ) {
        self.document = document
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
            deepLinkParser: deepLinkParser,
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
}
