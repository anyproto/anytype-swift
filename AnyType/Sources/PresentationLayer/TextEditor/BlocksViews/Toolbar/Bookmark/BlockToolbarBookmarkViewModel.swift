import Foundation
import Combine
import SwiftUI

// MARK: ViewModelBuilder
extension BlockToolbarBookmark {
    enum ViewModelBuilder {
        static func create() -> ViewModel {
            let viewModel: ViewModel = .init()
            return viewModel
        }
    }
}

// MARK: ViewModel
extension BlockToolbarBookmark {
    class ViewModel: ObservableObject {
        // MARK: Public / Publishers
        /// It is a chosen block type publisher.
        /// It receives value when user press/choose concrete cell with concrete associated block type.
        ///

        // MARK: Public / Variables
        var title = "Paste or type url"
        var buttonTitle = "Add bookmark"

        @ObservedObject var webViewModel: BlockToolbarBookmark.WebView.ViewModel = .init()
        
        @Published var typingURL: String = "" {
            didSet {
                self.webViewModel.url = self.typingURL
            }
        }
        @Published private var chosenURL: URL?
        var userAction: AnyPublisher<URL, Never> = .empty()
        
        // MARK: Choose
        func choose(url: String) {
            self.chosenURL = URL.init(string: url)
        }
        
        // MARK: Initialization
        init() {
            self.userAction = self.$chosenURL.safelyUnwrapOptionals().eraseToAnyPublisher()
        }
    }
}

// MARK: ViewModel / Configuration
extension BlockToolbarBookmark.ViewModel {
    func configured(title: String) -> Self {
        self.title = title
        return self
    }
    func configured(buttonTitle: String) -> Self {
        self.buttonTitle = buttonTitle
        return self
    }
}
