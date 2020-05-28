//
//  TextView+MarksPane+Panes+Color.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 13.05.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import UIKit
import Combine
import SwiftUI

extension TextView.MarksPane.Panes {
    enum Color {}
}

// MARK: Colors
extension TextView.MarksPane.Panes.Color {
    typealias Colors = BlockModels.Parser.Text.Color.Converter.Colors
    typealias ColorsConverter = BlockModels.Parser.Text.Color.Converter
}

// MARK: States and Actions
extension TextView.MarksPane.Panes.Color {
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
        case setColor(UIColor)
    }
    
    /// `Converter` converts `TextView.MarkStyle` -> `Attribute`.
    ///
    enum Converter {
        private static func state(_ style: TextView.MarkStyle, background: Bool) -> Attribute? {
            switch style {
            case let .textColor(color): return .setColor(color ?? Colors.default.color(background: false))
            case let .backgroundColor(color): return .setColor(color ?? Colors.default.color(background: true))
            default: return nil
            }
        }
        
        static func state(_ style: TextView.MarkStyle?, background: Bool) -> Attribute? {
            style.flatMap({state($0, background: background)})
        }
        
        static func states(_ styles: [TextView.MarkStyle], background: Bool) -> [Attribute] {
            styles.compactMap({state($0, background: background)})
        }
    }
    
    /// Well, we have Exclusive attriubtes.
    /// So, we have only one attribute.
    /// It is a convenient typealias to an `Attribute`.
    ///
    typealias UserResponse = Attribute
    
    /// `Action` is an action from User, when he pressed current cell in this pane.
    /// It refers to outgoing ( or `to OuterWorld` ) publisher.
    ///
    enum Action {
        // Maybe better to use Colors?
        case setColor(UIColor)
    }
}

// MARK: ListDataSource
extension TextView.MarksPane.Panes.Color {
    /// `ListDataSource` is intended to manipulate with data at index paths.
    /// Also, it knows about the count of entries in a row at section.
    ///
    enum ListDataSource {
        /// Since we have only two rows on our screen in current design, we are fine with constant `2`.
        /// - Returns: A count of sections (actually, rows) of colors in pane.
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
            case 0: return 6
            case 1: return Colors.allCases.count - self.itemsCount(section: 0)
            default: return 0
            }
        }
        
        /// We should map 1-dimensional index to our IndexPath ( 2-dimensional index ).
        /// This method return correct index path for index.
        ///
        /// WARNING:
        /// This method `does not` align `indexPath.item` to `zero`.
        /// It only add `section` value.
        ///
        /// It is fine with the following:
        ///
        /// (0, 0), (0, 1), (0, 2)
        /// (1, 3), (1, 4)
        /// (2, 5)
        ///
        static func indexPath(_ index: Int) -> IndexPath {
            for section in 0 ..< self.sectionsCount() {
                let previousCount = self.itemsCount(section: section - 1) // equal to zero for -1
                let currentCount = self.itemsCount(section: section)
                if index - previousCount < currentCount {
                    return .init(item: index, section: section)
                }
            }
            return .init(item: 0, section: 0)
        }
        
        // MARK: Conversion: IndexPath and Colors
        /// We should determine an indexPath for a specific case of `enum Colors`.
        /// Here we do it.
        static func indexPath(_ color: Colors) -> IndexPath {
            guard let index = Colors.allCases.firstIndex(of: color) else { return .init(item: 0, section: 0) }
            return self.indexPath(index)
        }
        
        /// We should determine a case of `enum Colors` for specific indexPath.
        /// Here we do it.
        ///
        /// WARNING:
        /// This method uses a fact about indexPath.
        /// IndexPath doesn't align to a zero and uses `continuous numbering`.
        /// It `does not` reset `indexPath.item` to a `zero` in `new` section.
        ///
        static func color(at indexPath: IndexPath) -> Colors {
            Colors.allCases[indexPath.item]
        }
        
        // MARK: Conversion: UIColor and Colors
        /// Actually, we can't determine a `case` of `enum Colors` without a context: `background`.
        /// This method determines a case of `enum Colors` with `background` flag.
        ///
        /// `(UIColor, background: Bool) -> Colors`
        ///
        static func color(by color: UIColor, background: Bool) -> Colors {
            .init(name: ColorsConverter.asMiddleware(color, background: background))
        }
        
        // TODO: Change to String (maybe?)
        /// This method `could` use a `String` as a resource IF middleware has unique names of colors.
        /// Without it, we use a context `background` to determine `UIColor`.
        ///
        /// `(Colors, background: Bool) -> UIColor`
        ///
        static func imageResource(_ color: Colors, background: Bool) -> UIColor {
            color.color(background: background)
        }
    }
}

// MARK: ViewModelBuilder
extension TextView.MarksPane.Panes.Color {
    enum CellViewModelBuilder {
        static func item(_ color: Colors, background: Bool) -> Cell.ViewModel {
            let indexPath = ListDataSource.indexPath(color)
            let imageResource = ListDataSource.imageResource(color, background: background)
            
            return .init(section: indexPath.section, index: indexPath.item, imageResource: imageResource)
        }
        
        static func cell(_ color: Colors, background: Bool) -> Cell.ViewModel {
            self.item(color, background: background)
        }
    }
}


// MARK: ViewModel
extension TextView.MarksPane.Panes.Color {
    class ViewModel: ObservableObject {
        // MARK: Variables
        private var background: Bool = false
        
        // MARK: Initialization
        init(background: Bool) {
            self.background = background
            self.setupSubscriptions(background: background)
        }
        
        // MARK: Publishers
        /// From OuterWorld
        @Published fileprivate var userResponse: Attribute?
        fileprivate var userResponsePublisher: AnyPublisher<IndexPath?, Never> = .empty()
        
        /// To OuterWorld, Public
        var userAction: AnyPublisher<Action, Never> = .empty()
        
        /// From Colors ViewModels
        @Published fileprivate var indexPath: IndexPath?
        
        var subscriptions: Set<AnyCancellable> = []
        
        // MARK: Subscriptions
        private func setupSubscriptions(background: Bool) {
            // To OuterWorld
            self.userAction =
            self.$indexPath.safelyUnwrapOptionals().map { [weak self] (value) in
                self.flatMap({ListDataSource.color(at: value).color(background: $0.background)})
            }.safelyUnwrapOptionals().map(Action.setColor).eraseToAnyPublisher()
            
            // From OuterWorld
            /// Actually, we have to do the following:
            /// 1. Receive a response from a User ( when he select a range of attributed string ).
            /// 2. Convert this response to our `IndexPath` to select a `Cell` with related `IndexPath`.
            ///
            /// What we really do:
            ///
            /// 1. Extract a value from a case of `enum Attribute`.
            /// 2. Convert this value to a case of `enum Colors`. (UIColor, background: Bool) -> (Colors)
            /// 3. Convert a case of `enum Colors` to an IndexPath. (Colors) -> (IndexPath)
            ///
            self.userResponsePublisher = self.$userResponse.map({ Self.enhance(response: $0, background: background) }).eraseToAnyPublisher()
        }
        
        // MARK: From OuterWorld
        private class func enhance(response: Attribute?, background: Bool) -> IndexPath? {
            guard case let .setColor(color) = response else { return nil }
            return ListDataSource.indexPath(ListDataSource.color(by: color, background: background))
        }
        
        // MARK: Public Setters
        func deliver(response: Attribute?) {
            self.userResponse = response
        }
        
        // MARK: Cell
        func sectionsCount() -> Int {
            ListDataSource.sectionsCount()
        }

        func cells(section: Int) -> [Cell.ViewModel] {
            /// we have two sections
            let colors = Colors.allCases.enumerated().filter({ListDataSource.indexPath($0.offset).section == section}).compactMap { value in
                CellViewModelBuilder.cell(value.element, background: self.background)
            }
            _ = colors.map({$0.configured(indexPathStream: self._indexPath)})
            _ = colors.map({$0.configured(indexPathPublisher: self.userResponsePublisher)})
            return colors
        }
    }
}

// MARK: - Pane View
extension TextView.MarksPane.Panes.Color {
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

extension TextView.MarksPane.Panes.Color {
    /// The `InputView` is a `View` of current namespace.
    /// Here it is a `View` of `Panes.Color`.
    ///
    /// So, it is a View of Pane Color.
    ///
    struct InputView: View {
        var viewModel: ViewModel
        
        var layout: Layout = .init()
        
        /// We have two list views.
        /// First list view contains styles.
        /// Second list view contains alignments.
                
        var body: some View {
            VStack(alignment: .center, spacing: self.layout.verticalSpacing) {
                ForEach(0..<self.viewModel.sectionsCount()) { section in
                    Category.init(cells: self.viewModel.cells(section: section))
                }
            }
        }
    }
}

extension TextView.MarksPane.Panes.Color.InputView {
    struct Layout {
        var verticalSpacing: CGFloat = 5
    }
}

// MARK: - Category
extension TextView.MarksPane.Panes.Color {
    /// `Category` is a `View` that represents a Row in a Pane.
    /// But pane is horizontal, so, it represents a `Section`.
    ///
    struct Category: View {
        var cells: [Cell.ViewModel]
        var layout: Layout = .init()
        var view: some View {
            HStack(alignment: .center, spacing: self.layout.horizontalSpacing) {
                ForEach(self.cells.indices) { i in
                    Cell(viewModel: self.cells[i])
                }
            }
        }
        var body: some View {
            self.view
        }
    }
}

extension TextView.MarksPane.Panes.Color.Category {
    struct Layout {
        var horizontalSpacing: CGFloat = 8
    }
}

extension TextView.MarksPane.Panes.Color.Category {
    /// I am not quite sure about Category ViewModel.
    /// Maybe we require it...
    /// So, don't remove it for some time.
    ///
    //    class ViewModel: {}
}

// MARK: - Cell
extension TextView.MarksPane.Panes.Color {
    struct Cell: View {
        @ObservedObject var viewModel: ViewModel
        var layout: Layout = .init()
        var style: Style = .presentation
        var view: some View {
            Color(self.viewModel.imageResource).frame(width: self.layout.size, height: self.layout.size, alignment: .center).cornerRadius(self.layout.size)
        }
        func view(state: Bool) -> some View {
            self.view.padding(self.layout.selectedCircle.padding)
                .overlay(
                    Circle().stroke(Color( state ? self.style.borderColor() : .clear), lineWidth: self.layout.selectedCircle.strokeWidth)
            ).padding(self.layout.selectedCircle.additionalPadding)
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

// MARK: - Cell Layout
extension TextView.MarksPane.Panes.Color.Cell {
    struct Layout {
        var size: CGFloat = 48
        
        var selectedCircle: SelectedCircle = .init()
        struct SelectedCircle {
            var padding: CGFloat = 3
            var strokeWidth: CGFloat = 2
            var additionalPadding: CGFloat {self.strokeWidth}
        }
    }
}

// MARK: - Cell Style
extension TextView.MarksPane.Panes.Color.Cell {
    enum Style {
        case presentation
        func borderColor() -> UIColor {
            switch self {
            case .presentation: return .init(red: 0.165, green: 0.656, blue: 0.933, alpha: 1)
            }
        }
    }
}

extension TextView.MarksPane.Panes.Color.Cell {
    class ViewModel: ObservableObject {
        /// Connection between view and viewModel
        @Published var state: Bool = false
        
        /// Connection view model -> parent view model
        
        /// As soon as we have only one selected color, we could safely do the following:
        /// Set only one indexPath for all values.
        /// Exclusivity is simple.
        
        @Published var indexPath: IndexPath?
        
        /// But we still need a Publisher
        /// Connection parent view model -> view model
        var subscription: AnyCancellable?
        
        /// Resources
        let section: Int
        let index: Int
        let imageResource: UIColor
        
        /// Output Stream ( from this ViewModel to OuterWorld. )
        func configured(indexPathStream: Published<IndexPath?>) -> Self {
            self._indexPath = indexPathStream
            return self
        }
        
        /// Input Stream ( from OuterWorld to this ViewModel. )
        func configured(indexPathPublisher: AnyPublisher<IndexPath?, Never>) -> Self {
            self.subscription = indexPathPublisher.safelyUnwrapOptionals().sink { [weak self] (value) in
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
                
        // MARK: - Initialization
        internal init(section: Int, index: Int, imageResource: UIColor) {
            self.section = section
            self.index = index
            self.imageResource = imageResource
        }
    }
}
