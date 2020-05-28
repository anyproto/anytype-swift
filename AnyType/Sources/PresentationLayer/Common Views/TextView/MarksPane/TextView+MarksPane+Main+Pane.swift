//
//  TextView+MarksPane+ViewModel.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 14.05.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

// MARK: States and Actions
extension TextView.MarksPane.Main {
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
    /// This `Attribute` aggregates different attributes from different panes.
    enum Attribute {
        case style(Panes.StylePane.Attribute)
        case textColor(Panes.Color.Attribute)
        case backgroundColor(Panes.Color.Attribute)
    }

    /// `Converter` converts `TextView.MarkStyle` -> `Attribute`.
    /// Most functions have the same name and they are dispatching by a type of argument.
    /// Parameter name `style` refers to `TextView.MarkStyle`
    /// Parameter name `alignment` refers to `NSTextAlignment`
    ///
    enum Converter {
        /// All functions have name `state`.
        /// It is better to rename it to `convert` or `attribute`.
        ///
        private static func state(_ style: TextView.MarkStyle) -> Attribute? {
            switch style {
            case .bold: return Panes.StylePane.Converter.state(style).flatMap(Attribute.style)
            case .italic: return Panes.StylePane.Converter.state(style).flatMap(Attribute.style)
            case .strikethrough: return Panes.StylePane.Converter.state(style).flatMap(Attribute.style)
            case .keyboard: return Panes.StylePane.Converter.state(style).flatMap(Attribute.style)

            case .underscored: return nil
            case .textColor: return Panes.Color.Converter.state(style, background: false).flatMap(Attribute.textColor)
            case .backgroundColor: return Panes.Color.Converter.state(style, background: true).flatMap(Attribute.backgroundColor)

            case .link: return nil
            }
        }
        
        private static func state(_ alignment: NSTextAlignment) -> Attribute? {
            Panes.StylePane.Converter.state(alignment).flatMap(Attribute.style)
        }

        static func state(_ style: TextView.MarkStyle?) -> Attribute? {
            style.flatMap(state)
        }
        
        static func state(_ alignment: NSTextAlignment?) -> Attribute? {
            alignment.flatMap(state)
        }
        
        static func state(_ alignments: [NSTextAlignment]) -> [Attribute] {
            alignments.compactMap(state)
        }

        static func states(_ styles: [TextView.MarkStyle]) -> [Attribute] {
            styles.compactMap(state)
        }
        
        static func states(_ styles: [TextView.MarkStyle], _ alignments: [NSTextAlignment]) -> [Attribute] {
            styles.compactMap(state) + alignments.compactMap(state)
        }
    }

    // AppleBug: Switch to (NSRange, [State]) pair instead.
    // We can't just use Pairs in Publishers.
    
    /// `UserResponse` is a structure that is delivering updates from OuterWorld.
    /// So, when user want to refresh UI of this component, he needs to `select` text.
    /// Next, appropriate method will update current value of `UserResponse` in this pane.
    ///
    struct UserResponse {
        var range: NSRange = .init()
        var states: [Attribute] = []
        static var zero = Self.init()
        func isZero() -> Bool {
            return self.range == Self.zero.range && self.states.count == Self.zero.states.count
        }
    }
    
    struct RawUserResponse {
        var attributedString: NSAttributedString = .init(string: "")
        var textAlignment: NSTextAlignment
        var textColor: UIColor = .clear
        var backgroundColor: UIColor = .clear
    }

    /// `Action` is an action from User, when he pressed current cell in this pane.
    /// This pane is set of panes, so, whenever user pressed a cell in child pane, update will deliver to OuterWorld.
    /// It refers to outgoing ( or `to OuterWorld` ) publisher.
    ///
    enum Action {
        case style(NSRange, Panes.StylePane.Action)
        case textColor(NSRange, Panes.Color.Action)
        case backgroundColor(NSRange, Panes.Color.Action)
    }
}

// MARK: ViewModel
extension TextView.MarksPane.Main {
    class ViewModel: ObservableObject {
        // MARK: Variables
        /// Selected range, actually.
        var range: NSRange = .init()

        // MARK: Initialization
        init() {
            self.setupPublishers()
        }
        
        // MARK: Publishers
        /// From OuterWorld
        @Published fileprivate var userResponse: UserResponse?

        /// To OuterWorld, Public
        var userAction: AnyPublisher<Action, Never> = .empty()
        
        // MARK: Subscriptions
        var subscriptions: Set<AnyCancellable> = []
        
        // MARK: ViewModels
        @ObservedObject var sectionViewModel: Section.ViewModel = .init()
        
        var styleModel: Panes.StylePane.ViewModel = .init()
        var textColorModel: Panes.Color.ViewModel = .init(background: false)
        var backgroundColorModel: Panes.Color.ViewModel = .init(background: true)

        // MARK: ObservedObjects
        var observedSectionViewModel: ObservedObject<Section.ViewModel> { self._sectionViewModel }
        
        // MARK: Private Setters
        private func enhance(_ action: Action) -> Action {
            switch action {
            case let .style(_, value): return .style(self.range, value)
            case let .textColor(_, value): return .textColor(self.range, value)
            case let .backgroundColor(_, value): return .backgroundColor(self.range, value)
            }
        }
        
        // MARK: Publishers
        func setupPublishers() {
            let style = self.styleModel.userAction.map({Action.style(.init(), $0)}).eraseToAnyPublisher()
            let color = self.textColorModel.userAction.map({Action.textColor(.init(), $0)}).eraseToAnyPublisher()
            let backgroundColor = self.backgroundColorModel.userAction.map({Action.backgroundColor(.init(), $0)}).eraseToAnyPublisher()
            
            self.userAction = Publishers.Merge3(style, color, backgroundColor).map({ [weak self] value in
                self?.enhance(value)
            }).safelyUnwrapOptionals().eraseToAnyPublisher()
        }
        
        // MARK: Delivery and Dispatching
        /// We need to dispatch and deliver corrcet attributes to correct view models.
        private func dispatch(attribute: Attribute) {
            switch attribute {
            case .style: return
            case let .textColor(value): self.textColorModel.deliver(response: value)
            case let .backgroundColor(value): self.backgroundColorModel.deliver(response: value)
            }
        }
        
        private func dispatch(attributes: [Attribute]) {
            /// first, we should gather all attributes for style.
            let styleAttributes = attributes.compactMap({ value -> Panes.StylePane.Attribute? in
                switch value {
                case let .style(value): return value
                default: return nil
                }
            })
            
            let styleUserResponse = styleAttributes.map { (value) -> Panes.StylePane.UserResponse in
                switch value {
                case let .fontStyle(value): return .fontStyle([value])
                case let .alignment(value): return .alignment(value)
                }
            }
            styleUserResponse.forEach(self.styleModel.deliver(response:))
            
            _ = attributes.compactMap(self.dispatch)
        }
        
        // MARK: Public Setters
        /// Update at Range.
        func update(range: NSRange, attributedText: NSMutableAttributedString, alignment: NSTextAlignment = .left) {
            self.range = range
            let modifier = TextView.MarkStyleModifier(attributedText: attributedText)
            let styles = modifier.getMarkStyles(at: .range(range))
            let states = Converter.states(styles, [alignment])
            
            self.dispatch(attributes: states)
        }
        
        /// Update at whole string.
        /// It takes attributes from whole string ( bold, italic etc. ) and convert them to styles.
        ///
        func update(_ userResponse: RawUserResponse) {
            let attributedText: NSMutableAttributedString = .init(attributedString: userResponse.attributedString)
            
            let modifier = TextView.MarkStyleModifier(attributedText: attributedText)
            let styles = modifier.getMarkStyles(at: .whole(true))
            let states = Converter.states(styles, [userResponse.textAlignment])
            
            self.dispatch(attribute: .textColor(.setColor(userResponse.textColor)))
            self.dispatch(attribute: .backgroundColor(.setColor(userResponse.backgroundColor)))
            
            let styleAttributes = states.compactMap({ value -> Panes.StylePane.Attribute? in
                switch value {
                case let .style(value): return value
                default: return nil
                }
            })
            
            let styleUserResponse = styleAttributes.map { (value) -> Panes.StylePane.UserResponse in
                switch value {
                case let .fontStyle(value): return .fontStyle([value])
                case let .alignment(value): return .alignment(value)
                }
            }
            
            styleUserResponse.forEach(self.styleModel.deliver(response:))
        }
        
        func update(category: Section.Category) {
            self.sectionViewModel.chosenCategory = category
        }
        
        // MARK: For View
        func view(category: Section.Category) -> AnyView {
            switch category {
            case .style: return .init(Panes.StylePane.InputViewBuilder.createView(self.styleModel))
            case .textColor: return .init(Panes.Color.InputViewBuilder.createView(self.textColorModel))
            case .backgroundColor: return .init(Panes.Color.InputViewBuilder.createView(self.backgroundColorModel))
            }
        }
    }
}

// MARK: ViewModelHolder
extension TextView.MarksPane.Main {
    /// We have to add this creature...
    /// Well, as soon as we embed SwiftUI into UIKit, we have to deliver UIView to our host.
    /// But, UIView doesn't hold view model :/
    /// So, we need this `ViewModelHolder`, which will have access to UIView and to its ViewModel.
    /// 
    struct ViewModelHolder {
        @ObservedObject private(set) var viewModel: ViewModel = .init()
        private(set) lazy var view: UIView = {
            self.createView()
        }()
        func createView() -> UIView {
            InputViewBuilder.createView(self._viewModel, sectionViewModel: self.viewModel.observedSectionViewModel)
        }
    }
}

// MARK: - Pane View
extension TextView.MarksPane.Main {
    /// Builder that builds View from ViewModel.
    ///
    /// The only one way to build view from its viewModel.
    ///
    /// (ViewModel) -> (View)
    ///
    enum InputViewBuilder {
        static func createView(_ viewModel: ObservedObject<ViewModel>, sectionViewModel: ObservedObject<Section.ViewModel>) -> UIView {
            UIHostingController.init(rootView: InputView.init(viewModel: viewModel.wrappedValue, sectionViewModel: sectionViewModel.wrappedValue)).view
        }
    }
}

// MARK: - View
extension TextView.MarksPane.Main {
    struct InputView: View {
        @ObservedObject var viewModel: ViewModel
        
        // We should add sectionModel as ObservedObject to observe it and to receive updates from it.
        @ObservedObject var sectionViewModel: Section.ViewModel
        
        var layout: Layout = .init()
        var style: Style = .presentation
        
        var view: some View {
                VStack {
                    Divider().frame(height: self.layout.dividerHeight).background(Color(self.style.separatorColor()))
                    Spacer().frame(height: self.layout.topSpacing)
                    HStack(alignment: .top) {
                        Section.InputViewBuilder.createView(self.viewModel.observedSectionViewModel)
                    }
                    Spacer().frame(height: self.layout.intermediateSpacing)//(minLength: self.layout.minimumIntermediateSpacing)
                    HStack(alignment: .center) {
                        self.viewModel.view(category: self.sectionViewModel.chosenCategory)
                    }
                    Spacer(minLength: self.layout.minimumBottomSpacing)
                }
        }
        var body: some View {
            GeometryReader { geometry in
                self.view.frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
    }
}

// MARK: - View / Layout
extension TextView.MarksPane.Main.InputView {
    struct Layout {
        var dividerHeight: CGFloat = 1
        var topSpacing: CGFloat = 15
        var intermediateSpacing: CGFloat = 30
        var minimumBottomSpacing: CGFloat = 10
    }
}

// MARK: - View / Style
extension TextView.MarksPane.Main.InputView {
    enum Style {
        case presentation
        func separatorColor() -> UIColor {
            switch self {
            case .presentation: return .systemGray2
            }
        }
    }
}
