//
//  BlocksViews+New+Text+Callout.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 09.06.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import SwiftUI

// MARK: - ViewModel
extension BlocksViews.New.Text.Callout {
    class ViewModel: BlocksViews.New.Text.Base.ViewModel {
        @Published var style: Style = .emoji("🥳") {
            willSet {
                // BUG: Apple Bug.
                // Subclassing ObservableObject requires explicit invocation of self.objectWillChange.send() in willSet hook in @Published property.
                // Workaround: Explicit invocation
                self.objectWillChange.send()
            }
        }
        func update(style: Style) -> Self {
            self.style = style
            return self
        }

        override func makeSwiftUIView() -> AnyView {
            .init(BlockView(viewModel: self))
        }
    }
}

// MARK: - Style
extension BlocksViews.New.Text.Callout {
    enum Style {
        case none
        case emoji(String)
        func imageName() -> String {
            switch self {
            case .none: return ":facetime:"
            case let .emoji(name): return name
            }
        }
    }
}

// MARK: - View
private extension BlocksViews.New.Text.Callout {
    
    struct MarkedViewModifier: ViewModifier {
        @Binding var style: Style
        func image() -> AnyView {
            if case let .emoji(value) = self.style {
                return AnyView(Text(value))
            }
            else {
                return AnyView(Image(""))
            }
        }
        func body(content: Content) -> some View {
            HStack(alignment: .top) {
                Button(action: {
                    
                }) {
                    self.image()
                }
                content
            }
        }
    }
    
    struct BlockView: View {
        @ObservedObject var viewModel: ViewModel
        var body: some View {
            TextView(text: self.$viewModel.text)
                .modifier(MarkedViewModifier(style: self.$viewModel.style))
        }
    }
}
