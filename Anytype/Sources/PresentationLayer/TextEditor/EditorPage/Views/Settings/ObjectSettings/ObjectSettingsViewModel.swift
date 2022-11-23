import Foundation
import Combine
import BlocksModels
import UIKit
import FloatingPanel
import SwiftUI

protocol ObjectSettingswModelOutput: AnyObject {
    func undoRedoAction()
    func layoutPickerAction()
    func coverPickerAction()
    func iconPickerAction()
    func relationsAction()
    func openPageAction(screenData: EditorScreenData)
    func linkToAction(onSelect: @escaping (BlockId, _ typeUrl: String) -> ())
}

final class ObjectSettingsViewModel: ObservableObject, Dismissible {
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
            isLocked: document.isLocked
        )
    }
    
    let objectActionsViewModel: ObjectActionsViewModel

    private let document: BaseDocumentProtocol
    private let objectDetailsService: DetailsServiceProtocol
    private let settingsBuilder = ObjectSettingBuilder()
    
    private var subscription: AnyCancellable?
    private weak var output: ObjectSettingswModelOutput?
    
    init(
        document: BaseDocumentProtocol,
        objectDetailsService: DetailsServiceProtocol,
        output: ObjectSettingswModelOutput
    ) {
        self.document = document
        self.objectDetailsService = objectDetailsService
        self.output = output
        
        self.objectActionsViewModel = ObjectActionsViewModel(
            objectId: document.objectId,
            undoRedoAction: { [weak output] in
                output?.undoRedoAction()
            },
            openPageAction: { [weak output] screenData in
                output?.openPageAction(screenData: screenData)
            }
        )

        objectActionsViewModel.onLinkItselfAction = { [weak output] onSelect in
            output?.linkToAction(onSelect: onSelect)
        }
        
        setupSubscription()
        onDocumentUpdate()
    }

    func onTapLayoutPicker() {
        output?.layoutPickerAction()
    }
    
    func onTapIconPicker() {
        output?.iconPickerAction()
    }
    
    func onTapCoverPicker() {
        output?.coverPickerAction()
    }
    
    func onTapRelations() {
        output?.relationsAction()
    }
    
    // MARK: - Private
    private func setupSubscription() {
        subscription = document.updatePublisher.sink { [weak self] _ in
            self?.onDocumentUpdate()
        }
    }
    
    private func onDocumentUpdate() {
        objectWillChange.send()
        if let details = document.details {
            objectActionsViewModel.details = details
        }
        objectActionsViewModel.isLocked = document.isLocked
        objectActionsViewModel.objectRestrictions = document.objectRestrictions
    }
}
