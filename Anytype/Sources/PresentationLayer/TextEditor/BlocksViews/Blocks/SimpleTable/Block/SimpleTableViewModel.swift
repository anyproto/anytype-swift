import UIKit
import Combine
import BlocksModels

final class SimpleTableViewModel {
    private let document: BaseDocumentProtocol
    private let cellBuilder: SimpleTableCellsBuilder
    private let cursorManager: EditorCursorManager
    private var tableBlockInfo: BlockInformation

    @Published var cells = [[SimpleTableBlockProtocol]]()
    @Published var widths = [CGFloat]()
    var onDataSourceUpdate: (([[SimpleTableBlockProtocol]]) -> Void)?

    private var cancellables = [AnyCancellable]()

    init(
        document: BaseDocumentProtocol,
        tableBlockInfo: BlockInformation,
        cellBuilder: SimpleTableCellsBuilder,
        cursorManager: EditorCursorManager
    ) {
        self.document = document
        self.tableBlockInfo = tableBlockInfo
        self.cellBuilder = cellBuilder
        self.cursorManager = cursorManager

        forceUpdate(shouldApplyFocus: false)
        setupHandlers()
    }

    private func setupHandlers() {
        document.updatePublisher.sink { [weak self] update in
            self?.handleUpdate(update: update)
        }.store(in: &cancellables)
    }

    private func handleUpdate(update: DocumentUpdate) {
        switch update {
        case .general:
            forceUpdate(shouldApplyFocus: true)
        case .details, .syncStatus, .header, .changeType: break
        case .blocks(let blockIds):
            let container = document.infoContainer
            let allChilds = container.recursiveChildren(of: tableBlockInfo.id).map(\.id)


            if blockIds.intersection(Set(allChilds)).isNotEmpty {
                forceUpdate(shouldApplyFocus: true)
            }
        case .dataSourceUpdate:
            guard let newInfo = document.infoContainer.get(id: tableBlockInfo.id) else {
                return
            }
            tableBlockInfo = newInfo

            let cells = cellBuilder.buildItems(from: newInfo)
            
            onDataSourceUpdate?(cells)
        }
    }

    private func forceUpdate(shouldApplyFocus: Bool) {
        guard let newInfo = document.infoContainer.get(id: tableBlockInfo.id) else {
            return
        }
        tableBlockInfo = newInfo

        let cells = cellBuilder.buildItems(from: newInfo)
        let numberOfColumns = cells.first?.count ?? 0

        var widths = [CGFloat]()
        for _ in 0..<numberOfColumns {
            widths.append(170)
        }

        if self.widths != widths {
            self.widths = widths
        }

        self.cells = cells

        if shouldApplyFocus {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.cursorManager.applyCurrentFocus()
            }

        }
    }
}

