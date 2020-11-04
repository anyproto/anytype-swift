//
//  BlocksViews+New+File+Image.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 08.06.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import os
import BlocksModels

fileprivate typealias Namespace = BlocksViews.New.File.Image

private extension Logging.Categories {
    static let fileBlocksViewsImage: Self = "BlocksViews.New.File.Image"
}

// MARK: ViewModel
extension Namespace {
    class ViewModel: BlocksViews.New.File.Base.ViewModel {
        
        private var subscription: AnyCancellable?
        
        private var fileContentPublisher: AnyPublisher<File, Never> = .empty()
        
        override func makeUIView() -> UIView {
            UIKitView().configured(publisher: self.fileContentPublisher)
        }
        
        override func makeContentConfiguration() -> UIContentConfiguration {
            var configuration = ContentConfiguration.init(self.getBlock().blockModel.information)
            configuration.contextMenuHolder = self
            return configuration
        }
        
        // MARK: Subclassing
        override init(_ block: BlockModel) {
            super.init(block)
            self.setup()
        }
        
        // MARK: Subclassing / Events
        override func handle(event: BlocksViews.UserEvent) {
            switch event {
            case .didSelectRowInTableView:
                // we should show image picker only for empty state
                // TODO: Need to think about error state, reload or something
                if self.state != .empty {
                    let logger = Logging.createLogger(category: .fileBlocksViewsImage)
                    os_log(.info, log: logger, "User pressed on FileBlocksViews when our state is not empty.")
                    return
                }
                                
                let model: CommonViews.Pickers.Image.Picker.ViewModel = .init()
                self.configureListening(model)
                self.send(userAction: .specific(.file(.image(.shouldShowImagePicker(model)))))
            }
        }
        
        private func setup() {
            self.setupSubscribers()
        }
        
        func setupSubscribers() {
            let fileContentPublisher = self.getBlock().didChangeInformationPublisher().map({ value -> TopLevel.AliasesMap.BlockContent.File? in
                switch value.content {
                case let .file(value): return value
                default: return nil
                }
            }).safelyUnwrapOptionals().eraseToAnyPublisher()
            /// Should we store it (?)
            self.fileContentPublisher = fileContentPublisher
            
            self.subscription = self.fileContentPublisher.sink(receiveValue: { [weak self] (value) in
                self?.state = value.state
            })
        }
        
        override func makeDiffable() -> AnyHashable {
            let diffable = super.makeDiffable()
            if case let .file(value) = self.getBlock().blockModel.information.content {
                let newDiffable: [String: AnyHashable] = [
                    "parent": diffable,
                    "fileState": value.state
                ]
                return .init(newDiffable)
            }
            return diffable
        }
        
        // MARK: Contextual Menu
        override func makeContextualMenu() -> BlocksViews.ContextualMenu {
            .init(title: "", children: [
                .create(action: .general(.addBlockBelow)),
                .create(action: .general(.delete)),
                .create(action: .general(.duplicate)),
                .create(action: .specific(.download)),
                .create(action: .specific(.replace)),
                .create(action: .general(.moveTo)),
                .create(action: .specific(.addCaption)),
                .create(action: .specific(.backgroundColor)),
            ])
        }
    }
}

// MARK: - Image Picker Enhancements
private extension Namespace.ViewModel {
    func configureListening(_ pickerViewModel: CommonViews.Pickers.Image.Picker.ViewModel) {
        let blockModel = self.getBlock()
        guard let documentId = blockModel.findRoot()?.blockModel.information.id else { return }
        let blockId = blockModel.blockModel.information.id
        let pickerPublisher = pickerViewModel.$resultInformation.safelyUnwrapOptionals().map(\.filePath)
        let result = Publishers.CombineLatest3(Just(documentId), Just(blockId), pickerPublisher)
        result.map(\.0, \.1, \.2)
            .flatMap(IpfsFilesService().uploadDataAtFilePath.action)
            .sink(receiveCompletion: { value in
                switch value {
                case .finished: break
                case let .failure(value):
                    let logger = Logging.createLogger(category: .fileBlocksViewsImage)
                    os_log(.error, log: logger, "uploading image error %@ on %@", String(describing: value), String(describing: self))
                }
            }) { _ in }
            .store(in: &self.subscriptions)
    }
}

// MARK: - UIView
private extension Namespace {
    class UIKitView: UIView {
        
        typealias File = BlocksViews.New.File.Image.ViewModel.File
        typealias State = File.State
        typealias EmptyView = BlocksViews.New.File.Base.TopUIKitEmptyView
        
        struct Layout {
            var imageContentViewDefaultHeight: CGFloat = 250
            var imageViewTop: CGFloat = 4
            var emptyViewHeight: CGFloat = 52
        }
        
        struct Resource {
            var emptyViewPlaceholderTitle = "Add link or Upload a picture"
            var emptyViewImagePath = "TextEditor/Style/File/Empty/Image"
        }
        
        var subscription: AnyCancellable?
        
        var setupImageSubscription: AnyCancellable?
        
        var resource: Resource = .init()
        var layout: Layout = .init()
        
        // MARK: Views
        var imageContentView: UIView!
        var imageContentViewHeight: NSLayoutConstraint?
        var imageView: UIImageView!
        
        var emptyView: EmptyView!
        
        // MARK: Initialization
        override init(frame: CGRect) {
            super.init(frame: frame)
            self.setup()
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            self.setup()
        }
        
        // MARK: Setup
        func setup() {
            self.setupUIElements()
            self.addLayout()
        }
        
        // MARK: UI Elements
        func setupUIElements() {
            // Default behavior
            self.setupEmptyView()
            self.translatesAutoresizingMaskIntoConstraints = false
        }
        
        func setupImageView() {
            self.imageContentView = {
                let view = UIView()
                view.translatesAutoresizingMaskIntoConstraints = false
                return view
            }()
            
            self.imageView = {
                let view = UIImageView()
                view.contentMode = .scaleAspectFill
                view.clipsToBounds = true
                view.translatesAutoresizingMaskIntoConstraints = false
                return view
            }()
            
            self.imageContentView.addSubview(self.imageView)
            self.addSubview(imageContentView)
        }
        
        func setupEmptyView() {
            
            self.emptyView = {
                let view = EmptyView()
                view.translatesAutoresizingMaskIntoConstraints = false
                return view
            }()
            
            self.emptyView.configured(.init(placeholderText: self.resource.emptyViewPlaceholderTitle, imagePath: self.resource.emptyViewImagePath))
            
            self.addSubview(emptyView)
        }
        
        // MARK: Layout
        func addLayout() {
            addEmptyViewLayout()
        }
        
        func addImageViewLayout() {
            if let view = self.imageContentView, let superview = view.superview {
                imageContentViewHeight = view.heightAnchor.constraint(equalToConstant: self.layout.imageContentViewDefaultHeight)
                // We need priotity here cause cell self size constraint will conflict with ours
                imageContentViewHeight?.priority = .init(750)
                imageContentViewHeight?.isActive = true
                
                NSLayoutConstraint.activate([
                    view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                    view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                    view.topAnchor.constraint(equalTo: superview.topAnchor),
                    view.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
                ])
            }
            
            if let view = self.imageView, let superview = view.superview {
                NSLayoutConstraint.activate([
                    view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                    view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                    view.topAnchor.constraint(equalTo: superview.topAnchor, constant: self.layout.imageViewTop),
                    view.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
                ])
            }
        }
        
        func addEmptyViewLayout() {
            if let view = self.emptyView, let superview = view.superview {
                let heightAnchor = view.heightAnchor.constraint(equalToConstant: self.layout.emptyViewHeight)
                let bottomAnchor = view.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
                // We need priotity here cause cell self size constraint will conflict with ours
                bottomAnchor.priority = .init(750)
                
                NSLayoutConstraint.activate([
                    view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                    view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                    view.topAnchor.constraint(equalTo: superview.topAnchor),
                    bottomAnchor,
                    heightAnchor
                ])
            }
        }
        
        private func removeViewsIfExist() {
            if imageContentView != nil {
                self.imageContentView.removeFromSuperview()
            }
            if emptyView != nil {
                self.emptyView.removeFromSuperview()
            }
        }
        
        func setupImage(_ file: TopLevel.AliasesMap.BlockContent.File) {
            guard !file.metadata.hash.isEmpty else { return }
            let imageId = file.metadata.hash
            
            self.setupImageSubscription = CoreLayer.Network.Image.URLResolver.init().transform(imageId: imageId).safelyUnwrapOptionals().ignoreFailure().flatMap({
                CoreLayer.Network.Image.Loader.init($0).imagePublisher
            }).receive(on: RunLoop.main).sink { [weak self] (value) in
                if let imageView = self?.imageView {
                    imageView.image = value
                    self?.updateImageConstraints()
                }
            }
        }
        // TODO: Will work dynamic when finish granual reload of parent tableView
        private func updateImageConstraints()  {
            if let image = self.imageView.image, image.size.width > 0 {
                let width = image.size.width
                let height = image.size.height
                let viewWidth = self.imageView.frame.width
                let ratio = viewWidth / width
                let scaledHeight = height * ratio
                
                self.imageContentViewHeight?.constant = scaledHeight
            }
        }
        
        private func handleFile(_ file: TopLevel.AliasesMap.BlockContent.File) {
            self.removeViewsIfExist()
            
            switch file.state  {
            case .empty:
                self.setupEmptyView()
                self.addEmptyViewLayout()
                self.emptyView.change(state: .empty)
            case .uploading:
                self.setupEmptyView()
                self.addEmptyViewLayout()
                self.emptyView.change(state: .uploading)
            case .done:
                self.setupImageView()
                self.addImageViewLayout()
                self.setupImage(file)
            case .error:
                self.setupEmptyView()
                self.addEmptyViewLayout()
                self.emptyView.change(state: .error)
            }
        }
        
        func configured(publisher: AnyPublisher<TopLevel.AliasesMap.BlockContent.File, Never>) -> Self {
            self.subscription = publisher.receive(on: RunLoop.main).sink { [weak self] (value) in
                self?.handleFile(value)
            }
            return self
        }
    }
}

// MARK: ContentConfiguration
extension Namespace.ViewModel {
    
    /// As soon as we have builder in this type ( makeContentView )
    /// We could map all states ( for example, image has several states ) to several different ContentViews.
    ///
    struct ContentConfiguration: UIContentConfiguration, Hashable {
        static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.container == rhs.container
        }
        func hash(into hasher: inout Hasher) {
            hasher.combine(self.container)
        }
        
        typealias HashableContainer = TopLevel.AliasesMap.BlockInformationUtilities.AsHashable
        var information: Information {
            self.container.value
        }
        private var container: HashableContainer
        fileprivate weak var contextMenuHolder: Namespace.ViewModel?
        
        init(_ information: Information) {
            /// We should warn if we have incorrect content type (?)
            /// Don't know :(
            /// Think about failable initializer
            
            switch information.content {
            case let .file(value) where value.contentType == .image: break
            default:
                let logger = Logging.createLogger(category: .fileBlocksViewsImage)
                os_log(.error, log: logger, "Can't create content configuration for content: %@", String(describing: information.content))
                break
            }
            
            self.container = .init(value: information)
        }
                
        /// UIContentConfiguration
        func makeContentView() -> UIView & UIContentView {
            let view = ContentView(configuration: self)
            self.contextMenuHolder?.addContextMenu(view)
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
        
        /// Views
        var imageContentView: UIView = .init()
        var imageContentViewHeight: NSLayoutConstraint?
        var imageView: UIImageView = .init()
        
        var emptyView: Namespace.UIKitView.EmptyView = .init()
        
        /// Subscriptions
        var setupImageSubscription: AnyCancellable?
        
        /// Publishers Properties
        var imageProperty: CoreLayer.Network.Image.Property?
        
        /// Others
        var resource: Namespace.UIKitView.Resource = .init()
        var layout: Namespace.UIKitView.Layout = {
            var layout: Namespace.UIKitView.Layout = .init()
            layout.imageViewTop = 0
            return layout
        }()
                
        /// Setup
        func setup() {
            self.setupUIElements()
        }
        
        func setupUIElements() {
            
            /// Empty View
            self.emptyView.configured(.init(placeholderText: self.resource.emptyViewPlaceholderTitle, imagePath: self.resource.emptyViewImagePath))
            
            /// Image View
            self.imageView.contentMode = .scaleAspectFill
            self.imageView.clipsToBounds = true
            
            /// Disable Autoresizing Mask
            [self.emptyView, self.imageContentView, self.imageView].forEach { (value) in
                value.translatesAutoresizingMaskIntoConstraints = false
            }
            
            /// Top most ContentView should have .translatesAutoresizingMaskIntoConstraints = true
            self.translatesAutoresizingMaskIntoConstraints = true

            /// View hierarchy
            self.addSubview(self.emptyView)
            self.imageContentView.addSubview(self.imageView)
            self.addSubview(imageContentView)
        }
        
        func addImageViewContentLayout() {
            let view = self.imageContentView
            if let superview = view.superview {
                imageContentViewHeight = view.heightAnchor.constraint(equalToConstant: self.layout.imageContentViewDefaultHeight)
                // We need priotity here cause cell self size constraint will conflict with ours
//                imageContentViewHeight?.priority = .init(750)
                imageContentViewHeight?.isActive = true
                
                NSLayoutConstraint.activate([
                    view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                    view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                    view.topAnchor.constraint(equalTo: superview.topAnchor),
                    view.bottomAnchor.constraint(equalTo: superview.bottomAnchor),
                ])
            }
        }
        
        func addImageViewLayout() {
            self.addImageViewContentLayout()
            let view = self.imageView
            if let superview = view.superview {
                NSLayoutConstraint.activate([
                    view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                    view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                    view.topAnchor.constraint(equalTo: superview.topAnchor, constant: self.layout.imageViewTop),
                    view.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
                ])
            }
        }
        
        func addEmptyViewLayout() {
            let view = self.emptyView
            if let superview = view.superview {
                let heightAnchor = view.heightAnchor.constraint(equalToConstant: self.layout.emptyViewHeight)
                let bottomAnchor = view.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
                // We need priotity here cause cell self size constraint will conflict with ours
                bottomAnchor.priority = .init(750)
                
                NSLayoutConstraint.activate([
                    view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                    view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                    view.topAnchor.constraint(equalTo: superview.topAnchor),
                    bottomAnchor,
                    heightAnchor
                ])
            }
        }
        
        func setupImage(_ file: TopLevel.AliasesMap.BlockContent.File, _ oldFile: TopLevel.AliasesMap.BlockContent.File?) {
            guard !file.metadata.hash.isEmpty else { return }
            let imageId = file.metadata.hash
            guard imageId != oldFile?.metadata.hash else { return }
            // We could put image into viewModel.
            // In this case we would only check

            self.imageProperty = CoreLayer.Network.Image.Property.init(imageId: imageId, .init(width: .default))
            
            if let image = self.imageProperty?.property {
                self.imageView.image = image
                return
            }
            
            self.imageView.image = nil
            self.setupImageSubscription = self.imageProperty?.stream.receive(on: RunLoop.main).sink { [weak self] (value) in
                self?.imageView.image = value
//                    self?.updateImageConstraints()
            }
        }
        
        // TODO: Will work dynamic when finish granual reload of parent tableView
        private func updateImageConstraints()  {
            if let image = self.imageView.image, image.size.width > 0 {
                let width = image.size.width
                let height = image.size.height
                let viewWidth = self.imageView.frame.width
                let ratio = viewWidth / width
                let scaledHeight = height * ratio
                
                self.imageContentViewHeight?.constant = scaledHeight
            }
        }
        
        /// Cleanup
        private func cleanupOnNewConfiguration() {
            self.setupImageSubscription = nil
        }
        /// Handle new value
        private func handleFile(_ file: TopLevel.AliasesMap.BlockContent.File, _ oldFile: TopLevel.AliasesMap.BlockContent.File?) {
//            self.removeViewsIfExist()
            
            switch file.state {
            case .empty:
//                self.setupEmptyView()
                self.imageContentView.removeFromSuperview()
                self.addSubview(self.emptyView)
                self.addEmptyViewLayout()
                self.emptyView.change(state: .empty)
            case .uploading:
//                self.setupEmptyView()
                self.imageContentView.removeFromSuperview()
                self.addSubview(self.emptyView)
                self.addEmptyViewLayout()
                self.emptyView.change(state: .uploading)
            case .done:
//                self.setupImageView()
                self.emptyView.removeFromSuperview()
                self.addSubview(self.imageContentView)
                self.addImageViewLayout()
                self.setupImage(file, oldFile)
//                self.updateImageConstraints()
            case .error:
//                self.setupEmptyView()
                self.imageContentView.removeFromSuperview()
                self.addSubview(self.emptyView)
                self.addEmptyViewLayout()
                self.emptyView.change(state: .error)
            }
            switch file.state {
            case .empty, .error, .uploading:
                self.emptyView.isHidden = false
                self.imageContentView.isHidden = true
            case .done:
                self.emptyView.isHidden = true
                self.imageContentView.isHidden = false
            }
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
            if forced {
                self.currentConfiguration?.contextMenuHolder?.addContextMenu(self)
            }
        }
        
        private func apply(configuration: ContentConfiguration) {
            self.apply(configuration: configuration, forced: true)
            guard self.currentConfiguration != configuration else { return }
            let oldConfiguration = self.currentConfiguration
            self.currentConfiguration = configuration
            
            self.cleanupOnNewConfiguration()
            switch (self.currentConfiguration.information.content, oldConfiguration?.information.content) {
            case let (.file(value), .file(oldValue)): self.handleFile(value, oldValue)
            case let (.file(value), .none): self.handleFile(value, .none)
            default: return
            }
        }
    }
}
