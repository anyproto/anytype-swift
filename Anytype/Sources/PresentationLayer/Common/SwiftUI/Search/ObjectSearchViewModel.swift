//
//  ObjectSearchViewModel.swift
//  Anytype
//
//  Created by Denis Batvinkin on 29.10.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import SwiftUI


enum SearchKind {
    case objects
    case objectTypes(currentObjectTypeUrl: String)
}

/// https://www.figma.com/file/TupCOWb8sC9NcjtSToWIkS/Mobile---main?node-id=6455%3A4097
final class ObjectSearchViewModel: SearchViewModel, ObservableObject {
    typealias SearchDataType = SearchData

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
    var onSelect: (SearchDataType.ID) -> ()

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

        searchData = [SearchDataSection(searchData: result ?? [], sectionName: "")]
    }

    init(searchKind: SearchKind,
         onSelect: @escaping (SearchDataType.ID) -> ()) {
        self.searchKind = searchKind
        self.onSelect = onSelect
    }
}

extension SearchData: SearchDataProtocol {

    var usecase: ObjectIconImageUsecase {
        .dashboardSearch
    }

    var searchTitle: String {
        self.name.isEmpty ? "Untitled".localized : self.name
    }

    var iconImage: ObjectIconImage {
        let layout = self.layout
        if layout == .todo {
            return .todo(self.isDone)
        } else {
            return self.icon.flatMap { .icon($0) } ?? .placeholder(searchTitle.first)
        }
    }

    var callout: String {
        if let type = self.objectType?.name, !type.isEmpty {
            return type
        } else {
            return "Page".localized
        }
    }
}
