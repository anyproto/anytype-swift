//
//  BlocksViews+Toolbar+AddBlock+ViewModel.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 22.04.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import Combine

// MARK: ViewModel
extension BlocksViews.Toolbar.AddBlock {
    /// View model for a whole List with cells.
    /// Cells are grouped in Sections.
    /// For us, Categories (Sections) are values of BlocksTypes.
    /// And Cells in each Category (Section) are enum that is associated with concrete value of BlocksTypes enum.
    /// In this example,
    ///
    /// enum First {
    ///  enum Second {case b}
    ///  case a(Second)
    ///}
    ///
    /// Sections equal to all cases of First enum ({case a})
    /// Cells in {case a} are equal to cases in Second enum ({case b})
    ///
    class ViewModel: ObservableObject {
        // MARK: Public / Publishers
        /// It is a chosen block type publisher.
        /// It receives value when user press/choose concrete cell with concrete associated block type.
        ///
        var chosenBlockTypePublisher: AnyPublisher<BlocksTypes?, Never> = .empty()
        
        // MARK: Public / Variables
        var title = "Add Block"
        
        // MARK: Fileprivate / Publishers
        @Published var categoryIndex: Int? = 0
        @Published var typeIndex: Int?
        
        // MARK: Fileprivate / Variables
        var categories = BlocksTypes.allCases
        
        // MARK: Initialization
        init() {
            self.chosenBlockTypePublisher = self.$typeIndex.map { [weak self] value in
                let category = self?.categoryIndex
                let type = value
                return self?.chosenAction(category: category, type: type)
            }.eraseToAnyPublisher()
        }
    }
}

// MARK: ViewModel / Internal
extension BlocksViews.Toolbar.AddBlock.ViewModel {
    typealias Types = BlocksViews.Toolbar.BlocksTypes
    typealias Cell = BlocksViews.Toolbar.AddBlock.Cell
    
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
            types.compactMap{($0.title, $0.subtitle, $0.path)}.map(ChosenType.init(title:subtitle:image:))
        }
        guard let category = category else { return [] }
        switch self.categories[category] {
        case .text: return extractedChosenTypes(Types.Text.allCases)
        case .list: return extractedChosenTypes(Types.List.allCases)
        case .page: return extractedChosenTypes(Types.Page.allCases)
        case .media: return extractedChosenTypes(Types.Media.allCases)
        case .tool: return extractedChosenTypes(Types.Tool.allCases)
        case .other: return extractedChosenTypes(Types.Other.allCases)
        }
    }
    
    func chosenAction(category: Int?, type: Int?) -> Types? {
        guard let category = category, let type = type else { return nil }
        switch self.categories[category] {
        case .text: return .text(Types.Text.allCases[type])
        case .list: return .list(Types.List.allCases[type])
        case .page: return .page(Types.Page.allCases[type])
        case .media: return .media(Types.Media.allCases[type])
        case .tool: return .tool(Types.Tool.allCases[type])
        case .other: return .other(Types.Other.allCases[type])
        }
    }
    
    func cells(category: Int) -> [Cell.ViewModel] {
        self.chosenTypes(category: category).enumerated()
            .map{(category, $0, $1.title, $1.subtitle, $1.image)}
            .map(Cell.ViewModel.init(section:index:title:subtitle:imageResource:))
    }
}

// MARK: Category
extension BlocksViews.Toolbar.AddBlock.Category {
    struct ViewModel {
        let title: String
        var uppercasedTitle: String { title.uppercased() }
    }
}

// MARK: Cell
extension BlocksViews.Toolbar.AddBlock.Cell {
    struct ViewModel {
        let section: Int
        let index: Int
        let title: String
        let subtitle: String
        let imageResource: String // path to image
    }
}

