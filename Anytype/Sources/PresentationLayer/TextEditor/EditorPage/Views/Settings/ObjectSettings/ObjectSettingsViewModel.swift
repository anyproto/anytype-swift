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
    func didCreateLinkToItself(selfName: String, data: EditorScreenData)
    func didCreateTemplate(templateId: String)
    func didTapUseTemplateAsDefault(templateId: String)
}

@MainActor
final class ObjectSettingsViewModel: ObservableObject, ObjectActionsOutput {
    
    var settings: [ObjectSetting] {
        guard let details = document.details else { return [] }
        return settingsBuilder.build(
            details: details,
            permissions: document.permissions
        )
    }

    private let document: BaseDocumentProtocol
    private let settingsBuilder = ObjectSettingBuilder()
    private let settingsActionHandler: (ObjectSettingsAction) -> Void
    
    private var subscription: AnyCancellable?
    private var onLinkItselfToObjectHandler: ((EditorScreenData) -> Void)?
    
    private weak var output: ObjectSettingsModelOutput?
    
    var objectId: String { document.objectId }
    
    init(
        document: BaseDocumentProtocol,
        output: ObjectSettingsModelOutput,
        settingsActionHandler: @escaping (ObjectSettingsAction) -> Void
    ) {
        self.document = document
        self.output = output
        self.settingsActionHandler = settingsActionHandler
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
    
    // MARK: - ObjectActionsOutput
    
    func undoRedoAction() {
        output?.undoRedoAction(document: document)
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
