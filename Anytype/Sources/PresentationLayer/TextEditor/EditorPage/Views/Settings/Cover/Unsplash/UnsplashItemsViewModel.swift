import Foundation
import Combine
import Services

@MainActor
final class UnsplashViewModel: GridItemViewModelProtocol {
    typealias Item = UnsplashItemViewModel
    typealias Section = GridItemSection<Item>

    let searchAvailability: SearchAvailability = .available(placeholder: Loc.search)
    let onItemSelect: (UnsplashItem) -> ()

    @Published var sections = [Section]()

    private var unsplashItems = [UnsplashItem]() {
        didSet {
            sections = backgroundSections()
        }
    }
    @Injected(\.unsplashService)
    private var unsplashService: any UnsplashServiceProtocol
    private(set) var isLoading: Bool = true
    private var searchTextChangedSubscription: AnyCancellable?

    @Published private var searchValue: String = ""

    init(
        onItemSelect: @escaping (UnsplashItem) -> ()
    ) {
        self.onItemSelect = onItemSelect
        self.unsplashService = unsplashService

        searchImages(query: "")

        searchTextChangedSubscription = $searchValue
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .sink { [weak self] value in
                self?.searchImages(query: value)
            }
    }

    func didSelectItem(item: UnsplashItemViewModel) {
        onItemSelect(item.item)
    }

    func didChangeSearchQuery(query: String) {
        searchValue = query
    }

    private func searchImages(query: String) {
        isLoading = true

        Task { @MainActor [weak self] in
            let items = try? await self?.unsplashService.searchUnsplashImages(query: query)
            self?.isLoading = false
            if let items {
                self?.unsplashItems = items
            }
        }
    }

    private func backgroundSections() -> [Section] {
        let items = unsplashItems.map(UnsplashItemViewModel.init(item:))

        return [Section(title: nil, items: items)]
    }
}
