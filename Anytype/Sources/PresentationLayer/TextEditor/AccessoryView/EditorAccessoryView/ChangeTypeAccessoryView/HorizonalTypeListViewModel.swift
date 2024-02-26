import UIKit
import Combine
import Services
import SwiftUI
import AnytypeCore

struct HorizontalListItem: Identifiable, Hashable {
    let id: String
    let title: String
    let icon: Icon?

    @EquatableNoop var action: () -> Void
}

protocol TypeListItemProvider: AnyObject {
    var typesPublisher: AnyPublisher<[HorizontalListItem], Never> { get }
}

final class HorizonalTypeListViewModel: ObservableObject {
    @Published var items = [HorizontalListItem]()
    @Published var showPaste = false
    let onSearchTap: () -> ()
    
    private let pasteboardHelper: PasteboardHelperProtocol
    private var cancellables = [AnyCancellable]()
    private let onPasteTap: () -> ()

    init(
        itemProvider: TypeListItemProvider?,
        pasteboardHelper: PasteboardHelperProtocol = PasteboardHelper(),
        onSearchTap: @escaping () -> (),
        onPasteTap: @escaping () -> ()
    ) {
        self.onSearchTap = onSearchTap
        self.onPasteTap = onPasteTap
        self.pasteboardHelper = pasteboardHelper
        
        pasteboardHelper.startSubscription { [weak self] in
            self?.updatePasteState()
        }
        
        itemProvider?.typesPublisher.sink { [weak self] types in
            self?.items = types
        }.store(in: &cancellables)
    }
    
    func updatePasteState() {
        withAnimation {
            showPaste = pasteboardHelper.hasSlots
        }
    }
    
    func onPasteButtonTap() {
        if !pasteboardHelper.isPasteboardEmpty { // No Permission
            onPasteTap()
        }
    }
}

extension HorizontalListItem {
    init(from details: ObjectDetails, handler: @escaping () -> Void) {
        self.init(
            id: details.id,
            title: details.name,
            icon: details.objectIconImage,
            action: handler
        )
    }
}
