import UIKit
import Combine
import BlocksModels
import SwiftUI
import AnytypeCore

protocol TypeListItemProvider: AnyObject {
    var typesPublisher: AnyPublisher<[HorizonalTypeListViewModel.Item], Never> { get }
}

final class HorizonalTypeListViewModel: ObservableObject {
    struct Item: Identifiable {
        let id: String
        let title: String
        let image: ObjectIconImage
        let action: () -> Void
    }

    @Published var items = [Item]()

    private var cancellables = [AnyCancellable]()

    init(itemProvider: TypeListItemProvider) {
        itemProvider.typesPublisher.sink { [weak self] types in
            self?.items = types
        }.store(in: &cancellables)
    }
}

extension HorizonalTypeListViewModel.Item {
    init(from details: ObjectDetails, handler: @escaping () -> Void) {
        let emoji = Emoji(details.iconEmoji).map { ObjectIconImage.icon(.emoji($0)) } ??  ObjectIconImage.image(UIImage())

        self.init(
            id: details.id,
            title: details.name,
            image: emoji,
            action: handler
        )
    }

    static func searchItem(onTap: @escaping () -> Void) -> Self {
        let image = UIImage.edititngToolbar.ChangeType.search.image(
            imageSize: .init(width: 24, height: 24),
            cornerRadius: 12,
            side: 48,
            backgroundColor: .strokeTertiary
        )

        return .init(
            id: "Search",
            title: "Search".localized,
            image: ObjectIconImage.image(image),
            action: onTap
        )
    }
}
