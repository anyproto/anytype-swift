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
    let onSearchTap: () -> ()

    private var cancellables = [AnyCancellable]()

    init(itemProvider: TypeListItemProvider?, onSearchTap: @escaping () -> ()) {
        self.onSearchTap = onSearchTap
        
        itemProvider?.typesPublisher.sink { [weak self] types in
            self?.items = types
        }.store(in: &cancellables)
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
