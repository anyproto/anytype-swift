import Foundation
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
    func relationsAction(document: some BaseDocumentProtocol)
    func showVersionHistory(document: some BaseDocumentProtocol)
    func showPublising(document: some BaseDocumentProtocol)
    func openPageAction(screenData: ScreenData)
    func linkToAction(document: some BaseDocumentProtocol, onSelect: @escaping (String) -> ())
    func closeEditorAction()
    func didCreateLinkToItself(selfName: String, data: ScreenData)
    func didCreateTemplate(templateId: String)
    func didTapUseTemplateAsDefault(templateId: String)
}

@MainActor
@Observable
final class ObjectSettingsViewModel: ObjectActionsOutput {

    @Injected(\.openedDocumentProvider) @ObservationIgnored
    private var openDocumentsProvider: any OpenedDocumentsProviderProtocol
    @Injected(\.propertiesService) @ObservationIgnored
    private var propertiesService: any PropertiesServiceProtocol
    @Injected(\.objectSettingsBuilder) @ObservationIgnored
    private var settingsBuilder: any ObjectSettingsBuilderProtocol
    @Injected(\.objectSettingsConflictManager) @ObservationIgnored
    private var conflictManager: any ObjectSettingsPrimitivesConflictManagerProtocol

    @ObservationIgnored
    private weak var output: (any ObjectSettingsModelOutput)?

    @ObservationIgnored
    private lazy var document: any BaseDocumentProtocol = {
        openDocumentsProvider.document(objectId: objectId, spaceId: spaceId)
    }()

    @ObservationIgnored
    let objectId: String
    @ObservationIgnored
    let spaceId: String
    var settings: [ObjectSetting] = []
    var showConflictAlert = false
    
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
    
    func onTapDescription() async throws {
        guard let details = document.details else { return }
        
        let descriptionIsOn = details.featuredRelations.contains(where: { $0 == BundledPropertyKey.description.rawValue })
        try await propertiesService.toggleDescription(objectId: document.objectId, isOn: !descriptionIsOn)
    }
    
    func onTapResolveConflict() {
        showConflictAlert.toggle()
    }
    
    func onTapResolveConflictApprove() async throws {
        guard let details = document.details else { return }
        try await conflictManager.resolveConflicts(details: details)
        AnytypeAnalytics.instance().logResetToTypeDefault()
    }
    
    func onTapPublishing() {
        if let details = document.details {
            AnytypeAnalytics.instance().logClickShareObject(objectType: details.objectType.analyticsType)
        }
        output?.showPublising(document: document)
    }
    
    // MARK: - ObjectActionsOutput
    
    func undoRedoAction() {
        output?.undoRedoAction(objectId: objectId)
    }
    
    func openPageAction(screenData: ScreenData) {
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
    
    func onLinkItselfToObjectHandler(data: ScreenData) {
        guard let documentName = document.details?.name else { return }
        output?.didCreateLinkToItself(selfName: documentName, data: data)
    }
}
