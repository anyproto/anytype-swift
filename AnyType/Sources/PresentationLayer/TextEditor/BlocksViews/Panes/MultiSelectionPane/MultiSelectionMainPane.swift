import Foundation
import UIKit
import Combine
import SwiftUI
import os

enum MultiSelectionMainPane {}

extension MultiSelectionMainPane {
    typealias Panes = MultiSelectionPane.Panes
}

// MARK: States
extension MultiSelectionMainPane {
    // MARK: Action
    enum Action {
        case toolbar(MultiSelectionPaneToolbarAction)
        case selection(MultiSelectionPaneSelectionAction)
    }
    
    // MARK: State
    /// Internal State for View.
    /// For example, if you press button which doesn't hide keyboard, by design, this button could be highlighted.
    ///
    struct UserResponse {
        var selectedItemsCount: Int
        var turnIntoStyles: [BlocksViews.Toolbar.BlocksTypes]
    }
}

// MARK: ViewModel
extension MultiSelectionMainPane {
    class ViewModel {
        // MARK: Initialization
        init() {
            self.setup()
        }

        // MARK: Setup
        func setup() {
            
            // From OuterWorld
            self.userResponse = self.userResponseSubject.safelyUnwrapOptionals().eraseToAnyPublisher()
            
            _ = self._toolbarViewModel.configured(userResponseStream: self.userResponse)
            _ = self._selectionViewModel.configured(userResponseStream: self.userResponse.map(\.selectedItemsCount).eraseToAnyPublisher())
            
            // To OuterWorld
            self.userAction = Publishers.Merge(self._toolbarViewModel.userAction.map(Action.toolbar), self._selectionViewModel.userAction.map(Action.selection)).eraseToAnyPublisher()
        }
        
        // MARK: ViewModels
        private var _toolbarViewModel = MultiSelectionPaneToolbarViewModel()
        private var _selectionViewModel = MultiSelectionPaneSelectionViewModel()
        
        // MARK: Publishers
        
        /// From OuterWorld
        private var userResponseSubject: PassthroughSubject<UserResponse?, Never> = .init()
        fileprivate var userResponse: AnyPublisher<UserResponse, Never> = .empty()
                
        /// To OuterWorld
        var userAction: AnyPublisher<Action, Never> = .empty()

        // MARK: Public Setters
        /// Use this method from outside to update value.
        ///
        func handle(countOfObjects: Int, turnIntoStyles: [BlocksViews.Toolbar.BlocksTypes]) {
            self.userResponseSubject.send(UserResponse(selectedItemsCount: countOfObjects,
                                                       turnIntoStyles: turnIntoStyles))
        }
    }
}

// TODO: Add cache if needed.
extension MultiSelectionMainPane.ViewModel {
    func toolbarViewModel() -> MultiSelectionPaneToolbarViewModel {
        self._toolbarViewModel
    }
    
    func selectionViewModel() -> MultiSelectionPaneSelectionViewModel {
        _selectionViewModel
    }
}

// MARK: Assembly
extension MultiSelectionMainPane {
    struct Assembly {
        
        private(set) var viewModel: ViewModel
        private(set) var selectionAssembly: MultiSelectionPaneSelectionAssembly
        
        init(viewModel: ViewModel) {
            self.viewModel = viewModel
            self.selectionAssembly = .init(viewModel: viewModel.selectionViewModel())
        }
        
        func toolbarView() -> UIView {
            MultiSelectionPaneToolbarView(viewModel: viewModel.toolbarViewModel())
        }
        
        func selectionView() -> UIView {
            MultiSelectionPaneSelectionAssembly(viewModel: viewModel.selectionViewModel()).buildView()
        }
    }
}
