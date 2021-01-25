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
import UniformTypeIdentifiers

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
                    let logger = Logging.createLogger(category: .blocksViewsNewFileFile)
                    os_log(.info, log: logger, "User pressed on FileBlocksViews when our state is not empty.")
                    return
                }
                                
                let model: CommonViews.Pickers.File.Picker.ViewModel = .init()
                self.configureListening(model)
                self.send(userAction: .specific(.file(.file(.shouldShowFilePicker(.init(model: model))))))
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
    private func sendFile(at filePath: String) {
        let blockModel = self.getBlock()
        self.send(actionsPayload: .userAction(.init(model: blockModel, action: .specific(.file(.file(.shouldUploadFile(.init(filePath: filePath))))))))
    }
    func configureListening(_ pickerViewModel: CommonViews.Pickers.File.Picker.ViewModel) {
        pickerViewModel.$resultInformation.safelyUnwrapOptionals().sink { [weak self] (value) in
            self?.sendFile(at: value.filePath)
        }.store(in: &self.subscriptions)
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
            self.handle(.init(metadata: .empty(), contentType: .file, state: .empty))
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
                        
        private func handle(_ file: TopLevel.AliasesMap.BlockContent.File) {
            
            switch file.state  {
            case .empty:
                self.addEmptyViewLayout()
                self.emptyView.change(state: .empty)
            case .uploading:
                self.addEmptyViewLayout()
                self.emptyView.change(state: .uploading)
            case .done:
                self.addFileViewLayout()
            case .error:
                self.addEmptyViewLayout()
                self.emptyView.change(state: .error)
            }
            
            self.fileView.isHidden = [.empty, .uploading, .error].contains(file.state)
            self.emptyView.isHidden = [.done].contains(file.state)

        }
                
        func configured(publisher: AnyPublisher<TopLevel.AliasesMap.BlockContent.File, Never>) -> Self {
            self.subscription = publisher.receive(on: RunLoop.main).sink { [weak self] (value) in
                self?.handle(value)
            }
            return self
        }
        
        func configured(published: AnyPublisher<UIKitViewWithFile.Resource?, Never>) -> Self {
            self.fileView.configured(published)
            return self
        }
    }
}

fileprivate extension Namespace.UIKitView {
    func process(_ file: TopLevel.AliasesMap.BlockContent.File) {
        self.handle(file)
    }
    
    func process(_ resource: Namespace.UIKitViewWithFile.Resource?) {
        self.fileView.handle(resource)
    }
    func apply(_ file: TopLevel.AliasesMap.BlockContent.File) {
        self.process(file)
        let resource: Namespace.UIKitViewWithFile.Resource?
        switch file.contentType {
        case .file:
            let metadata = file.metadata
            resource = .init(size: Namespace.SizeConverter.convert(size: Int(metadata.size)), name: metadata.name, mime: Namespace.MimeConverter.convert(mime: metadata.mime))
        default: resource = nil
        }
        self.process(resource)
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
        private static func isEqualOrSubtype(mime: String, of uttype: UTType) -> Bool {
            guard let type = UTType.init(mimeType: mime) else { return false }
            return type == uttype || type.isSubtype(of: uttype)
        }

        
        private static var dictionary: [UTType: String] = [
            .text: "Text",
            .spreadsheet: "Spreadsheet",
            .presentation: "Presentation",
            .pdf: "PDF",
            .image: "Image",
            .audio: "Audio",
            .video: "Video",
            .archive: "Archive"
        ]
                
        static func convert(mime: String) -> String {
            let key = dictionary.keys.first(where: {self.isEqualOrSubtype(mime: mime, of: $0)})
            let name = key.flatMap({dictionary[$0]}) ?? "Other"
            let path = "TextEditor/Style/File/Content" + "/" + name
            return path
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
            case let .file(value) where value.contentType == .file: break
            default:
                let logger = Logging.createLogger(category: .blocksViewsNewFileFile)
                os_log(.error, log: logger, "Can't create content configuration for content: %@", String(describing: information.content))
                break
            }
            
            self.container = .init(value: information)
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
        
        typealias TopView = Namespace.UIKitView
        
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
        
        /// Handle
        private func handle(_ value: Block.Content.ContentType.File) {
            /// Do something
            /// We should reload data if text are not equal
            ///
            switch value.contentType {
            case .file: self.topView.apply(value)
            default: return
            }
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
            if forced {
                self.currentConfiguration?.contextMenuHolder?.addContextMenuIfNeeded(self)
            }
        }
        
        private func apply(configuration: ContentConfiguration) {
            self.apply(configuration: configuration, forced: true)
            guard self.currentConfiguration != configuration else { return }
            
            self.currentConfiguration = configuration
            
            self.cleanupOnNewConfiguration()
            self.invalidateIntrinsicContentSize()
            
            switch self.currentConfiguration.information.content {
            case let .file(value): self.handle(value)
            default: return
            }
        }
    }
}
