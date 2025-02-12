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
    private let onDismiss: (ChatCreateObjectDismissResult) -> Void
    
    @Published var isNotEmpty = false
    @Published var dismissConfirmationAlert = false
    @Published var openObjectConfirmationAlert: ScreenData?
    var parentPageNavigation: PageNavigation?
    var chatActionProvider: ChatActionProvider?
    var dismiss: DismissAction?
    
    init(data: EditorScreenData, onDismiss: @escaping (ChatCreateObjectDismissResult) -> Void) {
        self.data = data
        if let objectId = data.objectId {
            self.document = openDocumentProvider.document(objectId: objectId, spaceId: data.spaceId)
        } else {
            self.document = nil
        }
        self.onDismiss = onDismiss
    }
    
    func startSubscriptions() async {
        guard let document else { return }
        for await details in document.detailsPublisher.values {
            isNotEmpty = !details.internalFlagsValue.contains(.editorDeleteEmpty)
        }
    }
    
    func tryDismiss() {
        dismissConfirmationAlert = true
    }
    
    func openObjectConfirm(data: ScreenData) {
        dismiss(with: .pageOpened)
        parentPageNavigation?.open(data)
    }
    
    func onConfirmDiscardChanges() {
        dismiss(with: .canceled)
    }
    
    func onTapCacel() {
        if isNotEmpty {
            dismissConfirmationAlert = true
        } else {
            dismiss(with: .canceled)
        }
    }
    
    func onTapAttach() {
        guard let link = data.chatLink else { return }
        chatActionProvider?.addAttachment(link, clearInput: false)
        dismiss(with: .attachedToChat)
    }
    
    // MARK: - Private
    
    private func handleOpenObject(data: ScreenData) {
        openObjectConfirmationAlert = data
    }
    
    private func dismiss(with result: ChatCreateObjectDismissResult) {
        dismiss?()
        onDismiss(result)
    }
}
