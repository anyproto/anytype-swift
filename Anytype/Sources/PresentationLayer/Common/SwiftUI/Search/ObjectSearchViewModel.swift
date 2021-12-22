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
        let result: [ObjectDetails]? = {
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
        let objectsSearchData = result?.compactMap { details in
            ObjectSearchData(searchKind: searchKind, details: details)
        }

        guard let objectsSearchData = objectsSearchData, objectsSearchData.isNotEmpty else {
            searchData = []
            return
        }

        searchData = [SearchDataSection(searchData: objectsSearchData, sectionName: "")]
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
    private let details: ObjectDetails

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
        let layout = details.layout
        if layout == .todo {
            return .todo(details.isDone)
        } else {
            return details.icon.flatMap { .icon($0) } ?? .placeholder(searchTitle.first)
        }
    }

    var callout: String {
        details.objectType.name
    }
    
    var viewType: EditorViewType {
        details.editorViewType
    }

    init(searchKind: SearchKind, details: ObjectDetails) {
        self.details = details
        self.searchKind = searchKind
        self.searchTitle = details.title
        self.description = details.description
        self.blockId = details.id
    }
}
