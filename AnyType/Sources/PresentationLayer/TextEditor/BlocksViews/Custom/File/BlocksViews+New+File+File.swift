//
//  BlocksViews+New+File+File.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 19.07.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import os
import BlocksModels
import MobileCoreServices

fileprivate typealias Namespace = BlocksViews.New.File.File

private extension Logging.Categories {
    static let blocksViewsNewFileFile: Self = "BlocksViews.New.File.File"
}

// MARK: ViewModel
extension Namespace {
    class ViewModel: BlocksViews.New.File.Base.ViewModel {
                
        private var subscription: AnyCancellable?
        
        private var fileContentPublisher: AnyPublisher<File, Never> = .empty()
        
        @Published private var fileResource: UIKitViewWithFile.Resource?
        
        override func makeUIView() -> UIView {
            UIKitView().configured(publisher: self.fileContentPublisher).configured(published: self.$fileResource.eraseToAnyPublisher())
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
                    let logger = Logging.createLogger(category: .blocksViewsNewFileFile)
                    os_log(.info, log: logger, "User pressed on FileBlocksViews when our state is not empty.")
                    return
                }
                
                let blockModel = self.getBlock()
                guard let documentId = blockModel.findRoot()?.blockModel.information.id else { return }
                let blockId = blockModel.blockModel.information.id
                
                let model: CommonViews.Pickers.File.Picker.ViewModel = .init(documentId: documentId, blockId: blockId)
                self.configureListening(imagePickerViewModel: model)
                self.send(userAction: .specific(.file(.file(.shouldShowFilePicker(model)))))
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
                
                let metadata = value.metadata
                self?.fileResource = .init(size: SizeConverter.convert(size: Int(metadata.size)), name: metadata.name, mime: MimeConverter.convert(mime: metadata.mime))
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
    func configureListening(imagePickerViewModel: CommonViews.Pickers.File.Picker.ViewModel) {
        imagePickerViewModel.$resultInformation.safelyUnwrapOptionals().notableError()
            .map(\.documentId, \.blockId, \.filePath)
            .flatMap(IpfsFilesService().upload(contextID:blockID:filePath:))
            .sink(receiveCompletion: { value in
                switch value {
                case .finished: break
                case let .failure(value):
                    let logger = Logging.createLogger(category: .blocksViewsNewFileFile)
                    os_log(.error, log: logger, "uploading image error %@ on %@", String(describing: value), String(describing: self))
                }
            }) { _ in }
        .store(in: &self.subscriptions)
    }
}

// MARK: - UIView
private extension Namespace {
    class UIKitViewWithFile: UIView {
        enum Style {
            case presentation
            var titleFont: UIFont {
                switch self {
                case .presentation: return .systemFont(ofSize: 15)
                }
            }
            var sizeFont: UIFont {
                switch self {
                case .presentation: return .systemFont(ofSize: 13)
                }
            }
            var titleColor: UIColor {
                switch self {
                case .presentation: return .black
                }
            }
            var sizeColor: UIColor {
                switch self {
                case .presentation: return .lightGray
                }
            }
        }
        
        struct Layout {
            var offset: CGFloat = 10
        }
        
        struct Resource {
            var size: String
            var name: String
            var mime: String
        }
        
        /// Variables
        var style: Style = .presentation {
            didSet {
                self.titleView.font = self.style.titleFont
                self.sizeView.font = self.style.sizeFont
            }
        }
        
        var layout: Layout = .init()
        
        /// Publishers
        var subscription: AnyCancellable?
        @Published var resource: Resource? {
            didSet {
                self.handle(self.resource)
            }
        }
        
        /// Views
        var contentView: UIView!
        var imageView: UIImageView!
        var titleView: UILabel!
        var sizeView: UILabel!
        
        /// Initialization
        override init(frame: CGRect) {
            super.init(frame: frame)
            self.setup()
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            self.setup()
        }
        
        /// Setup
        func setup() {
            self.setupUIElements()
            self.addLayout()
        }

        /// UI Elements
        func setupUIElements() {
            self.translatesAutoresizingMaskIntoConstraints = false
            
            self.contentView = {
                let view = UIView()
                view.translatesAutoresizingMaskIntoConstraints = false
                return view
            }()
            
            self.imageView = {
                let view = UIImageView()
                view.contentMode = .center
                view.translatesAutoresizingMaskIntoConstraints = false
                return view
            }()
            
            self.titleView = {
                let view = UILabel()
                view.translatesAutoresizingMaskIntoConstraints = false
                view.font = self.style.titleFont
                view.textColor = self.style.titleColor
                return view
            }()
            
            self.sizeView = {
                let view = UILabel()
                view.translatesAutoresizingMaskIntoConstraints = false
                view.font = self.style.sizeFont
                view.textColor = self.style.sizeColor
                return view
            }()
            
            self.contentView.addSubview(self.imageView)
            self.contentView.addSubview(self.titleView)
            self.contentView.addSubview(self.sizeView)
            
            self.addSubview(self.contentView)
        }
        
        /// Layout
        func addLayout() {
            let offset: CGFloat = self.layout.offset
            
            if let view = self.contentView, let superview = view.superview {
                NSLayoutConstraint.activate([
                    view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                    view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                    view.topAnchor.constraint(equalTo: superview.topAnchor),
                    view.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
                ])
            }
            
            if let view = self.imageView, let superview = view.superview {
                NSLayoutConstraint.activate([
                    view.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: offset),
                    view.topAnchor.constraint(equalTo: superview.topAnchor),
                    view.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
                ])
            }
            
            if let view = self.titleView, let superview = view.superview, let leftView = self.imageView {
                NSLayoutConstraint.activate([
                    view.leadingAnchor.constraint(equalTo: leftView.trailingAnchor, constant: offset),
                    view.topAnchor.constraint(equalTo: superview.topAnchor),
                    view.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
                ])
            }

            if let view = self.sizeView, let superview = view.superview, let leftView = self.titleView {
                NSLayoutConstraint.activate([
                    view.leadingAnchor.constraint(equalTo: leftView.trailingAnchor, constant: offset),
                    view.trailingAnchor.constraint(lessThanOrEqualTo: superview.trailingAnchor, constant: -offset),
                    view.topAnchor.constraint(equalTo: superview.topAnchor),
                    view.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
                ])
            }
        }
        
        /// Configurations
        func handle(_ value: Resource?) {
            self.titleView.text = value?.name
            self.imageView.image = UIImage.init(named: value?.mime ?? "")
            self.sizeView.text = value?.size
        }
        
        func configured(_ stream: AnyPublisher<Resource?, Never>) {
            self.subscription = stream.receive(on: RunLoop.main).sink(receiveValue: { [weak self] (value) in
                self?.resource = value
            })
        }
    }
}

private extension Namespace {
    class UIKitView: UIView {
        
        typealias File = BlocksViews.New.File.Base.ViewModel.File
        typealias State = File.State
        typealias EmptyView = BlocksViews.New.File.Base.TopUIKitEmptyView
        
        struct Layout {
            var imageContentViewDefaultHeight: CGFloat = 250
            var imageViewTop: CGFloat = 4
            var emptyViewHeight: CGFloat = 52
        }
        
        var subscription: AnyCancellable?
        
        var layout: Layout = .init()
        
        // MARK: Views
        var contentView: UIView!
        var fileView: UIKitViewWithFile!
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
            self.handleFile(.init(metadata: .empty(), contentType: .file, state: .empty))
        }
        
        // MARK: UI Elements
        func setupUIElements() {
            // Default behavior
            self.translatesAutoresizingMaskIntoConstraints = false
            
            self.contentView = {
                let view = UIView()
                view.translatesAutoresizingMaskIntoConstraints = false
                return view
            }()
            
            self.fileView = {
                let view = UIKitViewWithFile()
                view.layer.borderWidth = 1
                view.layer.borderColor = UIColor(hexString: "#DFDDD0").cgColor
                view.layer.cornerRadius = 4
                view.translatesAutoresizingMaskIntoConstraints = false
                return view
            }()
            
            self.emptyView = {
                let view = EmptyView()
                view.translatesAutoresizingMaskIntoConstraints = false
                return view
            }()
            
            self.contentView.addSubview(self.fileView)
            self.contentView.addSubview(self.emptyView)
            self.addSubview(self.contentView)
        }
        
        // MARK: Layout
        func addLayout() {
            if let view = self.contentView, let superview = view.superview {
                NSLayoutConstraint.activate([
                    view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                    view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                    view.topAnchor.constraint(equalTo: superview.topAnchor),
                    view.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
                ])
            }
            self.addEmptyViewLayout()
        }
        
        func addFileViewLayout() {
            if let view = self.fileView, let superview = view.superview {
                NSLayoutConstraint.activate([
                    view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                    view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                    view.topAnchor.constraint(equalTo: superview.topAnchor),
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
                        
        private func handleFile(_ file: TopLevel.AliasesMap.BlockContent.File) {
            
            switch file.state  {
            case .empty:
                self.addEmptyViewLayout()
            case .uploading:
                self.addEmptyViewLayout()
                self.emptyView.toUploadingView()
            case .done:
                self.addFileViewLayout()
            case .error:
                self.addEmptyViewLayout()
                self.emptyView.toErrorView()
            }
            
            self.fileView.isHidden = [.empty, .uploading, .error].contains(file.state)
            self.emptyView.isHidden = [.done].contains(file.state)

        }
        
        func configured(publisher: AnyPublisher<TopLevel.AliasesMap.BlockContent.File, Never>) -> Self {
            self.subscription = publisher.receive(on: RunLoop.main).sink { [weak self] (value) in
                self?.handleFile(value)
            }
            return self
        }
        
        func configured(published: AnyPublisher<UIKitViewWithFile.Resource?, Never>) -> Self {
            self.fileView.configured(published)
            return self
        }
    }
}

// MARK: - Converters
// MARK: - Converters / Size
private extension Namespace {
    struct SizeConverter {
        private static var formatter: ByteCountFormatter = {
           let formatter = ByteCountFormatter.init()
           formatter.allowedUnits = .useAll
           formatter.allowsNonnumericFormatting = true
           formatter.countStyle = .file
           return formatter
        }()
        
        static func convert(size: Int) -> String {
            self.formatter.string(fromByteCount: Int64(size))
        }
    }
}

// MARK: - Converters / Image
private extension Namespace {
    struct MimeConverter {
        /// TODO: Remove when iOS 14 will be released.
        /// Well, in iOS 14 it will be SIMPLE.
        /// For now we could only do this...
        private static func conforms(mime: String, uttype: CFString) -> Bool {
            UTTypeConformsTo(mime as CFString, uttype)
        }
        
        private static var dictionary: [CFString: String] = [
            kUTTypeText: "Text",
            kUTTypeSpreadsheet: "Spreadsheet",
            kUTTypePresentation: "Presentation",
            kUTTypePDF: "PDF",
            kUTTypeImage: "Image",
            kUTTypeAudio: "Audio",
            kUTTypeVideo: "Video",
            kUTTypeArchive: "Archive",
        ]
        
        static func convert(mime: String) -> String {
            let key = dictionary.keys.first(where: {self.conforms(mime: mime, uttype: $0)})
            let name = key.flatMap({dictionary[$0]}) ?? "Other"
            let path = "TextEditor/Style/File/Content" + "/" + name
            return path
        }
    }
}
