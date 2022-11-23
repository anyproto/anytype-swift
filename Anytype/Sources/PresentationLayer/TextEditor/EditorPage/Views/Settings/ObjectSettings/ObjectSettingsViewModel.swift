import Foundation
import Combine
import BlocksModels
import UIKit
import FloatingPanel
import SwiftUI

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

    private weak var router: EditorRouterProtocol?
    private let document: BaseDocumentProtocol
    private let objectDetailsService: DetailsServiceProtocol
    private let settingsBuilder = ObjectSettingBuilder()
    
    private var subscription: AnyCancellable?
    
    init(
        document: BaseDocumentProtocol,
        objectDetailsService: DetailsServiceProtocol,
        router: EditorRouterProtocol
    ) {
        self.document = document
        self.objectDetailsService = objectDetailsService
        self.router = router

        self.objectActionsViewModel = ObjectActionsViewModel(
            objectId: document.objectId,
            undoRedoAction: { [weak router] in
                router?.presentUndoRedo()
            },
            openPageAction: { [weak router] screenData in
                router?.showPage(data: screenData)
            }
        )

        objectActionsViewModel.onLinkItselfAction = { [weak router] onSelect in
            router?.showLinkTo(onSelect: onSelect)
        }
        
        setupSubscription()
        onDocumentUpdate()
    }

    func showLayoutSettings() {
        router?.showLayoutPicker()
    }
    
    func showIconPicker() {
        router?.showIconPicker()
    }
    
    func showCoverPicker() {
        router?.showCoverPicker()
    }
    
    func showRelations() {
        router?.showRelations()
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
