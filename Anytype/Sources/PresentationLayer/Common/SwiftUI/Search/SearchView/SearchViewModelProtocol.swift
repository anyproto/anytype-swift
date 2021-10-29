//
//  SearchViewModelProtocol.swift
//  Anytype
//
//  Created by Denis Batvinkin on 29.10.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import SwiftUI


protocol SearchDataProtocol: Identifiable {
    associatedtype ID

    var id: ID { get }

    var usecase: ObjectIconImageUsecase { get }
    var iconImage: ObjectIconImage { get }

    var searchTitle: String { get }
    var description: String { get }
    var callout: String { get }
}

struct SearchDataSection<SearchData: SearchDataProtocol>: Identifiable {
    let id = UUID()
    let searchData: [SearchData]
    let sectionName: String
}

protocol SearchViewModel {
    associatedtype SearchDataType: SearchDataProtocol

    var descriptionTextColor: Color { get }
    var shouldShowCallout: Bool { get }
    var searchData: [SearchDataSection<SearchDataType>] {get}
    var onSelect: (SearchDataType.ID) -> () { get }

    func search(text: String)
}
