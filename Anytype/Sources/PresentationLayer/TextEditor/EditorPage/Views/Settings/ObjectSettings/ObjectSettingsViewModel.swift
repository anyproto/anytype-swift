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
    func undoRedoAction(objectId: String)
    func layoutPickerAction(document: BaseDocumentProtocol)
    func relationsAction(document: BaseDocumentProtocol)
    func openPageAction(screenData: EditorScreenData)
    func linkToAction(document: BaseDocumentProtocol, onSelect: @escaping (String) -> ())
    func closeEditorAction()
    func didCreateLinkToItself(selfName: String, data: EditorScreenData)
    func didCreateTemplate(templateId: String)
    func didTapUseTemplateAsDefault(templateId: String)
}

@MainActor
final class ObjectSettingsViewModel: ObservableObject, ObjectActionsOutput {

    @Injected(\.documentService)
    private var openDocumentsProvider: OpenedDocumentsProviderProtocol
    
    private weak var output: ObjectSettingsModelOutput?
    private let settingsBuilder = ObjectSettingBuilder()
    
    private lazy var document: BaseDocumentProtocol = {
        openDocumentsProvider.document(objectId: objectId)
    }()
    
    let objectId: String
    @Published var settings: [ObjectSetting] = []
    
    init(
        objectId: String,
        output: ObjectSettingsModelOutput
    ) {
        self.objectId = objectId
        self.output = output
    }

    func startDocumentTask() async {
        for await _ in document.syncPublisher.receiveOnMain().values {
            if let details = document.details {
                settings = settingsBuilder.build(
                    details: details,
                    permissions: document.permissions
                )
            }
        }
    }
    
    func onTapLayoutPicker() {
        output?.layoutPickerAction(document: document)
    }
    
    func onTapIconPicker() {
        output?.showIconPicker(document: document)
    }
    
    func onTapCoverPicker() {
        output?.showCoverPicker(document: document)
    }
    
    func onTapRelations() {
        output?.relationsAction(document: document)
    }
    
    // MARK: - ObjectActionsOutput
    
    func undoRedoAction() {
        output?.undoRedoAction(objectId: objectId)
    }
    
    func openPageAction(screenData: EditorScreenData) {
        output?.openPageAction(screenData: screenData)
    }
    
    func closeEditorAction() {
        output?.closeEditorAction()
    }
    
    func onLinkItselfAction(onSelect: @escaping (String) -> Void) {
        output?.linkToAction(document: document, onSelect: onSelect)
    }
    
    func onNewTemplateCreation(templateId: String) {
        output?.didCreateTemplate(templateId: templateId)
    }
    
    func onTemplateMakeDefault(templateId: String) {
        output?.didTapUseTemplateAsDefault(templateId: templateId)
    }
    
    func onLinkItselfToObjectHandler(data: EditorScreenData) {
        guard let documentName = document.details?.name else { return }
        output?.didCreateLinkToItself(selfName: documentName, data: data)
    }
}
