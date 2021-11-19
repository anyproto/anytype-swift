import SwiftUI
import BlocksModels


enum SearchKind {
    case objects
    case objectTypes(currentObjectTypeUrl: String)
}

/// https://www.figma.com/file/TupCOWb8sC9NcjtSToWIkS/Mobile---main?node-id=6455%3A4097
final class ObjectSearchViewModel: SearchViewModelProtocol {
    typealias SearchDataType = ObjectSearchData

    private let service = SearchService()
    private let searchKind: SearchKind

    var descriptionTextColor: Color {
        switch searchKind {
        case .objects:
            return .textPrimary
        case .objectTypes:
            return .textSecondary
        }
    }
    var shouldShowCallout: Bool {
        switch searchKind {
        case .objects:
            return true
        case .objectTypes:
            return false
        }
    }
    @Published var searchData: [SearchDataSection<SearchDataType>] = []
    var onSelect: (SearchDataType) -> ()
    var onDismiss: () -> () = {}

    func search(text: String) {
        let result: [SearchData]? = {
            switch searchKind {
            case .objects:
                return service.search(text: text)
            case .objectTypes(let currentObjectTypeUrl):
                return service.searchObjectTypes(
                    text: text,
                    filteringTypeUrl: currentObjectTypeUrl
                )
            }
        }()
        let objectsSearchData = result?.compactMap { searchData in
            ObjectSearchData(searchKind: searchKind, searchData: searchData)
        }

        searchData = [SearchDataSection(searchData: objectsSearchData ?? [], sectionName: "")]
    }

    init(
        searchKind: SearchKind,
        onSelect: @escaping (SearchDataType) -> ()
    ) {
        self.searchKind = searchKind
        self.onSelect = onSelect
    }
}

struct ObjectSearchData: SearchDataProtocol {
    let id = UUID()

    let searchKind: SearchKind
    private let searchData: SearchData

    let blockId: BlockId
    let searchTitle: String
    let description: String
    var shouldShowDescription: Bool { true }

    var shouldShowCallout: Bool {
        switch searchKind {
        case .objects:
            return true
        case .objectTypes:
            return false
        }
    }

    var descriptionTextColor: Color {
        switch searchKind {
        case .objects:
            return .textPrimary
        case .objectTypes:
            return .textSecondary
        }
    }

    var usecase: ObjectIconImageUsecase {
        .dashboardSearch
    }

    var iconImage: ObjectIconImage {
        let layout = searchData.layout
        if layout == .todo {
            return .todo(searchData.isDone)
        } else {
            return searchData.icon.flatMap { .icon($0) } ?? .placeholder(searchTitle.first)
        }
    }

    var callout: String {
        searchData.objectType.name
    }
    
    var viewType: EditorViewType {
        searchData.editorViewType
    }

    init(searchKind: SearchKind, searchData: SearchData) {
        self.searchData = searchData
        self.searchKind = searchKind
        self.searchTitle = searchData.title
        self.description = searchData.description
        self.blockId = searchData.id
    }
}
