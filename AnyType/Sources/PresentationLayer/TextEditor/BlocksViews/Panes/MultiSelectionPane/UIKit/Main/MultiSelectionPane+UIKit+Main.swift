//
//  MultiSelectionPane+UIKit+Main.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 21.06.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import UIKit
import Combine
import SwiftUI
import os

fileprivate typealias Namespace = MultiSelectionPane.UIKit
fileprivate typealias FileNamespace = MultiSelectionPane.UIKit.Main

extension Namespace {
    enum Main {}
}

extension FileNamespace {
    typealias Panes = MultiSelectionPane.UIKit.Panes
}

// MARK: States
extension FileNamespace {
    // MARK: Action
    enum Action {
        case toolbar(Panes.Toolbar.Action)
        case selection(Panes.Selection.Action)
    }
    
    // MARK: State
    /// Internal State for View.
    /// For example, if you press button which doesn't hide keyboard, by design, this button could be highlighted.
    ///
    typealias UserResponse = Int
}

// MARK: ViewModel
extension FileNamespace {
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
            _ = self._selectionViewModel.configured(userResponseStream: self.userResponse)
            
            // To OuterWorld
            self.userAction = Publishers.Merge(self._toolbarViewModel.userAction.map(Action.toolbar), self._selectionViewModel.userAction.map(Action.selection)).eraseToAnyPublisher()
        }
        
        // MARK: ViewModels
        private var _toolbarViewModel: MultiSelectionPane.UIKit.Panes.Toolbar.ViewModel = .init()
        private var _selectionViewModel: MultiSelectionPane.UIKit.Panes.Selection.ViewModel = .init()
        
        // MARK: Publishers
        
        /// From OuterWorld
        private var userResponseSubject: PassthroughSubject<UserResponse?, Never> = .init()
        fileprivate var userResponse: AnyPublisher<UserResponse, Never> = .empty()
                
        /// To OuterWorld
        var userAction: AnyPublisher<Action, Never> = .empty()

        // MARK: Public Setters
        /// Use this method from outside to update value.
        ///
        func handle(countOfObjects: Int) {
            self.userResponseSubject.send(countOfObjects)
        }
    }
}

// TODO: Add cache if needed.
extension FileNamespace.ViewModel {
    func toolbarViewModel() -> MultiSelectionPane.UIKit.Panes.Toolbar.ViewModel {
        self._toolbarViewModel
    }
    
    func selectionViewModel() -> MultiSelectionPane.UIKit.Panes.Selection.ViewModel {
        _selectionViewModel
    }
}

// MARK: Builder
extension FileNamespace {
    enum Builder {
        enum Kind {
            case selection
            case toolbar
        }
        
        static func buildView(viewModel: ViewModel, kind: Kind) -> UIView {
            switch kind {
            case .selection: return FileNamespace.Panes.Selection.Assembly.init(viewModel: viewModel.selectionViewModel()).buildView()
            case .toolbar: return FileNamespace.Panes.Toolbar.View.init(viewModel: viewModel.toolbarViewModel())
            }
        }
    }
}

// MARK: Assembly
extension FileNamespace {
    struct Assembly {
        /// Aliases
        typealias SelectionAssembly = MultiSelectionPane.UIKit.Panes.Selection.Assembly
        
        /// Variables
        private(set) var viewModel: ViewModel = .init()
        private(set) var selectionAssembly: SelectionAssembly
        
        /// Initialization
        init() {
            self.selectionAssembly = .init(viewModel: self.viewModel.selectionViewModel())
        }
        
        /// Getters
        func toolbarView() -> UIView {
            Builder.buildView(viewModel: self.viewModel, kind: .toolbar)
        }
        
        func selectionView() -> UIView {
            Builder.buildView(viewModel: self.viewModel, kind: .selection)
        }
    }
}
