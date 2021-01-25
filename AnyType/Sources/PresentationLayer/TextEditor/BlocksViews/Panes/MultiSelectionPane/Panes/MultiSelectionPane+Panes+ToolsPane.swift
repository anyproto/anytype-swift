//
//  MultiSelectionPane+Panes+ToolsPane.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 19.06.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import UIKit
import Combine
import SwiftUI

// MARK: Style pane
extension MultiSelectionPane.Panes {
    enum ToolbarPane {}
}

// MARK: States and Actions
/// A set of Input(`Attribute`, `UserResponse`) and Output(`Action`) types.
/// `Attribute` refers to possible values of Input.
/// `UserResponse` refers to a set of possible values of Input.
/// `UserResponse` := (`Optional<Attribute>`, `Attribute`) | (`[Attribute]`)
/// `UserResponse` is `exclusive` ( `Optional<Attribute> | Attribute` ) or `inclusive` (`[Attribute]`).
///
extension MultiSelectionPane.Panes.ToolbarPane {
    /// `UserResponse` is a structure that is delivering updates from OuterWorld.
    /// So, when user want to refresh UI of this component, he needs to `select` text.
    /// Next, appropriate method will update current value of `UserResponse` in this pane.
    ///
    enum Attribute {
        case isEmpty
        case nonEmpty(Int)
    }
    
    enum Converter {
        typealias Output = Attribute
        enum Input {
            case selection(Int)
        }
        static func convert(_ input: Input) -> Output? {
            switch input {
            case let .selection(value): return value <= 0 ? .isEmpty : .nonEmpty(value)
            }
        }
    }
    
    enum UserResponse {
        case selection(Attribute)
    }
        
    /// `Action` is an action from User, when he pressed current cell in this pane.
    /// This pane is set of panes, so, whenever user pressed a cell in child pane, update will deliver to OuterWorld.
    /// It refers to outgoing ( or `to OuterWorld` ) publisher.
    ///
    enum Action {
        enum ToolbarAction: CaseIterable {
            case turnInto
            case delete
            case more
            
            static var allCases: [ToolbarAction] = [.turnInto, .delete, .more]
        }
        case isEmpty
        case toolbar(ToolbarAction)
    }
}

// MARK: ListDataSource
extension MultiSelectionPane.Panes.ToolbarPane {
    /// `ListDataSource` is intended to manipulate with data at index paths.
    /// Also, it knows about the count of entries in a row at section.
    ///
    /// Responsibilities:
    /// - Get sections count and count of items in section.
    /// - Conversion between `IndexPath` and `Attribute`.
    /// - Resources for items at `IndexPath` or for `Attribute`.
    ///
    enum ListDataSource {

        /// Since we have only two rows on our screen in current design, we are fine with constant `2`.
        /// - Returns: A count of sections (actually, rows) of cells in a pane.
        ///
        static func sectionsCount() -> Int {
            return 1
        }

        /// Well, we determine number of sections ( or rows ) in our pane.
        /// Now we have to determine count of items in a section ( in a row ).
        /// For that, we do this lookup in section index.
        ///
        /// WARNING:
        /// This method returns `valid` indices even for `section > sectionsCount` and for `section < 0`
        ///
        static func itemsCount(section: Int) -> Int {
            switch section {
            case 0: return Action.ToolbarAction.allCases.count
            default: return 0
            }
        }

        // MARK: Conversion: IndexPath and Attribute
        /// We should determine an indexPath for a specific case of `enum Attribute`.
        /// Here we do it.
        static func indexPath(action: Action) -> IndexPath {
            switch action {
            case .isEmpty: return .init()
            case let .toolbar(value):
                switch value {
                case .turnInto: return .init(row: 0, section: 0)
                case .delete: return .init(row: 1, section: 0)
                case .more: return .init(row: 2, section: 0)
                }
            }
        }

        /// We should determine a case of `enum Attribute` for specific indexPath.
        /// Here we do it.
        ///
        /// WARNING:
        /// This method uses a fact about indexPath.
        /// IndexPath doesn't align to a zero and uses `continuous numbering`.
        /// It `does not` reset `indexPath.item` to a `zero` in `new` section.
        ///
        static func action(at indexPath: IndexPath) -> Action {
            switch indexPath.section {
            case 0: return .toolbar(Action.ToolbarAction.allCases[indexPath.row])
            default: return .isEmpty
            }
        }

        // MARK: Conversion: String and Attribute
        static func imageResource(action: Action) -> String {
            switch action {
            case .isEmpty: return ""
            case let .toolbar(value):
                switch value {
                case .turnInto: return "TurnInto"
                case .delete: return "Delete"
                case .more: return "More"
                }
            }
        }
    }
}

// MARK: ViewModelBuilder
extension MultiSelectionPane.Panes.ToolbarPane {
    /// Creates `Cell.ViewModel`
    enum CellViewModelBuilder {
        /// Creates a `Data` or `CellData`.
        /// - Parameter attribute: An Attribute for which we will create `Data` or `CellData`.
        /// - Returns: Configured `Data`or `CellData`.
        static func item(action: Action) -> Cell.ViewModel {
            let indexPath = ListDataSource.indexPath(action: action)
            let imageResource = ListDataSource.imageResource(action: action)

            return .init(section: indexPath.section, index: indexPath.item, imageResource: imageResource)
        }
        
        /// Alias to `self.item(attribute:)`
        static func cell(action: Action) -> Cell.ViewModel {
            item(action: action)
        }
    }
}

// MARK: ViewModel
extension MultiSelectionPane.Panes.ToolbarPane {
    class ViewModel: ObservableObject {
        // MARK: Initialization
        init() {
            self.setupSubscriptions()
        }

        // MARK: Publishers
        /// From OuterWorld
        @Published fileprivate var userResponse: UserResponse?
        
        private var attributePublisher: AnyPublisher<Attribute, Never> = .empty()
                
        /// To OuterWorld, Public
        var userAction: AnyPublisher<Action, Never> = .empty()
        
        /// From Cells ViewModels
        @Published var cellIndexPath: IndexPath?
        
        /// Subscriptions
        var subscriptions: Set<AnyCancellable> = []
        
        // MARK: Subscriptions
        func setupSubscriptions() {
            /// To OuterWorld            
            self.userAction = self.$cellIndexPath.safelyUnwrapOptionals().map(ListDataSource.action(at:)).eraseToAnyPublisher()
            
            /// From OuterWorld (?)
            self.attributePublisher = self.$userResponse.safelyUnwrapOptionals().map({ value -> Attribute in
                switch value {
                case let .selection(value): return value
                }
            }).eraseToAnyPublisher()
        }

        // MARK: Public Setters
        func deliver(response: UserResponse) {
            self.userResponse = response
        }

        // MARK: Cells
        func sectionsCount() -> Int {
            ListDataSource.sectionsCount()
        }

        func cells(section: Int) -> [Cell.ViewModel] {
            switch section {
            case 0:
                let cells = Action.ToolbarAction.allCases.map(Action.toolbar).map(CellViewModelBuilder.cell(action:))
                return cells
            default: return []
            }
        }
    }
}

// MARK: - Pane View
extension MultiSelectionPane.Panes.ToolbarPane {
    /// Builder that builds View from ViewModel.
    ///
    /// The only one way to build view from its viewModel.
    ///
    /// (ViewModel) -> (View)
    ///
    enum InputViewBuilder {
        static func createView(_ viewModel: ViewModel) -> some View {
            InputView.init(viewModel: viewModel)
        }
    }
}

extension MultiSelectionPane.Panes.ToolbarPane {
    /// The `InputView` is a `View` of current namespace.
    /// Here it is a `View` of `Panes.Style`.
    ///
    /// So, it is a View of Pane Style.
    ///
    struct InputView: View {
        var viewModel: ViewModel

        var layout: Layout = .init()
        /// We have two list views.
        /// First list view contains styles.
        /// Second list view contains alignments.

        var view: some View {
            VStack(alignment: .center, spacing: self.layout.verticalSpacing) {
                ForEach(0..<self.viewModel.sectionsCount()) { section in
                    Category.init(cells: self.viewModel.cells(section: section))
                }
            }
        }
        var body: some View {
            self.view
        }
    }
}

extension MultiSelectionPane.Panes.ToolbarPane.InputView {
    struct Layout {
        var verticalSpacing: CGFloat = 8
    }
}

// MARK: - Category
extension MultiSelectionPane.Panes.ToolbarPane {
    /// `Category` is a `View` that represents a Row in a Pane.
    /// But pane is horizontal, so, it represents a `Section`.
    ///
    struct Category: View {
        var cells: [Cell.ViewModel]
        var layout: Layout = .init()
        var style: Style = .presentation
        var view: some View {
            HStack(alignment: .center, spacing: 0) {
                Spacer().frame(width: self.layout.leadingSpacing)
                ForEach(self.cells.indices) { i in
                    HStack(spacing: 0){
                        Cell(viewModel: self.cells[i])
                        if (i + 1) != self.cells.indices.upperBound {
                            Divider().background(Color(self.style.borderColor())).frame(width: self.layout.dividerWidth)
                        }
                    }
                }
                Spacer().frame(width: self.layout.trailingSpacing)
            }.frame(height: self.layout.height)
        }

        var rectangle: some View {
            self.view
        }

        var body: some View {
            self.rectangle.overlay(RoundedRectangle(cornerRadius: self.layout.border.cornerRadius).stroke(Color(self.style.borderColor()), lineWidth: self.layout.border.width))
        }
    }
}

extension MultiSelectionPane.Panes.ToolbarPane.Category {
    /// I am not quite sure about Category ViewModel.
    /// Maybe we require it...
    /// So, don't remove it for some time.
    ///
    //    class ViewModel {}
}

extension MultiSelectionPane.Panes.ToolbarPane.Category {
    struct Layout {
        struct Border {
            var cornerRadius: CGFloat = 8
            var width: CGFloat = 2
        }
        var border: Border = .init()
        var horizontalSpacing: CGFloat = 8
        var leadingSpacing: CGFloat {
            self.horizontalSpacing / 2
        }
        var trailingSpacing: CGFloat {
            self.leadingSpacing
        }
        var dividerWidth: CGFloat = 2
        var height: CGFloat = 48
    }
}

extension MultiSelectionPane.Panes.ToolbarPane.Category {
    enum Style {
        case presentation
        func borderColor() -> UIColor {
            switch self {
            case .presentation: return .systemGray
            }
        }
    }
}

// MARK: Cell
extension MultiSelectionPane.Panes.ToolbarPane {
    struct Cell: View {
        @ObservedObject var viewModel: ViewModel
        var layout: Layout = .init()
        var style: Style = .presentation
        var view: some View {
            Image(self.viewModel.imageResource).renderingMode(.template)
                .foregroundColor(Color(self.style.foregroundColor(chosen: self.viewModel.state)))
                .frame(width: self.layout.width)
        }
        func view(state: Bool) -> some View {
            /// For now, we don't want to play with background.
            /// Do it later.
            self.view//.background(Color(self.viewModel.state ? self.style.backgroundColor() : .clear))
        }
        var body: some View {
            Button(action: {
                self.viewModel.pressed()
            }) {
                self.view(state: self.viewModel.state)
            }
        }
    }
}

// MARK: - Cell/Layout
extension MultiSelectionPane.Panes.ToolbarPane.Cell {
    struct Layout {
        var width: CGFloat = 60
        var height: CGFloat = 48
    }
}

// MARK: - Cell/Style
extension MultiSelectionPane.Panes.ToolbarPane.Cell {
    enum Style {
        case presentation
        func foregroundColor() -> UIColor {
            switch self {
            case .presentation: return .black
            }
        }
        func foregroundColor(chosen: Bool) -> UIColor {
            switch self {
            case .presentation: return chosen ? .black : .systemGray2
            }
        }
        func backgroundColor() -> UIColor {
            switch self {
            case .presentation: return .systemGray2
            }
        }
        func backgroundColor(chosen: Bool) -> UIColor {
            switch self {
            case .presentation: return chosen ? self.backgroundColor() : .clear
            }
        }
    }
}

// MARK: Cell/ViewModel
extension MultiSelectionPane.Panes.ToolbarPane.Cell {
    class ViewModel: ObservableObject {
        /// Connection between view and viewModel
        @Published var state: Bool = false

        /// Connection view model -> parent view model
        @Published var indexPath: IndexPath?

        /// But we still need a Publisher
        /// Connection parent view model -> view model
        var subscription: AnyCancellable?

        /// Resources
        let section: Int
        let index: Int
        let imageResource: String

        /// Output Stream ( from this ViewModel to OuterWorld. )
        func configured(indexPathPublished: Published<IndexPath?>) -> Self {
            self._indexPath = indexPathPublished
            return self
        }
        
        /// Actually, `ButtonPressed` action for an appropriate View.
        /// Our View is `Cell`.
        ///
        func pressed() {
            self.indexPath = .init(item: self.index, section: self.section)
        }

        // MARK: Initialization
        internal init(section: Int, index: Int, imageResource: String) {
            self.section = section
            self.index = index
            self.imageResource = imageResource
        }
    }
}
