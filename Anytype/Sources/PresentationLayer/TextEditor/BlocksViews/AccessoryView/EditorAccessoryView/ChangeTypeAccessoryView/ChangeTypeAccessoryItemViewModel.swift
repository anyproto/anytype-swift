import UIKit
import Combine

protocol ChangeTypeItemProvider: AnyObject {
    var typesPublisher: Published<[ChangeTypeAccessoryItemViewModel.Item]>.Publisher { get }
}

final class ChangeTypeAccessoryItemViewModel: ObservableObject {
    struct Item: Identifiable {
        let id: String
        let title: String
        let image: ObjectIconImage
        let action: () -> Void
    }

    @Published var items = [Item]()

    private let searchHandler: () -> Void
    private var cancellables = [AnyCancellable]()
    private lazy var searchItem = Item.searchItem { [weak self] in self?.searchHandler() }

    init(itemProvider: ChangeTypeItemProvider, searchHandler: @escaping () -> Void) {
        self.searchHandler = searchHandler

        itemProvider.typesPublisher.sink { [weak self] types in
            guard let self = self else { return }

            self.items = [self.searchItem] + types
        }.store(in: &cancellables)
    }
}

extension ChangeTypeAccessoryItemViewModel.Item {
    static func searchItem(onTap: @escaping () -> Void) -> Self {
        let image = UIImage.editorNavigation.search.image(
            imageSize: .init(width: 20, height: 20),
            cornerRadius: 12,
            side: 48,
            backgroundColor: .grayscale10
        )

        return .init(
            id: "Search",
            title: "Search".localized,
            image: ObjectIconImage.image(image),
            action: onTap
        )
    }
}
