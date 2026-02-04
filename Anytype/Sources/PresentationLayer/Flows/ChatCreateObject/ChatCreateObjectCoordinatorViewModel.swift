import Foundation
import Factory
import SwiftUI

@MainActor
@Observable
final class ChatCreateObjectCoordinatorViewModel {

    // MARK: DI

    @ObservationIgnored
    private let openDocumentProvider: any OpenedDocumentsProviderProtocol = Container.shared.openedDocumentProvider()

    // MARK: State
    @ObservationIgnored
    let data: EditorScreenData
    @ObservationIgnored
    lazy var pageNavigation = PageNavigation(
        open: { [weak self] in
            self?.handleOpenObject(data: $0)
        },
        pushHome: { },
        pop: { },
        popToFirstInSpace: {},
        replace: { _ in }
    )
    @ObservationIgnored
    private let document: (any BaseDocumentProtocol)?
    @ObservationIgnored
    private let onDismiss: (ChatCreateObjectDismissResult) -> Void

    var isNotEmpty = false
    var dismissConfirmationAlert = false
    var openObjectConfirmationAlert: ScreenData?
    @ObservationIgnored
    var parentPageNavigation: PageNavigation?
    @ObservationIgnored
    var chatActionProvider: ChatActionProvider?
    @ObservationIgnored
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
