
import UIKit
import Combine
import SwiftUI

extension BlocksViews.Toolbar {
    final class ViewController: UIViewController {
        // MARK: Variables
        private let model: ViewModel
        
        // MARK: Subscriptions
        private var subscriptions: Set<AnyCancellable> = []
        
        // MARK: Initialization
        init(model: ViewModel) {
            self.model = model
            super.init(nibName: nil, bundle: nil)
            model.dismissControllerPublisher.sink { [weak self] (value) in
                self?.dismiss(animated: true, completion: nil)
            }.store(in: &self.subscriptions)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func setupUIElements() {
            let chosenData = self.model.chosenView()
            if let chosenView = chosenData.view {
                self.view.addSubview(chosenView)
                chosenView.translatesAutoresizingMaskIntoConstraints = false
                chosenView.edgesToSuperview()
            }
            if let payload = chosenData.payload {
                self.navigationItem.title = payload.title
            }
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            self.setupUIElements()
        }
    }
}

// MARK: ViewBuilder
extension BlocksViews.Toolbar.ViewController {
    enum ViewBuilder {
    }
}

// MARK: ViewModel
extension BlocksViews.Toolbar.ViewController {
    final class ViewModel {
        typealias UnderlyingAction = BlocksViews.Toolbar.UnderlyingAction
        typealias Toolbar = BlocksViews.Toolbar
        
        // MARK: Variables
        var action: AnyPublisher<UnderlyingAction, Never> = .empty()
        var dismissControllerPublisher: AnyPublisher<Void, Never> = .empty()
        private var style: Style
        
        // MARK: Subscriptions
        private var subscriptions: Set<AnyCancellable> = []
                
        // MARK: Models
        @ObservedObject private var addBlockViewModel: Toolbar.AddBlock.ViewModel
        @ObservedObject private var turnIntoBlockViewModel: Toolbar.TurnIntoBlock.ViewModel
        @ObservedObject private var bookmarkViewModel: Toolbar.Bookmark.ViewModel
        
        // MARK: Setup
        private func publisher(style: Style) -> AnyPublisher<UnderlyingAction, Never> {
            switch style.style {
            case .addBlock: return self.addBlockViewModel.chosenBlockTypePublisher.safelyUnwrapOptionals().map { value in
                UnderlyingAction.addBlock(UnderlyingAction.BlockType.convert(value))
            }.eraseToAnyPublisher()
            case .turnIntoBlock: return self.turnIntoBlockViewModel.chosenBlockTypePublisher.safelyUnwrapOptionals().map { value in            
                UnderlyingAction.turnIntoBlock(UnderlyingAction.BlockType.convert(value))
            }.eraseToAnyPublisher()
            case .bookmark: return self.bookmarkViewModel.userAction.map({ value in
                UnderlyingAction.bookmark(.fetch(value))
            }).eraseToAnyPublisher()
            }
        }
        private func setup(style: Style) {
            self.action = self.publisher(style: style)
            self.dismissControllerPublisher = self.action.successToVoid().eraseToAnyPublisher()
        }
        
        // MARK: Initialization
        init(_ style: Style) {
            self.style = style
            self.addBlockViewModel = Toolbar.AddBlock.ViewModelBuilder.create()
            self.turnIntoBlockViewModel = Toolbar.TurnIntoBlock.ViewModelBuilder.create()
            self.bookmarkViewModel = Toolbar.Bookmark.ViewModelBuilder.create()
            
            if let filtering = self.style.filtering {
                _ = self.addBlockViewModel.configured(filtering: filtering)
                _ = self.turnIntoBlockViewModel.configured(filtering: filtering)
            }
            self.setup(style: style)
        }
                
        // MARK: Get Chosen View
        func chosenView() -> StyleAndViewAndPayload {
            switch self.style.style {
            case .addBlock: return .init(style: self.style, view: Toolbar.AddBlock.InputViewBuilder.createView(self._addBlockViewModel), payload: .init(title: self.addBlockViewModel.title))
            case .turnIntoBlock: return .init(style: self.style, view: Toolbar.TurnIntoBlock.InputViewBuilder.createView(self._turnIntoBlockViewModel), payload: .init(title: self.turnIntoBlockViewModel.title))
            case .bookmark: return .init(style: self.style, view: Toolbar.Bookmark.InputViewBuilder.createView(self._bookmarkViewModel), payload: .init(title: self.bookmarkViewModel.title))
            }
        }
    }
}

// MARK: Subscriptions
// TODO: Move this method to protocol.
// Theoretically each class can get power of this method.
extension BlocksViews.Toolbar.ViewController.ViewModel {
    func subscribe<S, T>(subject: S, keyPath: KeyPath<BlocksViews.Toolbar.ViewController.ViewModel, T>) where T: Publisher, S: Subject, T.Output == S.Output, T.Failure == S.Failure {
        self[keyPath: keyPath].subscribe(subject).store(in: &self.subscriptions)
    }
}

// MARK: StyleAndViewAndPayload
extension BlocksViews.Toolbar.ViewController.ViewModel {
    struct StyleAndViewAndPayload {
        struct Payload {
            let title: String
        }
        let style: Style
        let view: UIView?
        let payload: Payload?
    }
}

// MARK: Style
extension BlocksViews.Toolbar.ViewController.ViewModel {
    /// Necessary for different toolbars.
    /// We should add turnInto later.
    /// And may be we could add action toolbar here...
    ///
    struct Style {
        enum OurStyle {
            case addBlock, turnIntoBlock, bookmark
        }
        
        fileprivate var style: OurStyle = .addBlock
        fileprivate var filtering: BlocksViews.Toolbar.AddBlock.ViewModel.BlocksTypesCasesFiltering?
        
        init(style: BlocksViews.Toolbar.ViewController.ViewModel.Style.OurStyle = .addBlock, filtering: BlocksViews.Toolbar.AddBlock.ViewModel.BlocksTypesCasesFiltering? = nil) {
            self.style = style
            self.filtering = filtering
        }
    }
}
