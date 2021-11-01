//
//  SearchViewModelProtocol.swift
//  Anytype
//
//  Created by Denis Batvinkin on 29.10.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import SwiftUI


protocol SearchDataProtocol: Identifiable {
    associatedtype SearchResult

    var searchResult: SearchResult { get }

    var usecase: ObjectIconImageUsecase { get }
    var iconImage: ObjectIconImage { get }

    var searchTitle: String { get }
    var description: String { get }
    var callout: String { get }

    var shouldShowDescription: Bool { get }
    var shouldShowCallout: Bool { get }
    var descriptionTextColor: Color { get }
}

struct SearchDataSection<SearchData: SearchDataProtocol>: Identifiable {
    let id = UUID()
    let searchData: [SearchData]
    let sectionName: String
}

protocol SearchViewModelProtocol: ObservableObject {
    associatedtype SearchDataType: SearchDataProtocol

    var searchData: [SearchDataSection<SearchDataType>] {get}
    var onSelect: (SearchDataType.SearchResult) -> () { get }

    func search(text: String)
}
