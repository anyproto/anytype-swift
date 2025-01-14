import Foundation
import Factory
import SwiftUI

@MainActor
final class ChatCreateObjectCoordinatorViewModel: ObservableObject {
    
    // MARK: DI
    
    private let openDocumentProvider: any OpenedDocumentsProviderProtocol = Container.shared.documentService()
    
    // MARK: State
    let data: EditorScreenData
    lazy var pageNavigation = PageNavigation(
        open: { [weak self] in
            self?.handleOpenObject(data: $0)
        },
        pushHome: { },
        pop: { },
        popToFirstInSpace: {},
        replace: { _ in }
    )
    private let document: (any BaseDocumentProtocol)?
    
    @Published var interactiveDismissDisable = false
    @Published var dismissConfirmationAlert = false
    @Published var openObjectConfirmationAlert: ScreenData?
    var parentPageNavigation: PageNavigation?
    var dismiss: DismissAction?
    
    init(data: EditorScreenData) {
        self.data = data
        if let objectId = data.objectId {
            self.document = openDocumentProvider.document(objectId: objectId, spaceId: data.spaceId)
        } else {
            self.document = nil
        }
    }
    
    func startSubscriptions() async {
        guard let document else { return }
        for await details in document.detailsPublisher.values {
            interactiveDismissDisable = !details.internalFlagsValue.contains(.editorDeleteEmpty)
        }
    }
    
    func tryDismiss() {
        dismissConfirmationAlert = true
    }
    
    func openObjectConfirm(data: ScreenData) {
        dismiss?()
        parentPageNavigation?.open(data)
    }
    
    func onConfirmDiscardChanges() {
        dismiss?()
    }
    
    // MARK: - Private
    
    private func handleOpenObject(data: ScreenData) {
        openObjectConfirmationAlert = data
    }
}
