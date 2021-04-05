//
//  BlocksViews+New+Unknown+Label.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 05.11.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import os
import BlocksModels

fileprivate typealias Namespace = BlocksViews.New.Unknown.Label

private extension Logging.Categories {
    static let blocksViewsNewUnknownLabel: Self = "BlocksViews.New.Unknown.Label"
}

// MARK: ViewModel
extension Namespace {
    class ViewModel: BlocksViews.New.Unknown.Base.ViewModel {
        override func makeContentConfiguration() -> UIContentConfiguration {
            var configuration = ContentConfiguration.init(self.getBlock().blockModel.information)
            configuration.contextMenuHolder = self
            return configuration
        }
    }
}

// MARK: - State Converter
extension Namespace.ViewModel {
    enum ResourceConverter {
        typealias Model = Block.Information.InformationModel
        typealias OurModel = Resource
        static func asModel(_ value: OurModel) -> Model? {
            return nil
        }
        
        static func asOurModel(_ value: Model) -> OurModel? {
            let content = TopLevel.BlockUtilities.ContentTypeIdentifier.identifier(value.content)
            return .init(blockName: value.id, blockType: content)
        }
    }
}

// MARK: - Resource
extension Namespace.ViewModel {
    struct Resource: CustomStringConvertible {
        var description: String {
            "\(self.blockType) -> \(self.blockName)"
        }
        
        var blockName: String
        var blockType: String
    }
}

// Do we need UIKitView (?)
// It is used only by ContentConfiguration API.
// So, we only care about ContentConfiguration :D

// MARK: ContentConfiguration
extension Namespace.ViewModel {
    
    /// As soon as we have builder in this type ( makeContentView )
    /// We could map all states ( for example, image has several states ) to several different ContentViews.
    ///
    struct ContentConfiguration: UIContentConfiguration, Hashable {
        static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.information == rhs.information
        }
        func hash(into hasher: inout Hasher) {
            hasher.combine(self.information)
        }
        
        var information: Block.Information.InformationModel
        fileprivate weak var contextMenuHolder: Namespace.ViewModel?
        
        init(_ information: Information) {
            /// We could store somewhere which type we could treat as `Unknown`...
//            switch information.content {
//            case .bookmark: break
//            default:
//                let logger = Logging.createLogger(category: .blocksViewsNewUnknownLabel)
//                os_log(.error, log: logger, "Can't create content configuration for content: %@", String(describing: information.content))
//                break
//            }
            
            self.information = .init(information: information)
        }
                
        /// UIContentConfiguration
        func makeContentView() -> UIView & UIContentView {
            let view = ContentView(configuration: self)
            self.contextMenuHolder?.addContextMenuIfNeeded(view)
            return view
        }
        
        /// Hm, we could use state as from-user action channel.
        /// for example, if we have value "Checked"
        /// And we pressed something, we should do the following:
        /// We should pass value of state to a configuration.
        /// Next, configuration will send this value to a view model.
        /// Is it what we should use?
        func updated(for state: UIConfigurationState) -> ContentConfiguration {
            /// do something
            return self
        }
    }
}

// MARK: - ContentView
private extension Namespace.ViewModel {
    class ContentView: UIView & UIContentView {
        
        struct Layout {
            let insets: UIEdgeInsets = .init(top: 5, left: 5, bottom: 5, right: 5)
        }
        
        typealias TopView = UILabel
        
        /// Views
        private var topView: TopView = .init()
        private var contentView: UIView = .init()
        
        /// Subscriptions
        
        /// Others
//        var resource: Namespace.UIKitView.Resource = .init()
        var layout: Layout = .init()
                
        /// Setup
        private func setup() {
            self.setupUIElements()
            self.addLayout()
        }
        
        private func setupUIElements() {
            /// Top most ContentView should have .translatesAutoresizingMaskIntoConstraints = true
            self.translatesAutoresizingMaskIntoConstraints = true

            [self.contentView, self.topView].forEach { (value) in
                value.translatesAutoresizingMaskIntoConstraints = false
            }
            
            self.topView.lineBreakMode = .byWordWrapping
            self.topView.numberOfLines = 0
            
            /// View hierarchy
            self.contentView.addSubview(self.topView)
            self.addSubview(self.contentView)
        }
        
        private func addLayout() {
            if let superview = self.contentView.superview {
                let view = self.contentView
                NSLayoutConstraint.activate([
                    view.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: self.layout.insets.left),
                    view.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -self.layout.insets.right),
                    view.topAnchor.constraint(equalTo: superview.topAnchor, constant: self.layout.insets.top),
                    view.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -self.layout.insets.bottom),
                ])
            }
            
            if let superview = self.topView.superview {
                let view = self.topView
                NSLayoutConstraint.activate([
                    view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                    view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                    view.topAnchor.constraint(equalTo: superview.topAnchor),
                    view.bottomAnchor.constraint(equalTo: superview.bottomAnchor),
                ])
            }
        }
        
        /// Apply To View
        private func applyToTopView(_ value: Namespace.ViewModel.Resource?) {
            self.topView.text = value?.description
        }
        
        /// Handle
        private func handle(_ value: Namespace.ViewModel.Resource?) {
            self.applyToTopView(value)
        }
        
        private func handle(_ value: Namespace.ViewModel.ResourceConverter.Model) {
            /// Do something
            /// We should reload data if text are not equal
            ///
            ///
            // configure resource and subscribe on it.
            let model = Namespace.ViewModel.ResourceConverter.asOurModel(value)
            self.handle(model)
        }
        
        /// Cleanup
        private func cleanupOnNewConfiguration() {
            /// Cleanup subscriptions.
        }
        
        /// Initialization
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        /// ContentView
        var currentConfiguration: ContentConfiguration!
        var configuration: UIContentConfiguration {
            get { self.currentConfiguration }
            set {
                /// apply configuration
                guard let configuration = newValue as? ContentConfiguration else { return }
                self.apply(configuration: configuration)
            }
        }

        init(configuration: ContentConfiguration) {
            super.init(frame: .zero)
            self.setup()
            self.apply(configuration: configuration)
        }
        
        private func apply(configuration: ContentConfiguration, forced: Bool) {
//            if forced {
//                self.currentConfiguration?.contextMenuHolder?.addContextMenu(self)
//            }
        }
        
        private func apply(configuration: ContentConfiguration) {
            self.apply(configuration: configuration, forced: true)
            guard self.currentConfiguration != configuration else { return }
            
            self.currentConfiguration = configuration
            
            self.cleanupOnNewConfiguration()
            self.invalidateIntrinsicContentSize()
            
            self.handle(self.currentConfiguration.information)
        }
    }
}

