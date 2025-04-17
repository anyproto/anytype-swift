import Foundation
import Combine
import Services

final class TableOfContentsContentProvider {
    
    // MARK: - Private properties
    
    private enum Constants {
        static let sortedHeaderStyles: [BlockText.Style] = [.header, .header2, .header3, .header4]
    }
    
    private let document: any BaseDocumentProtocol
    private lazy var subscriptions = [AnyCancellable]()
    private lazy var blockSubscriptions = [String: AnyCancellable]()
    
    // MARK: - Public properties
    
    @Published private(set) var content: TableOfContentData = .empty("")
    
    init(document: some BaseDocumentProtocol) {
        self.document = document
        startUpdateContent()
    }
    
    // MARK: - Private
    
    private func startUpdateContent() {
        updateContent()
        
        document.flattenBlockIds.receiveOnMain().sink { [weak self] _ in
            self?.updateContent()
        }.store(in: &subscriptions)
        
        document.resetBlocksPublisher.receiveOnMain().sink { [weak self] _ in
            self?.updateContent()
        }.store(in: &subscriptions)
    }
    
    private func updateContent() {
        // Remove all subscriptions
        let newContent = buildTableOfContents()
//        guard newContent != content else { return }
        content = newContent
    }
    
    private func buildTableOfContents() -> TableOfContentData {
        var hasHeader = [Bool](repeating: false, count: Constants.sortedHeaderStyles.count)
        blockSubscriptions.removeAll()
        
        var items = [TableOfContentItem]()
        for child in document.children {
            switch child.content {
            case let .text(content):
                guard let position = Constants.sortedHeaderStyles.firstIndex(of: content.contentType) else {
                    continue
                }
                
                // Subscription on infocontainer child
                let depth = hasHeader[0..<position].filter { $0 }.count
                hasHeader[position] = true
                for index in position+1..<hasHeader.count {
                    hasHeader[index] = false
                }
                let title = content.text.withPlaceholder
                let item = TableOfContentItem(blockId: child.id, title: title, level: depth)
                setupSubsriptionFor(item: item)
                items.append(item)
            default:
                break
            }
        }
        
        if items.isEmpty {
            return .empty(Loc.TalbeOfContents.empty)
        } else {
            return .items(items)
        }
    }
    
    private func setupSubsriptionFor(item: TableOfContentItem) {
        blockSubscriptions[item.blockId] = document.subscribeForBlockInfo(blockId: item.blockId)
            .receiveOnMain().sink { [weak item] information in
                item?.title = information.textContent?.text ?? Loc.untitled
        }
    }
}
