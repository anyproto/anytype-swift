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
    func layoutPickerAction(document: some BaseDocumentProtocol)
    func relationsAction(document: some BaseDocumentProtocol)
    func showVersionHistory(document: some BaseDocumentProtocol)
    func openPageAction(screenData: EditorScreenData)
    func linkToAction(document: some BaseDocumentProtocol, onSelect: @escaping (String) -> ())
    func closeEditorAction()
    func didCreateLinkToItself(selfName: String, data: EditorScreenData)
    func didCreateTemplate(templateId: String)
    func didTapUseTemplateAsDefault(templateId: String)
}

@MainActor
final class ObjectSettingsViewModel: ObservableObject, ObjectActionsOutput {

    @Injected(\.documentService)
    private var openDocumentsProvider: any OpenedDocumentsProviderProtocol
    
    private weak var output: (any ObjectSettingsModelOutput)?
    private let settingsBuilder = ObjectSettingBuilder()
    
    private lazy var document: any BaseDocumentProtocol = {
        openDocumentsProvider.document(objectId: objectId, spaceId: spaceId)
    }()
    
    let objectId: String
    let spaceId: String
    @Published var settings: [ObjectSetting] = []
    
    init(
        objectId: String,
        spaceId: String,
        output: some ObjectSettingsModelOutput
    ) {
        self.objectId = objectId
        self.spaceId = spaceId
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
    
    func onTapIconPicker() {
        output?.showIconPicker(document: document)
    }
    
    func onTapCoverPicker() {
        output?.showCoverPicker(document: document)
    }
    
    func onTapRelations() {
        output?.relationsAction(document: document)
    }
    
    func onTapHistory() {
        output?.showVersionHistory(document: document)
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
