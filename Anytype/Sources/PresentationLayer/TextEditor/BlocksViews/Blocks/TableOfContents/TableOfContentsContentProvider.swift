import Foundation
import Combine
import BlocksModels

final class TableOfContentsContentProvider {
    
    private enum Constants {
        static let sortedHeaderStyles: [BlockText.Style] = [.header, .header2, .header3, .header4]
    }
    
    private let document: BaseDocumentProtocol
    private lazy var subscriptions = [AnyCancellable]()
    
    @Published private(set) var content: [TableOfContentItem] = []
    
    init(document: BaseDocumentProtocol) {
        self.document = document
        startUpdateContent()
    }
    
    // MARK: - Private
    
    private func startUpdateContent() {
        updateContent()
        document.updatePublisher.sink { [weak self] in
            self?.handleUpdate(updateResult: $0)
        }.store(in: &subscriptions)
    }
    
    private func handleUpdate(updateResult: DocumentUpdate) {
        switch updateResult {
        case let .blocks(updatedIds):
            for blockId in updatedIds {
                guard let info = document.infoContainer.get(id: blockId),
                      case let .text(content) = info.content,
                      Constants.sortedHeaderStyles.contains(content.contentType) else { continue }
                updateContent()
                break
            }
        case .dataSourceUpdate:
            updateContent()
        case .header, .changeType, .general, .syncStatus, .details:
            break
        }
    }
    
    private func updateContent() {
        let newContent = buildTableOfContents()
        guard newContent != content else { return }
        content = newContent
    }
    
    private func buildTableOfContents() -> [TableOfContentItem] {
        var hasHeader = [Bool](repeating: false, count: Constants.sortedHeaderStyles.count)
        
        var items = [TableOfContentItem]()
        for child in document.children {
            switch child.content {
            case let .text(content):
                guard let position = Constants.sortedHeaderStyles.firstIndex(of: content.contentType) else {
                    continue
                }
                let depth = hasHeader[0..<position].filter { $0 }.count
                hasHeader[position] = true
                for index in position+1..<hasHeader.count {
                    hasHeader[index] = false
                }
                items.append(TableOfContentItem(title: content.text, level: depth))
            default:
                break
            }
        }
        return items
    }
}
