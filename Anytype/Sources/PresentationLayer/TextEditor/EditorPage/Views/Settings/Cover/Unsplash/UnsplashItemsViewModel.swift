import Foundation
import Combine
import Kingfisher

final class UnsplashViewModel: GridItemViewModelProtocol {
    typealias Item = UnsplashItemViewModel
    typealias Section = GridItemSection<Item>

    let onItemSelect: (UnsplashItem) -> ()

    private var unsplashItems = [UnsplashItem]() {
        didSet {
            sections = backgroundSections()
        }
    }
    private let unsplashService: UnsplashServiceProtocol
    private var searchSubscription: AnyCancellable?

    @Published var sections = [Section]()

    init(
        onItemSelect: @escaping (UnsplashItem) -> (),
        unsplashService: UnsplashServiceProtocol
    ) {
        self.onItemSelect = onItemSelect
        self.unsplashService = unsplashService

        searchImages()
    }

    func searchImages() {
        searchSubscription = unsplashService
            .searchUnsplashImages(query: "")
            .receiveOnMain()
            .sinkWithResult { [weak self] result in
                switch result {
                case .success(let items): self?.unsplashItems = items
                case .failure: break
                }
            }
    }

    func didSelectItem(item: UnsplashItemViewModel) {
        onItemSelect(item.item)
    }

    private func backgroundSections() -> [Section] {
        let items = unsplashItems.map(UnsplashItemViewModel.init(item:))

        return [Section(title: nil, items: items)]
    }
}
