import UIKit
import Combine
import BlocksModels
import SwiftUI
import AnytypeCore

struct HorizontalListItem: Identifiable, Hashable {
    let id: String
    let title: String
    let image: ObjectIconImage

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
        let emoji = details.iconEmoji.map { ObjectIconImage.icon(.emoji($0)) } ??  ObjectIconImage.image(UIImage())

        self.init(
            id: details.id,
            title: details.name,
            image: emoji,
            action: handler
        )
    }

    static func searchItem(onTap: @escaping () -> Void) -> Self {
        let image = (UIImage(asset: .search) ?? UIImage()).image(
            imageSize: .init(width: 24, height: 24),
            cornerRadius: 12,
            side: 48,
            backgroundColor: .Stroke.tertiary
        )

        return .init(
            id: "Search",
            title: Loc.search,
            image: ObjectIconImage.image(image),
            action: onTap
        )
    }
}
