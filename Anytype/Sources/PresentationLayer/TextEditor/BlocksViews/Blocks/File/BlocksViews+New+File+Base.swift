import Combine
import BlocksModels
import UIKit

fileprivate typealias Namespace = BlocksViews.File.Base

extension Namespace {
    class ViewModel: BaseBlockViewModel {
        typealias File = BlockContent.File
        typealias State = File.State
        
        private var subscription: AnyCancellable?
        
        private var fileContentPublisher: AnyPublisher<File, Never> = .empty()
        
        @Published private(set) var fileResource: BlocksViewsFileUIKitViewWithFile.Resource?
        private var subscriptions: Set<AnyCancellable> = []
        @Published var state: State? { willSet { self.objectWillChange.send() } }
        
        init(_ block: BlockActiveRecordModelProtocol, delegate: BaseBlockDelegate?, router: EditorRouterProtocol?, actionHandler: NewBlockActionHandler?) {
            super.init(block, delegate: delegate, actionHandler: actionHandler, router: router)
            setupSubscribers()
        }
        
        override var diffable: AnyHashable {
            let diffable = super.diffable
            if case let .file(value) = block.content {
                let newDiffable: [String: AnyHashable] = [
                    "parent": diffable,
                    "fileState": value.state
                ]
                return .init(newDiffable)
            }
            return diffable
        }
        
        override func didSelectRowInTableView() {
            if self.state == .uploading {
                return
            }
            self.handleReplace()
        }
        
        override func makeContextualMenu() -> BlocksViews.ContextualMenu {
            .init(title: "", children: [
                .create(action: .general(.addBlockBelow)),
                .create(action: .general(.delete)),
                .create(action: .general(.duplicate)),
                .create(action: .specific(.download)),
                .create(action: .specific(.replace))
            ])
        }
        
        override func handle(contextualMenuAction: BlocksViews.ContextualMenu.MenuAction.Action) {
            switch contextualMenuAction {
            case let .specific(specificAction):
                switch specificAction {
                case .replace:
                    self.handleReplace()
                case.download:
                    self.downloadFile()
                default:
                    break
                }
            default:
                break
            }
            super.handle(contextualMenuAction: contextualMenuAction)
        }
        
        /// Handle replace contextual menu action
        func handleReplace() {
            
        }
        
        func configureMediaPickerViewModel(_ pickerViewModel: MediaPicker.ViewModel) {
            pickerViewModel.onResultInformationObtain = { [weak self] resultInformation in
                guard let resultInformation = resultInformation else { return }
                
                self?.sendFile(at: resultInformation.filePath)
            }
        }
        
        /// Add observer to file picker
        ///
        /// - Parameters:
        ///   - pickerViewModel: Model with information about picked file
        func configureListening(_ pickerViewModel: BaseFilePickerViewModel) {
            pickerViewModel.$resultInformation.safelyUnwrapOptionals().sink { [weak self] (value) in
                self?.sendFile(at: value.filePath)
            }.store(in: &self.subscriptions)
        }
        
        private func downloadFile() {
            guard case let .file(file) = block.content else { return }
            switch file.contentType {
            case .image:
                return
            case .video, .file:
                URLResolver().obtainFileURLPublisher(fileId: file.metadata.hash)
                    .sink(
                        receiveCompletion: { _ in },
                        receiveValue: { [weak self] url in
                            guard let url = url else { return }
                            self?.router?.saveFile(fileURL: url)
                        }
                    )
                    .store(in: &self.subscriptions)
                
            case .none:
                return
            }
        }
        
        private func setupSubscribers() {
            let fileContentPublisher = block.didChangeInformationPublisher().map({ value -> File? in
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
                self?.fileResource = .init(
                    size: BlocksViewsFileSizeConverter.convert(size: Int(metadata.size)),
                    name: metadata.name,
                    mime: BlocksViewsFileMimeConverter.convert(mime: metadata.mime)
                )
            })
        }
        
        private func sendFile(at filePath: String) {
            actionHandler?.handleAction(.upload(filePath: filePath), model: block.blockModel)
        }
    }
}

// MARK: - UIView
extension Namespace {
    class TopUIKitEmptyView: UIView {
        
        struct Layout {
            var placeholderViewInsets: UIEdgeInsets = .init(top: 4, left: 0, bottom: 4, right: 0)
            var placeholderIconLeading: CGFloat = 12
            var placeholderLabelSpacing: CGFloat = 4
            var activityIndicatorTrailing: CGFloat = 18
        }
        
        struct Resource {
            var placeholderText: String = "Add link or Upload a file"
            var errorText: String = "Some error. Try again later"
            var uploadingText: String = "Uploading..."
            
            var imagePath: String = "TextEditor/Style/File/Empty/File"
        }
        
        var layout: Layout = .init()
        var resource: Resource = .init() {
            didSet {
                self.placeholderLabel.text = self.resource.placeholderText
                self.placeholderIcon.image = UIImage.init(named: self.resource.imagePath)
            }
        }
        
        // MARK: - Publishers
        private var subscription: AnyCancellable?
        @Published private var hasError: Bool = false
        
        // MARK: Views
        private var contentView: UIView!
        
        private var placeholderView: UIView!
        private var placeholderLabel: UILabel!
        private var placeholderIcon: UIImageView!
        
        private var activityIndicator: UIActivityIndicatorView!
        
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
        private func setup() {
            self.setupUIElements()
            self.addLayout()
        }
        
        // MARK: UI Elements
        private func setupUIElements() {
            self.setupEmptyView()
        }
        
        private func setupEmptyView() {
            self.translatesAutoresizingMaskIntoConstraints = false
            
            // TODO: Move colors to service or smt
            self.placeholderView = {
                let view = UIView()
                view.layer.borderWidth = 1
                view.layer.borderColor = UIColor(hexString: "#DFDDD0").cgColor
                view.layer.cornerRadius = 4
                view.translatesAutoresizingMaskIntoConstraints = false
                return view
            }()
            
            self.placeholderLabel = {
                let label = UILabel()
                label.text = self.resource.placeholderText
                label.textColor = UIColor(hexString: "#ACA996")
                label.translatesAutoresizingMaskIntoConstraints = false
                return label
            }()
            
            self.activityIndicator = {
                let loader = UIActivityIndicatorView()
                loader.color = UIColor(hexString: "#ACA996")
                loader.hidesWhenStopped = true
                loader.translatesAutoresizingMaskIntoConstraints = false
                return loader
            }()
            
            self.placeholderIcon = {
                let imageView = UIImageView()
                imageView.translatesAutoresizingMaskIntoConstraints = false
                imageView.image = UIImage.init(named: self.resource.imagePath)
                imageView.contentMode = .scaleAspectFit
                return imageView
            }()
            
            self.placeholderView.addSubview(placeholderLabel)
            self.placeholderView.addSubview(placeholderIcon)
            self.addSubview(placeholderView)
            self.addSubview(activityIndicator)
        }
                
        // MARK: Layout
        private func addLayout() {
            
            if let view = self.placeholderView, let superview = view.superview {
                NSLayoutConstraint.activate([
                    view.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: self.layout.placeholderViewInsets.left),
                    view.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -self.layout.placeholderViewInsets.right),
                    view.topAnchor.constraint(equalTo: superview.topAnchor, constant: self.layout.placeholderViewInsets.top),
                    view.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -self.layout.placeholderViewInsets.bottom)
                    
                ])
            }
            
            if let view = self.placeholderIcon, let superview = view.superview {
                NSLayoutConstraint.activate([
                    view.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: self.layout.placeholderIconLeading),
                    view.centerYAnchor.constraint(equalTo: superview.centerYAnchor),
                    view.widthAnchor.constraint(equalToConstant: view.intrinsicContentSize.width)
                ])
            }
            
            if let view = self.placeholderLabel, let superview = view.superview {
                NSLayoutConstraint.activate([
                    view.leadingAnchor.constraint(equalTo: self.placeholderIcon.trailingAnchor, constant: self.layout.placeholderLabelSpacing),
                    view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                    view.topAnchor.constraint(equalTo: superview.topAnchor),
                    view.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
                ])
            }
            
            if let view = self.activityIndicator, let superview = view.superview {
                NSLayoutConstraint.activate([
                    view.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -self.layout.activityIndicatorTrailing),
                    view.centerYAnchor.constraint(equalTo: superview.centerYAnchor),
                    view.widthAnchor.constraint(equalToConstant: view.intrinsicContentSize.width)
                ])
            }
            
        }
        
        // MARK: - Actions
        enum State {
            case empty
            case uploading
            case error
        }
        
        func change(state: State) {
            switch state {
            case .empty:
                self.placeholderLabel.text = self.resource.placeholderText
                self.activityIndicator.isHidden = true
                self.activityIndicator.stopAnimating()
            case .uploading:
                self.placeholderLabel.text = self.resource.uploadingText
                self.activityIndicator.isHidden = false
                self.activityIndicator.startAnimating()
            case .error:
                self.placeholderLabel.text = self.resource.errorText
                self.activityIndicator.isHidden = true
                self.activityIndicator.stopAnimating()
            }
        }
        
        // MARK: - Configurations
        
        func configured(_ stream: Published<Bool>) {
            self._hasError = stream
            self.subscription = self.$hasError.sink(receiveValue: { [weak self] (value) in
                if value {
                    self?.change(state: .error)
                }
                else {
                    self?.change(state: .uploading)
                }
            })
        }
        
        func configured(_ resource: Resource) {
            self.resource = resource
        }
    }
}
