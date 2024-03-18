import UIKit
import Combine
import Services

@MainActor
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
    private var tableBlockInfoProvider: BlockModelInfomationProvider

    @Published var widths = [CGFloat]()

    private var cancellables = [AnyCancellable]()

    init(
        document: BaseDocumentProtocol,
        tableBlockInfoProvider: BlockModelInfomationProvider,
        cellBuilder: SimpleTableCellsBuilder,
        stateManager: SimpleTableStateManagerProtocol,
        cursorManager: EditorCursorManager
    ) {
        self.document = document
        self.tableBlockInfoProvider = tableBlockInfoProvider
        self.cellBuilder = cellBuilder
        self.stateManager = stateManager
        self.cursorManager = cursorManager

        forceUpdate(shouldApplyFocus: false)
        stateManager.checkOpenedState()
        setupHandlers()
    }

    private func setupHandlers() {
        document.resetBlocksSubject.sink { [weak self] blockIds in
            guard let self else { return }
            
            let computedTable = ComputedTable(blockInformation: tableBlockInfoProvider.info, infoContainer: document.infoContainer)
            guard computedTable.isNotNil else { return }
            
            let allRelatedIds = [tableBlockInfoProvider.info.id] + document.infoContainer.recursiveChildren(of: tableBlockInfoProvider.info.id).map { $0.id }
            
            if Set(allRelatedIds).intersection(blockIds).count > 0 {
                forceUpdate(shouldApplyFocus: true)
                stateManager.checkOpenedState()
            }
        }.store(in: &cancellables)
    }

    private func updateDifference(newItems: [[EditorItem]]) {
        let newItems = cellBuilder.buildItems(from: tableBlockInfoProvider.info)

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
        let cells = cellBuilder.buildItems(from: tableBlockInfoProvider.info)
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

