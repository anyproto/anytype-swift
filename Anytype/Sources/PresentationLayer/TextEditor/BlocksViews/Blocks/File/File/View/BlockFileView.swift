import UIKit
import Combine
import BlocksModels

class BlockFileView: UIView {
    init(fileData: BlockFile) {
        super.init(frame: .zero)
        
        setupUIElements()
        handle(fileData)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func handle(_ file: BlockFile) {
        switch file.state  {
        case .empty:
            emptyView.change(state: .empty)

            fileView.isHidden = true
            emptyView.isHidden = false
        case .uploading:
            emptyView.change(state: .uploading)

            fileView.isHidden = true
            emptyView.isHidden = false
        case .error:
            emptyView.change(state: .error)

            fileView.isHidden = true
            emptyView.isHidden = false
        case .done:
            let data = BlockFileMediaData(
                size: FileSizeConverter.convert(size: Int(file.metadata.size)),
                name: file.metadata.name,
                typeIcon: BlockFileIconBuilder.convert(mime: file.metadata.mime)
            )
            fileView.handleNewData(data: data)
            
            fileView.isHidden = false
            emptyView.isHidden = true
        }
    }
    
    // MARK: UI Elements
    private func setupUIElements() {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(fileView)
        self.addSubview(emptyView)
        
        
        addEmptyViewLayout()
        addFileViewLayout()
    }
    
    private func addFileViewLayout() {
        fileView.pinAllEdges(to: self, insets: Layout.fileViewInsets)
    }
    
    private func addEmptyViewLayout() {
        let heightAnchor = emptyView.heightAnchor.constraint(equalToConstant: Layout.emptyViewHeight)
        let bottomAnchor = emptyView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        // We need priotity here cause cell self size constraint will conflict with ours
        bottomAnchor.priority = .init(750)
        
        NSLayoutConstraint.activate([
            emptyView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            emptyView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            emptyView.topAnchor.constraint(equalTo: self.topAnchor),
            bottomAnchor,
            heightAnchor
        ])
    }
    
    private enum Layout {
        static let emptyViewHeight: CGFloat = 48
        static let fileViewInsets = UIEdgeInsets(top: 10, left: 0, bottom: -10, right: 0)
    }
    
    private let fileView: BlockFileMediaView = BlockFileMediaView()
    
    private let emptyView: BlocksFileEmptyView = {
        let view = BlocksFileEmptyView(
            viewData: .init(
                image: UIImage.blockFile.empty.file,
                placeholderText: "Upload a file"
            )
        )
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
}
