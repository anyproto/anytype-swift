//
//  BlocksViews+Toolbar+AddBlock+ViewModel.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 22.04.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

// MARK: ViewModelBuilder
extension BlocksViews.Toolbar.AddBlock {
    enum ViewModelBuilder {
        static func create() -> ViewModel {
            let viewModel: ViewModel = .init()
            _ = viewModel.nestedCategories.allText()
            _ = viewModel.nestedCategories.allList()
//            _ = viewModel.nestedCategories.allObjects()
//            _ = viewModel.nestedCategories.allOther()
            _ = viewModel.nestedCategories.objects([.page, .picture, .file, .bookmark])
            _ = viewModel.nestedCategories.other([.lineDivider, .dotsDivider])
//            _ = viewModel.nestedCategories.page([.page])
//            _ = viewModel.nestedCategories.media([.picture, .file, .bookmark])
//            _ = viewModel.nestedCategories.other([.divider, .dots])
            _ = viewModel.configured(title: "Add Block")
            return viewModel
        }
    }
}

// MARK: ViewModel / Types Filtering
extension BlocksViews.Toolbar.AddBlock.ViewModel {
    struct BlocksTypesCasesFiltering {
        static func text(_ value: [Types.Text]) -> Self { .init(text: value) }
        static func list(_ value: [Types.List]) -> Self { .init(list: value) }
        static func objects(_ value: [Types.Objects]) -> Self { .init(objects: value) }
//        static func page(_ value: [Types.Page]) -> Self { .init(page: value) }
//        static func media(_ value: [Types.Media]) -> Self { .init(media: value) }
        static func tool(_ value: [Types.Tool]) -> Self { .init(tool: value) }
        static func other(_ value: [Types.Other]) -> Self { .init(other: value) }
        static func empty() -> Self { .init(text: [], list: [], objects: [], tool: [], other: []) }
        static func all() -> Self { .init(text: Types.Text.allCases, list: Types.List.allCases, objects: Types.Objects.allCases, tool: Types.Tool.allCases, other: Types.Other.allCases) }
        
        static func allText() -> [Types.Text] { Types.Text.allCases }
        static func allList() -> [Types.List] { Types.List.allCases }
        static func allObjects() -> [Types.Objects] { Types.Objects.allCases }
//        static func allPage() -> [Types.Page] { Types.Page.allCases }
//        static func allMedia() -> [Types.Media] { Types.Media.allCases }
        static func allTool() -> [Types.Tool] { Types.Tool.allCases }
        static func allOther() -> [Types.Other] { Types.Other.allCases }
        
        var text: [Types.Text] = []
        var list: [Types.List] = []
        var objects: [Types.Objects] = []
//        var page: [Types.Page] = []
//        var media: [Types.Media] = []
        var tool: [Types.Tool] = []
        var other: [Types.Other] = []
                                
        func availableCategories() -> [BlocksTypes] {
            BlocksTypes.allCases.filter { (value) -> Bool in
                switch value {
                case .text: return !self.text.isEmpty
                case .list: return !self.list.isEmpty
                case .objects: return !self.objects.isEmpty
//                case .page: return !self.page.isEmpty
//                case .media: return !self.media.isEmpty
                case .tool: return !self.tool.isEmpty
                case .other: return !self.other.isEmpty
                }
            }
        }
        
        @discardableResult mutating func allText() -> Self { self.text(Self.allText()) }
        @discardableResult mutating func allList() -> Self { self.list(Self.allList()) }
        @discardableResult mutating func allObjects() -> Self { self.objects(Self.allObjects()) }
//        @discardableResult mutating func allPage() -> Self { self.page(Self.allPage()) }
//        @discardableResult mutating func allMedia() -> Self { self.media(Self.allMedia()) }
        @discardableResult mutating func allTool() -> Self { self.tool(Self.allTool()) }
        @discardableResult mutating func allOther() -> Self { self.other(Self.allOther()) }

        mutating func text(_ value: [Types.Text]) -> Self {
            self.text = value
            return self
        }
        mutating func list(_ value: [Types.List]) -> Self {
            self.list = value
            return self
        }
        mutating func objects(_ value: [Types.Objects]) -> Self {
            self.objects = value
            return self
        }
//        mutating func page(_ value: [Types.Page]) -> Self {
//            self.page = value
//            return self
//        }
//        mutating func media(_ value: [Types.Media]) -> Self {
//            self.media = value
//            return self
//        }
        mutating func tool(_ value: [Types.Tool]) -> Self {
            self.tool = value
            return self
        }
        mutating func other(_ value: [Types.Other]) -> Self {
            self.other = value
            return self
        }
    }
}

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
        
        @Published var indexPathIndex: IndexPath?
        
        private var indexPathIndexSubscribers: Set<AnyCancellable> = []

        // MARK: Fileprivate / Variables
        var categories: [BlocksTypes] {
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
}

// MARK: ViewModel / Configuration
extension BlocksViews.Toolbar.AddBlock.ViewModel {
    typealias BlocksTypes = BlocksViews.Toolbar.AddBlock.BlocksTypes
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
        case .text: return extractedChosenTypes(self.nestedCategories.text)
        case .list: return extractedChosenTypes(self.nestedCategories.list)
        case .objects: return extractedChosenTypes(self.nestedCategories.objects)
//        case .page: return extractedChosenTypes(self.nestedCategories.page)
//        case .media: return extractedChosenTypes(self.nestedCategories.media)
        case .tool: return extractedChosenTypes(self.nestedCategories.tool)
        case .other: return extractedChosenTypes(self.nestedCategories.other)
        }
    }

    func chosenAction(category: Int?, type: Int?) -> Types? {
        guard let category = category, let type = type else { return nil }
        switch self.categories[category] {
        case .text: return .text(self.nestedCategories.text[type])
        case .list: return .list(self.nestedCategories.list[type])
        case .objects: return .objects(self.nestedCategories.objects[type])
//        case .page: return .page(self.nestedCategories.page[type])
//        case .media: return .media(self.nestedCategories.media[type])
        case .tool: return .tool(self.nestedCategories.tool[type])
        case .other: return .other(self.nestedCategories.other[type])
        }
    }

    func cells(category: Int) -> [Cell.ViewModel] {
        let cells = self.chosenTypes(category: category).enumerated()
            .map{(category, $0, $1.title, $1.subtitle, $1.image)}
            .map(Cell.ViewModel.init(section:index:title:subtitle:imageResource:))
        cells.forEach { $0.configured(indexPathStream: self._indexPathIndex) }
        return cells
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
    class ViewModel: ObservableObject, Identifiable {
        @Published var indexPath: IndexPath?
        let section: Int
        let index: Int
        let title: String
        let subtitle: String
        let imageResource: String // path to image
        
        func pressed() {
            self.indexPath = .init(item: self.index, section: self.section)
        }
        
        func configured(indexPathStream: Published<IndexPath?>) -> Self {
            self._indexPath = indexPathStream
            return self
        }
                
        internal init(section: Int, index: Int, title: String, subtitle: String, imageResource: String) {
            self.section = section
            self.index = index
            self.title = title
            self.subtitle = subtitle
            self.imageResource = imageResource
        }
        
        // MARK: - Identifiable
        var id: IndexPath {
            .init(row: self.index, section: self.section)
        }
    }
}

