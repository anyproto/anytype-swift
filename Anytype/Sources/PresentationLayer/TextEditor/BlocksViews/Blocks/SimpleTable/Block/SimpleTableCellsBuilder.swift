import UIKit
import Services
import AnytypeCore


@MainActor
final class SimpleTableCellsBuilder {
    private let document: any BaseDocumentProtocol
    private let router: any EditorRouterProtocol
    private let handler: any BlockActionHandlerProtocol
    private let pasteboardService: any PasteboardBlockDocumentServiceProtocol
    private let markdownListener: any MarkdownListener
    private let cursorManager: EditorCursorManager
    private let focusSubjectHolder: FocusSubjectsHolder
    private let infoContainer: any InfoContainerProtocol
    private let blockTableService: any BlockTableServiceProtocol
    private let responderScrollViewHelper: ResponderScrollViewHelper
    private let stateManager: SimpleTableStateManager
    private let blockMarkupChanger: any BlockMarkupChangerProtocol
    private let accessoryStateManager: any AccessoryViewStateManager
    private weak var moduleOutput: (any EditorPageModuleOutput)?
    
    private var textBlocksMapping = [String: EditorItem]()
    private var emptyBlocksMapping = [String: EditorItem]()
    
    init(
        document: some BaseDocumentProtocol,
        router: some EditorRouterProtocol,
        handler: some BlockActionHandlerProtocol,
        pasteboardService: some PasteboardBlockDocumentServiceProtocol,
        markdownListener: some MarkdownListener,
        cursorManager: EditorCursorManager,
        focusSubjectHolder: FocusSubjectsHolder,
        responderScrollViewHelper: ResponderScrollViewHelper,
        stateManager: SimpleTableStateManager,
        accessoryStateManager: some AccessoryViewStateManager,
        blockMarkupChanger: some BlockMarkupChangerProtocol,
        blockTableService: some BlockTableServiceProtocol,
        moduleOutput: (any EditorPageModuleOutput)?
    ) {
        self.document = document
        self.router = router
        self.handler = handler
        self.pasteboardService = pasteboardService
        self.markdownListener = markdownListener
        self.cursorManager = cursorManager
        self.focusSubjectHolder = focusSubjectHolder
        self.infoContainer = document.infoContainer
        self.responderScrollViewHelper = responderScrollViewHelper
        self.stateManager = stateManager
        self.blockMarkupChanger = blockMarkupChanger
        self.blockTableService = blockTableService
        self.accessoryStateManager = accessoryStateManager
        self.moduleOutput = moduleOutput
    }
    
    func buildItems(
        from info: BlockInformation
    ) -> [[EditorItem]] {
        guard let computedTable = ComputedTable(blockInformation: info, infoContainer: infoContainer) else {
            return []
        }
        
        return buildModels(computedTable: computedTable)
    }
    
    private func buildModels(computedTable: ComputedTable) -> [[EditorItem]] {
        return computedTable.cells.map {
            $0.map { item in
                guard let blockInformation = item.blockInformation else {
                    return makeEmptyContentCellConfiguration(columnId: item.columnId, rowId: item.rowId, isHeaderRow: item.isHeaderRow)
                }
                switch item.blockInformation?.content {
                case let .text(content):
                    return textBlockConfiguration(information: blockInformation, content: content, table: computedTable, isHeaderRow: item.isHeaderRow)
                default:
                    anytypeAssertionFailure("Wrong path")
                    return makeEmptyContentCellConfiguration(columnId: item.columnId, rowId: item.rowId, isHeaderRow: item.isHeaderRow)
                }
            }
        }
    }
    
    private func makeEmptyContentCellConfiguration(
        columnId: String,
        rowId: String,
        isHeaderRow: Bool
    ) -> EditorItem {
         .system(
            EmptyRowViewViewModel(
                contextId: document.objectId,
                rowId: rowId,
                columnId: columnId,
                tablesService: blockTableService,
                cursorManager: cursorManager,
                isHeaderRow: isHeaderRow
            )
        )
    }
    
    private func textBlockConfiguration(
        information: BlockInformation,
        content: BlockText,
        table: ComputedTable,
        isHeaderRow: Bool
    ) -> EditorItem {
        if let textBlock = textBlocksMapping[information.id] {
            return textBlock
        }
        
        let textBlockActionHandler = SimpleTablesTextBlockActionHandler(
            document: document,
            info: information,
            focusSubject: focusSubjectHolder.focusSubject(for: information.id),
            actionHandler: handler,
            pasteboardService: pasteboardService,
            markdownListener: markdownListener,
            cursorManager: cursorManager,
            accessoryViewStateManager: accessoryStateManager,
            markupChanger: blockMarkupChanger,
            responderScrollViewHelper: responderScrollViewHelper,
            showObject: { [weak self] objectId in
                self?.router.showObject(objectId: objectId)
            },
            openURL: { [weak moduleOutput] url in
                moduleOutput?.openUrl(url)
            },
            onShowStyleMenu: { [weak stateManager] info in
                Task { @MainActor [weak stateManager] in
                    stateManager?.didSelectStyleSelection(infos: [info])
                }
            },
            onEnterSelectionMode: { [weak stateManager] info in
                Task { @MainActor [weak stateManager] in
                    stateManager?.didSelectEditingState(info: info)
                }
            },
            onSelectUndoRedo: { [weak self] in
                self?.moduleOutput?.didUndoRedo()
            },
            showTextIconPicker: { [weak router, weak document] in
                guard let router, let document else { return }
                router.showTextIconPicker(
                    contextId: document.objectId,
                    objectId: information.id
                )
            },
            showWaitingView: { [weak router] text in
                router?.showWaitingView(text: text)
            },
            hideWaitingView: {  [weak router] in
                router?.hideWaitingView()
            },
            onKeyboardAction: { [weak self] action in
                self?.handleKeyboardAction(table: table, block: information, action: action)
            }
        )
        
        let textBlockViewModel = TextBlockViewModel(
            document: document,
            blockInformationProvider: BlockModelInfomationProvider(document: document, info: information),
            actionHandler: textBlockActionHandler,
            cursorManager: cursorManager
        )
        
        textBlocksMapping[information.id] = .block(textBlockViewModel)

        return EditorItem.block(textBlockViewModel)
    }
    
    private func handleKeyboardAction(table: ComputedTable, block: BlockInformation, action: CustomTextView.KeyboardAction) {
        guard let newComputedTable = ComputedTable(blockInformation: table.info, infoContainer: infoContainer) else {
            return
        }
        
        switch action {
        case .delete:
            guard let indexPath = newComputedTable.cells.indexPaths(for: block),
                  let newFocusingCell = newComputedTable.cells[safe: (indexPath.section - 1)]?[safe: indexPath.row]
            else { return }
            
            focus(on: newFocusingCell, position: .end)
        case .enterAtTheBegining, .enterAtTheEnd, .enterForEmpty, .enterInside:
            guard let indexPath = newComputedTable.cells.indexPaths(for: block),
                  let newFocusingCell = newComputedTable.cells[safe: (indexPath.section + 1)]?[safe: indexPath.row]
            else { return }
            
            focus(on: newFocusingCell, position: .end)
        }
    }
    
    private func focus(on cell: ComputedTable.Cell, position: BlockFocusPosition) {
        if let blockInformation = cell.blockInformation {
            cursorManager.focus(at: blockInformation.id, position: position)
        } else {
            Task { @MainActor in
                try await blockTableService.rowListFill(
                    contextId: document.objectId,
                    targetIds: [cell.rowId]
                )
                
                cursorManager.blockFocus = BlockFocus(id: "\(cell.rowId)-\(cell.columnId)", position: .beginning)
            }
        }
    }
}

struct ComputedTable {
    struct Cell {
        var blockId: String { "\(rowId)-\(columnId)" }
        let rowId: String
        let columnId: String
        let isHeaderRow: Bool
        let blockInformation: BlockInformation?
    }
    
    let info: BlockInformation
    let cells: [[Cell]]
    
    private init?(
        info: BlockInformation,
        infoContainer: some InfoContainerProtocol,
        tableColumnsBlockInfo: BlockInformation,
        tableRowsBlockInfo: BlockInformation
    ) {
        let numberOfColumns = tableColumnsBlockInfo.childrenIds.count
        var blocks = [[Cell]]()
        
        for rowId in tableRowsBlockInfo.childrenIds {
            guard let childInformation = infoContainer.get(id: rowId) else {
                anytypeAssertionFailure("Missing column or rows information")
                return nil
            }
            
            if case let .tableRow(tableRow) = childInformation.content {
                var rowBlocks = [Cell]()
                
                for columnIndex in 0..<numberOfColumns {
                    let columnId = tableColumnsBlockInfo.childrenIds[columnIndex]
                    
                    let child = infoContainer.get(id: "\(rowId)-\(columnId)")
                    let cell = Cell(rowId: rowId, columnId: columnId, isHeaderRow: tableRow.isHeader, blockInformation: child)
                    rowBlocks.append(cell)
                }
                
                blocks.append(rowBlocks)
            }
        }
        
        self.cells = blocks
        self.info = info
    }
}

extension ComputedTable {
    init?(blockInformation: BlockInformation, infoContainer: any InfoContainerProtocol) {
        guard let newBlockInformation = infoContainer.get(id: blockInformation.id) else { return nil }
        var tableColumnsBlockInfo: BlockInformation?
        var tableRowsBlockInfo: BlockInformation?
        
        for childId in newBlockInformation.childrenIds {
            guard let childInformation = infoContainer.get(id: childId) else {
                anytypeAssertionFailure("Can't find child of table view")
                return nil
            }
            
            if childInformation.content == .layout(.init(style: .tableRows)) {
                tableRowsBlockInfo = childInformation
            } else if childInformation.content == .layout(.init(style: .tableColumns)) {
                tableColumnsBlockInfo = childInformation
            }
        }
        
        guard let tableColumnsBlockInfo = tableColumnsBlockInfo,
              let tableRowsBlockInfo = tableRowsBlockInfo else {
            anytypeAssertionFailure("Missing column or rows information")
            return nil
        }
        
        self.init(info: blockInformation, infoContainer: infoContainer, tableColumnsBlockInfo: tableColumnsBlockInfo, tableRowsBlockInfo: tableRowsBlockInfo)
    }
}

extension ComputedTable {
    var allColumnIds: [String] {
        cells.first?.compactMap { $0.columnId } ?? []
    }
    
    var allRowIds: [String] {
        cells.compactMap {
            $0.first.map { $0.rowId }
        }
    }
}

extension UIColor {
    static var headerRowColor: UIColor {
        UIColor(hexString: "#353a3a").withAlphaComponent(0.3)
    }
}
