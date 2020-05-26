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
    enum Attribute: CaseIterable {
        case bold(Bool)
        case italic(Bool)
        case strikethrough(Bool)
        case keyboard(Bool)

        /// As soon as we have Inclusive `Attribute` ( a `Set` of attributes )
        /// We should be able to find attributes of the same kind.
        /// For that reason we have `allCases` with empty state.
        ///
        static var allCases: [Attribute] = [ .bold(false), .italic(false), .strikethrough(false), .keyboard(false) ]

        var boolValue: Bool {
            switch self {
            case let .bold(value): return value
            case let .italic(value): return value
            case let .strikethrough(value): return value
            case let .keyboard(value): return value
            }
        }

        /// This is a Kind of attribute.
        /// Actually, we have a Set of `Attributes`.
        /// For that reason, we should find an attribute of the same `kind`.
        /// This is helper struct for this.
        ///
        struct Kind {
            var attribute: Attribute
            func sameKind(_ value: Attribute) -> Bool {
                Self.same(self.attribute, value)
            }
            static func same(_ lhs: Attribute, _ rhs: Attribute) -> Bool {
                switch (lhs, rhs) {
                case (.bold, .bold): return true
                case (.italic, .italic): return true
                case (.strikethrough, .strikethrough): return true
                case (.keyboard, .keyboard): return true
                default: return false
                }
            }
        }
    }

    /// `Converter` converts `TextView.MarkStyle` -> `Attribute`.
    ///
    enum Converter {
        private static func state(_ style: TextView.MarkStyle) -> Attribute? {
            switch style {
            case let .bold(value): return .bold(value)
            case let .italic(value): return .italic(value)
            case let .strikethrough(value): return .strikethrough(value)
            case let .keyboard(value): return .keyboard(value)
            default: return nil
            }
        }

        static func state(_ style: TextView.MarkStyle?) -> Attribute? {
            style.flatMap(state)
        }

        static func states(_ styles: [TextView.MarkStyle]) -> [Attribute] {
            styles.compactMap(state)
        }
    }

    /// Well, we have Inclusive attriubtes.
    /// So, we have not only one attribute, we have a set of attributes.
    /// It is a convenient typealias to a `Set` of `Attribute`.
    typealias UserResponse = [Attribute]

    /// `Action` is an action from User, when he pressed current cell in this pane.
    /// It refers to outgoing ( or `to OuterWorld` ) publisher.
    ///
    enum Action {
        // styles
        case bold
        case italic
        case strikethrough
        case keyboard

        static func from(attribute: Attribute) -> Self {
            switch attribute {
            case .bold: return .bold
            case .italic: return .italic
            case .strikethrough: return .strikethrough
            case .keyboard: return .keyboard
            }
        }
    }
}

// MARK: ListDataSource
extension TextView.MarksPane.Panes.StylePane {
    /// `ListDataSource` is intended to manipulate with data at index paths.
    /// Also, it knows about the count of entries in a row at section.
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
            case 0: return Attribute.allCases.count
            default: return 0
            }
        }

        // MARK: Conversion: IndexPath and Attribute
        /// We should determine an indexPath for a specific case of `enum Attribute`.
        /// Here we do it.
        static func indexPath(attribute: Attribute) -> IndexPath {
            switch attribute {
            case .bold: return .init(item: 0, section: 0)
            case .italic: return .init(item: 1, section: 0)
            case .strikethrough: return .init(item: 2, section: 0)
            case .keyboard: return .init(item: 3, section: 0)
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
            Attribute.allCases[indexPath.item]
        }

        // MARK: Conversion: String and Attribute
        static func imageResource(attribute: Attribute) -> String {
            switch attribute {
            case .bold: return "TextEditor/Toolbar/Marks/Bold"
            case .italic: return "TextEditor/Toolbar/Marks/Italic"
            case .strikethrough: return "TextEditor/Toolbar/Marks/Strikethrough"
            case .keyboard: return "TextEditor/Toolbar/Marks/Code"
            }
        }

        // MARK: Stream
        /// We have inclusive attributes (a Set of Attributes).
        /// In this case we should provide a stream ( input stream ) to update current state of specified attribute.
        static func stream(attribute: Attribute, stream: AnyPublisher<UserResponse, Never>) -> AnyPublisher<Bool, Never> {
            stream.map{ value -> Attribute? in
                return value.first(where: Attribute.Kind(attribute: attribute).sameKind)
            }.safelyUnwrapOptionals().map(\.boolValue).eraseToAnyPublisher()
        }
    }
}

// MARK: ViewModelBuilder
extension TextView.MarksPane.Panes.StylePane {
    enum CellViewModelBuilder {
        /// MARK: 
        static func item(attribute: Attribute) -> Cell.ViewModel {
            let indexPath = ListDataSource.indexPath(attribute: attribute)
            let imageResource = ListDataSource.imageResource(attribute: attribute)

            return .init(section: indexPath.section, index: indexPath.item, imageResource: imageResource)
        }
        static func cell(attribute: Attribute, stream: AnyPublisher<UserResponse, Never>) -> Cell.ViewModel {
            self.item(attribute: attribute).configured(stateStream: ListDataSource.stream(attribute: attribute, stream: stream))
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
        @Published fileprivate var userResponse: UserResponse = []

        /// To OuterWorld, Public
        var userAction: AnyPublisher<Action, Never> = .empty()

        /// From Cells ViewModels
        @Published var indexPath: IndexPath?
        
        /// Subscriptions
        var subscriptions: Set<AnyCancellable> = []
        
        // MARK: Subscriptions
        func setupSubscriptions() {
            /// To OuterWorld
            self.userAction = self.$indexPath.safelyUnwrapOptionals()
                .map(ListDataSource.attribute(at:)).map(Action.from(attribute:)).eraseToAnyPublisher()
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
            case 0: return Attribute.allCases.map({CellViewModelBuilder.cell(attribute: $0, stream: self.$userResponse.eraseToAnyPublisher())}).map({$0.configured(indexPathStream: self._indexPath)})
            default: return self.cells(section: 0)
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
            VStack(alignment: .leading, spacing: self.layout.verticalSpacing) {
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
        func configured(indexPathStream: Published<IndexPath?>) -> Self {
            self._indexPath = indexPathStream
            return self
        }

        /// Input Stream ( from OuterWorld to this ViewModel. )
        func configured(stateStream: AnyPublisher<Bool, Never>) -> Self {
            self.subscription = stateStream.sink { [weak self] value in
                self?.state = value
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
