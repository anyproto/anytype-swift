import UIKit
import Combine
import BlocksModels

class BlocksViewsFileUIKitView: UIView {
    struct Layout {
        var imageContentViewDefaultHeight: CGFloat = 250
        var imageViewTop: CGFloat = 4
        var emptyViewHeight: CGFloat = 52
        let fileViewInsets = UIEdgeInsets(top: 10, left: 0, bottom: -10, right: 0)
    }
    
    var subscription: AnyCancellable?
    
    var layout: Layout = .init()
    
    // MARK: Views
    var contentView: UIView!
    var fileView: BlocksViewsFileUIKitViewWithFile!
    var emptyView: BlocksViewsBaseFileTopUIKitEmptyView!
            
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
            let view = BlocksViewsFileUIKitViewWithFile()
            view.layer.borderWidth = 1
            view.layer.borderColor = UIColor(hexString: "#DFDDD0").cgColor
            view.layer.cornerRadius = 4
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
        
        self.emptyView = {
            let view = BlocksViewsBaseFileTopUIKitEmptyView(
                viewData: .init(
                    image: UIImage.blockFile.empty.file,
                    placeholderText: "Add link or upload a file"
                )
            )
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
            view.pinAllEdges(to: superview, insets: layout.fileViewInsets)
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
                    
    private func handle(_ file: BlockFile) {
        
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
            
    func configured(publisher: AnyPublisher<BlockFile, Never>) -> Self {
        self.subscription = publisher.receiveOnMain().sink { [weak self] (value) in
            self?.handle(value)
        }
        return self
    }
    
    func configured(published: AnyPublisher<BlocksViewsFileUIKitViewWithFile.Resource?, Never>) -> Self {
        self.fileView.configured(published)
        return self
    }
}

extension BlocksViewsFileUIKitView {
    func process(_ file: BlockFile) {
        self.handle(file)
    }
    
    func process(_ resource: BlocksViewsFileUIKitViewWithFile.Resource?) {
        self.fileView.handle(resource)
    }
    func apply(_ file: BlockFile) {
        self.process(file)
        let resource: BlocksViewsFileUIKitViewWithFile.Resource?
        switch file.contentType {
        case .file:
            let metadata = file.metadata
            resource = .init(
                size: BlocksViewsFileSizeConverter.convert(size: Int(metadata.size)),
                name: metadata.name,
                typeIcon: BlocksViewsFileMimeConverter.convert(mime: metadata.mime)
            )
        default: resource = nil
        }
        self.process(resource)
    }
}
