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
                
                let blockModel = self.getBlock()
                guard let documentId = blockModel.findRoot()?.blockModel.information.id else { return }
                let blockId = blockModel.blockModel.information.id
                
                let model: ImagePickerUIKit.ViewModel = .init(documentId: documentId, blockId: blockId)
                self.configureListening(imagePickerViewModel: model)
                // self.getRealBlock()
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
    func configureListening(imagePickerViewModel: ImagePickerUIKit.ViewModel) {
        imagePickerViewModel.$resultInformation.safelyUnwrapOptionals().notableError()
            .map(\.documentId, \.blockId, \.filePath)
            .flatMap(IpfsFilesService().upload(contextID:blockID:filePath:))
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
            let blockHash = file.metadata.hash
            _ = MiddlewareConfigurationService().obtainConfiguration().sink(receiveCompletion: { value in
                switch value {
                case .finished: break
                case let .failure(value):
                    let logger = Logging.createLogger(category: .fileBlocksViewsImage)
                    os_log(.error, log: logger, "Obtaining image error %@ on %@", String(describing: value), String(describing: self))
                }
            }, receiveValue: { (config) in
                
                guard let url = URL(string: config.gatewayURL + "/image/" + blockHash) else { return }
                
                // TODO: WIll change loading to new ImageLoader class
                DispatchQueue.global().async {
                    if let data = try? Data(contentsOf: url) {
                        DispatchQueue.main.async {
                            if let imageView = self.imageView {
                                imageView.image = UIImage(data: data)
                                self.updateImageConstraints()
                            }
                        }
                    }
                }
            })
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
            case .uploading:
                self.setupEmptyView()
                self.addEmptyViewLayout()
                self.emptyView.toUploadingView()
            case .done:
                self.setupImageView()
                self.addImageViewLayout()
                self.setupImage(file)
            case .error:
                self.setupEmptyView()
                self.addEmptyViewLayout()
                self.emptyView.toErrorView()
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
