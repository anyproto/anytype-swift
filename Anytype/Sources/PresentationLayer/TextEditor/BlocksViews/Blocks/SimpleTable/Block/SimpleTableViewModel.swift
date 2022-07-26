import UIKit
import Combine
import BlocksModels

final class SimpleTableViewModel {
    let stateManager: SimpleTableStateManagerProtocol
    weak var dataSource: SpreadsheetViewDataSource? {
        didSet {
            forceUpdate(shouldApplyFocus: true)
        }
    }

    private let document: BaseDocumentProtocol
    private let cellBuilder: SimpleTableCellsBuilder
    private let cursorManager: EditorCursorManager
    private var tableBlockInfo: BlockInformation

    @Published var widths = [CGFloat]()

    private var cancellables = [AnyCancellable]()

    init(
        document: BaseDocumentProtocol,
        tableBlockInfo: BlockInformation,
        cellBuilder: SimpleTableCellsBuilder,
        stateManager: SimpleTableStateManagerProtocol,
        cursorManager: EditorCursorManager
    ) {
        self.document = document
        self.tableBlockInfo = tableBlockInfo
        self.cellBuilder = cellBuilder
        self.stateManager = stateManager
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
        case .general, .details:
            forceUpdate(shouldApplyFocus: true)
        case .syncStatus, .header: break
        case .blocks(let blockIds):
            let container = document.infoContainer

            let allChilds = container.recursiveChildren(of: tableBlockInfo.id).map(\.id)
            guard blockIds.intersection(Set(allChilds)).isNotEmpty else {
                return
            }

            let newItems = cellBuilder.buildItems(from: tableBlockInfo)

           updateDifference(newItems: newItems)
        case .dataSourceUpdate:
            guard let newInfo = document.infoContainer.get(id: tableBlockInfo.id) else {
                return
            }
            tableBlockInfo = newInfo

            let cells = cellBuilder.buildItems(from: newInfo)

            dataSource?.allModels = cells
        }

        stateManager.checkDocumentLockField()
    }

    private func updateDifference(newItems: [[EditorItem]]) {
        let newItems = cellBuilder.buildItems(from: tableBlockInfo)

        var itemsToUpdate = [EditorItem]()
        zip(newItems, dataSource!.allModels).forEach { newSections, currentSections in
            zip(newSections, currentSections).forEach { newItem, currentItem in
                if newItem.hashValue != currentItem.hashValue {
                    itemsToUpdate.append(newItem)
                }
            }
        }

        dataSource?.update(changes: newItems.flatMap { $0 }, allModels: newItems)
    }

    private func forceUpdate(shouldApplyFocus: Bool) {
        guard let newInfo = document.infoContainer.get(id: tableBlockInfo.id) else {
            return
        }
        tableBlockInfo = newInfo

        let cells = cellBuilder.buildItems(from: newInfo)
        let numberOfColumns = cells.first?.count ?? 0

        let widths = [CGFloat](repeating: 170, count: numberOfColumns)

        if self.widths != widths { self.widths = widths }

        dataSource?.update(
            changes: cells.flatMap { $0 },
            allModels: cells
        )

        if shouldApplyFocus {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.cursorManager.applyCurrentFocus()
            }
        }
    }
}

