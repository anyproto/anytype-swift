import UIKit
import Combine
import Services
import SwiftUI
import AnytypeCore

struct HorizontalListItem: Identifiable, Hashable {
    let id: String
    let title: String
    let image: Icon

    @EquatableNoop var action: () -> Void
}

protocol TypeListItemProvider: AnyObject {
    var typesPublisher: AnyPublisher<[HorizontalListItem], Never> { get }
}

final class HorizonalTypeListViewModel: ObservableObject {
    @Published var items = [HorizontalListItem]()

    private var cancellables = [AnyCancellable]()

    init(itemProvider: TypeListItemProvider?) {
        itemProvider?.typesPublisher.sink { [weak self] types in
            self?.items = types
        }.store(in: &cancellables)
    }
}

extension HorizontalListItem {
    init(from details: ObjectDetails, handler: @escaping () -> Void) {
        let emoji = details.iconEmoji.map { Icon.object(.emoji($0)) } ??
            .object(.placeholder(details.name.first))
        
        self.init(
            id: details.id,
            title: details.name,
            image: emoji,
            action: handler
        )
    }

    static func searchItem(onTap: @escaping () -> Void) -> Self {
        return .init(
            id: "Search",
            title: Loc.search,
            image: .squircle(.asset(.X32.search)),
            action: onTap
        )
    }
}
