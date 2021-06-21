import Foundation
import Combine
import SwiftUI


class BlockToolbarAddBlockViewModel: ObservableObject {
    // MARK: Public / Publishers
    /// It is a chosen block type publisher.
    /// It receives value when user press/choose concrete cell with concrete associated block type.
    ///
    var chosenBlockTypePublisher: AnyPublisher<BlockToolbarBlocksTypes?, Never> = .empty()

    // MARK: Public / Variables
    var title = "Add Block"

    // MARK: Fileprivate / Publishers
    @Published var categoryIndex: Int? = 0
    @Published var typeIndex: Int?
    
    @Published var indexPathIndex: IndexPath?
    
    private var indexPathIndexSubscribers: Set<AnyCancellable> = []

    // MARK: Fileprivate / Variables
    var categories: [BlockToolbarBlocksTypes] {
        self.nestedCategories.availableCategories()
    }
            
    var nestedCategories: BlocksTypesCasesFiltering = .init()

    // MARK: Initialization
    init() {
        self.chosenBlockTypePublisher = self.$indexPathIndex.map { [weak self] value in
            let (category, type) = (value?.section, value?.item)
            return self?.chosenAction(category: category, type: type)
        }.eraseToAnyPublisher()
    }
}

// MARK: ViewModel / Configuration
extension BlockToolbarAddBlockViewModel {
    func configured(title: String) -> Self {
        self.title = title
        return self
    }
    func configured(filtering: BlocksTypesCasesFiltering) -> Self {
        self.nestedCategories = filtering
        return self
    }
}

// MARK: ViewModel / Internal
extension BlockToolbarAddBlockViewModel {
    /// Actually, it was ViewData for one Cell.
    /// It is Deprecated.
    ///
    struct ChosenType: Identifiable, Equatable {
        var title: String
        var subtitle: String
        var image: String
        var id: String { title }
    }

    var types: [ChosenType] {
        return self.chosenTypes(category: self.categoryIndex)
    }

    func chosenTypes(category: Int?) -> [ChosenType] {
        func extractedChosenTypes(_ types: [BlocksViewsToolbarBlocksTypesProtocol]) -> [ChosenType] {
            types.compactMap{($0.title, $0.subtitle, $0.image)}.map(ChosenType.init(title:subtitle:image:))
        }

        guard let category = category else { return [] }

        switch self.categories[category] {
        case .text: return extractedChosenTypes(self.nestedCategories.text)
        case .list: return extractedChosenTypes(self.nestedCategories.list)
        case .objects: return extractedChosenTypes(self.nestedCategories.objects)
        case .tool: return extractedChosenTypes(self.nestedCategories.tool)
        case .other: return extractedChosenTypes(self.nestedCategories.other)
        }
    }

    func chosenAction(category: Int?, type: Int?) -> BlockToolbarBlocksTypes? {
        guard let category = category, let type = type else { return nil }
        switch self.categories[category] {
        case .text: return .text(self.nestedCategories.text[type])
        case .list: return .list(self.nestedCategories.list[type])
        case .objects: return .objects(self.nestedCategories.objects[type])
        case .tool: return .tool(self.nestedCategories.tool[type])
        case .other: return .other(self.nestedCategories.other[type])
        }
    }

    func cells(category: Int) -> [BlockToolbarAddBlockCellViewModel] {
        let cells = self.chosenTypes(category: category).enumerated()
            .map{(category, $0, $1.title, $1.subtitle, $1.image)}
            .map(BlockToolbarAddBlockCellViewModel.init(section:index:title:subtitle:imageResource:))
        cells.forEach { _ = $0.configured(indexPathStream: self._indexPathIndex) }
        return cells
    }
}
