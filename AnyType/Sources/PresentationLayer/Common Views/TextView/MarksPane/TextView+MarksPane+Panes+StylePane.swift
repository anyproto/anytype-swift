//
//  TextView+MarksPane+Panes+StylePane.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 13.05.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import UIKit
import Combine
import SwiftUI

// MARK: Style pane
extension TextView.MarksPane.Panes {
    enum StylePane {}
}

// MARK: States and Actions
/// A set of Input(`Attribute`, `UserResponse`) and Output(`Action`) types.
/// `Attribute` refers to possible values of Input.
/// `UserResponse` refers to a set of possible values of Input.
/// `UserResponse` := (`Optional<Attribute>`, `Attribute`) | (`[Attribute]`)
/// `UserResponse` is `exclusive` ( `Optional<Attribute> | Attribute` ) or `inclusive` (`[Attribute]`).
///
extension TextView.MarksPane.Panes.StylePane {
    /// An `Attribute` from UserResponse.
    /// When user press something in related UI component, you should update state of this UI component.
    /// For us, it is a selection of UITextView.
    ///
    /// So, we receive attributes from selection of UITextView.
    ///
    /// This attribute refers to this update.
    ///
    /// That is why you have `Converter` from `TextView.MarkStyle`
    ///
    enum Attribute {
        case fontStyle(FontStyle.Attribute)
        case alignment(Alignment.Attribute)
    }

    /// `Converter` converts `TextView.MarkStyle` -> `Attribute`.
    /// Most functions have the same name and they are dispatching by a type of argument.
    /// Parameter name `style` refers to `TextView.MarkStyle`
    /// Parameter name `alignment` refers to `NSTextAlignment`
    ///
    enum Converter {
        /// All functions have name `state`.
        /// It is better to rename it to `convert` ot `attribute`.
        ///

        private static func state(_ style: TextView.MarkStyle) -> Attribute? {
            FontStyle.Converter.state(style).flatMap(Attribute.fontStyle)
        }
        
        private static func state(_ alignment: NSTextAlignment) -> Attribute? {
            Alignment.Converter.state(alignment).flatMap(Attribute.alignment)
        }
        
        static func state(_ alignment: NSTextAlignment?) -> Attribute? {
            alignment.flatMap(state)
        }
        
        static func state(_ style: TextView.MarkStyle?) -> Attribute? {
            style.flatMap(state)
        }
        
        static func state(_ styles: [NSTextAlignment]) -> [Attribute] {
            styles.compactMap(state)
        }
        
        static func states(_ styles: [TextView.MarkStyle], _ alignment: [NSTextAlignment] = []) -> [Attribute] {
            styles.compactMap(state) + alignment.compactMap(state)
        }
    }
    
    /// `UserResponse` is a structure that is delivering updates from OuterWorld.
    /// So, when user want to refresh UI of this component, he needs to `select` text.
    /// Next, appropriate method will update current value of `UserResponse` in this pane.
    ///
    enum UserResponse {
        case fontStyle(FontStyle.UserResponse)
        case alignment(Alignment.UserResponse)
    }
        
    /// `Action` is an action from User, when he pressed current cell in this pane.
    /// This pane is set of panes, so, whenever user pressed a cell in child pane, update will deliver to OuterWorld.
    /// It refers to outgoing ( or `to OuterWorld` ) publisher.
    ///
    enum Action {
        case fontStyle(FontStyle.Action)
        case alignment(Alignment.Action)
        
        static func from(_ attribute: Attribute) -> Self {
            switch attribute {
            case let .fontStyle(value): return .fontStyle(.from(attribute: value))
            case let .alignment(value): return .alignment(.from(attribute: value))
            }
        }
    }
}

// MARK: ListDataSource
extension TextView.MarksPane.Panes.StylePane {
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
            return 2
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
            case 0: return FontStyle.ListDataSource.itemsCount(section: 0)
            case 1: return Alignment.ListDataSource.itemsCount(section: 0)
            default: return 0
            }
        }

        // MARK: Conversion: IndexPath and Attribute
        /// We should determine an indexPath for a specific case of `enum Attribute`.
        /// Here we do it.
        static func indexPath(attribute: Attribute) -> IndexPath {
            switch attribute {
            case let .fontStyle(value): return FontStyle.ListDataSource.indexPath(attribute: value)
            case let .alignment(value):
                let section = 1
                var item = Alignment.ListDataSource.indexPath(attribute: value)
                item.section = section
                return item
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
        static func attribute(at indexPath: IndexPath) -> Attribute {
            switch indexPath.section {
            case 0: return .fontStyle(FontStyle.ListDataSource.attribute(at: indexPath))
            case 1: return .alignment(Alignment.ListDataSource.attribute(at: .init(item: indexPath.item, section: 0)))
            default: return .alignment(.left) // Actually, unreachable.
            }
        }

        // MARK: Conversion: String and Attribute
        static func imageResource(attribute: Attribute) -> String {
            switch attribute {
            case let .fontStyle(value): return FontStyle.ListDataSource.imageResource(attribute: value)
            case let .alignment(value): return Alignment.ListDataSource.imageResource(attribute: value)
            }
        }
    }
}

// MARK: ViewModelBuilder
extension TextView.MarksPane.Panes.StylePane {
    /// Creates `Cell.ViewModel`
    enum CellViewModelBuilder {
        /// Creates a `Data` or `CellData`.
        /// - Parameter attribute: An Attribute for which we will create `Data` or `CellData`.
        /// - Returns: Configured `Data`or `CellData`.
        static func item(attribute: Attribute) -> Cell.ViewModel {
            let indexPath = ListDataSource.indexPath(attribute: attribute)
            let imageResource = ListDataSource.imageResource(attribute: attribute)

            return .init(section: indexPath.section, index: indexPath.item, imageResource: imageResource)
        }
        
        /// Alias to `self.item(attribute:)`
        static func cell(attribute: Attribute) -> Cell.ViewModel {
            item(attribute: attribute)
        }
    }
}

// MARK: ViewModel
extension TextView.MarksPane.Panes.StylePane {
    class ViewModel: ObservableObject {
        // MARK: Initialization
        init() {
            self.setupSubscriptions()
        }

        // MARK: Publishers
        /// From OuterWorld
        @Published fileprivate var userResponse: UserResponse?
        
        
        /// To OuterWorld, Public
        var userAction: AnyPublisher<Action, Never> = .empty()
        var fontStyleUserResponsePublisher: AnyPublisher<FontStyle.UserResponse, Never> = .empty()
        var alignmentUserResponsePublisher: AnyPublisher<IndexPath?, Never> = .empty()
        
        /// From Cells ViewModels
        @Published var fontStyleIndexPath: IndexPath?
        @Published var alignmentIndexPath: IndexPath?
        
        /// Subscriptions
        var subscriptions: Set<AnyCancellable> = []
        
        // MARK: Subscriptions
        func setupSubscriptions() {
            /// To OuterWorld
            let fontStyleAction = self.$fontStyleIndexPath.safelyUnwrapOptionals().map(ListDataSource.attribute(at:)).map(Action.from(_:)).eraseToAnyPublisher()
            let alignmentAction = self.$alignmentIndexPath.safelyUnwrapOptionals().map(ListDataSource.attribute(at:)).map(Action.from(_:)).eraseToAnyPublisher()
            self.userAction = Publishers.Merge(fontStyleAction, alignmentAction).eraseToAnyPublisher()
            
            /// From OuterWorld
            self.fontStyleUserResponsePublisher = self.$userResponse.safelyUnwrapOptionals().map({ value -> FontStyle.UserResponse? in
                switch value {
                case let .fontStyle(value): return value
                default: return nil
                }
            }).safelyUnwrapOptionals().eraseToAnyPublisher()
            
            self.alignmentUserResponsePublisher = self.$userResponse.safelyUnwrapOptionals().map({ value -> Alignment.UserResponse? in
                switch value {
                case let .alignment(value): return value
                default: return nil
                }
            }).safelyUnwrapOptionals().map(Attribute.alignment).map(ListDataSource.indexPath(attribute:)).eraseToAnyPublisher()
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
                let cells = FontStyle.Attribute.allCases
                    .map({($0, FontStyle.ListDataSource.stream(attribute: $0, stream: self.fontStyleUserResponsePublisher))})
                    .map({(Attribute.fontStyle($0.0), $0.1)})
                    .map({CellViewModelBuilder.cell(attribute: $0.0).configured(stateStream: $0.1)})
                _ = cells.map({$0.configured(indexPathPublished: self._fontStyleIndexPath)})
                return cells
            case 1:
                let cells = Alignment.Attribute.allCases.map(Attribute.alignment).map({CellViewModelBuilder.cell(attribute: $0)})
                _ = cells.map({$0.configured(indexPathPublished: self._alignmentIndexPath)})
                _ = cells.map({$0.configured(indexPathStream: self.alignmentUserResponsePublisher)})
                return cells
            default: return []
            }
        }
    }
}

// MARK: - Pane View
extension TextView.MarksPane.Panes.StylePane {
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

extension TextView.MarksPane.Panes.StylePane {
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

extension TextView.MarksPane.Panes.StylePane.InputView {
    struct Layout {
        var verticalSpacing: CGFloat = 8
    }
}

// MARK: - Category
extension TextView.MarksPane.Panes.StylePane {
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
                    if (i + 1) == self.cells.indices.upperBound {
                        HStack(spacing: 0) {
                            Cell(viewModel: self.cells[i])
                        }
                    }
                    else {
                        HStack(spacing: 0) {
                            Cell(viewModel: self.cells[i])
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

extension TextView.MarksPane.Panes.StylePane.Category {
    /// I am not quite sure about Category ViewModel.
    /// Maybe we require it...
    /// So, don't remove it for some time.
    ///
    //    class ViewModel {}
}

extension TextView.MarksPane.Panes.StylePane.Category {
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

extension TextView.MarksPane.Panes.StylePane.Category {
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
extension TextView.MarksPane.Panes.StylePane {
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
extension TextView.MarksPane.Panes.StylePane.Cell {
    struct Layout {
        var width: CGFloat = 60
        var height: CGFloat = 48
    }
}

// MARK: - Cell/Style
extension TextView.MarksPane.Panes.StylePane.Cell {
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
extension TextView.MarksPane.Panes.StylePane.Cell {
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

        /// Input Stream ( from OuterWorld to this ViewModel. )
        func configured(stateStream: AnyPublisher<Bool, Never>) -> Self {
            self.subscription = stateStream.sink { [weak self] value in
                self?.state = value
            }
            return self
        }
        
        func configured(indexPathStream: AnyPublisher<IndexPath?, Never>) -> Self {
            self.subscription = indexPathStream.safelyUnwrapOptionals().sink { [weak self] value in
                self?.state = (value.section == self?.section) && (value.item == self?.index)
            }
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
