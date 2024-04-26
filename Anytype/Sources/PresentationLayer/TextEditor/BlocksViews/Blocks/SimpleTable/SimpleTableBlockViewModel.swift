import Services
import Combine
import UIKit
import AnytypeCore

final class SimpleTableBlockViewModel: BlockViewModelProtocol {

    let info: BlockInformation

    var hashable: AnyHashable {
        info.id as AnyHashable
    }

    private let dependenciesBuilder: SimpleTableDependenciesBuilder
    private let infoContainer: InfoContainerProtocol
    private let tableService: BlockTableServiceProtocol
    private let document: BaseDocumentProtocol
    
    private var store = [AnyCancellable]()

    init(
        info: BlockInformation,
        simpleTableDependenciesBuilder: SimpleTableDependenciesBuilder,
        infoContainer: InfoContainerProtocol,
        tableService: BlockTableServiceProtocol,
        document: BaseDocumentProtocol,
        focusSubject: PassthroughSubject<BlockFocusPosition, Never> // Not proper way to handle focus. Need to refactor EditorCursorManager
    ) {
        self.info = info
        self.dependenciesBuilder = simpleTableDependenciesBuilder
        self.infoContainer = infoContainer
        self.tableService = tableService
        self.document = document
        
        focusSubject.sink { [weak self] position in
            self?.set(focus: position)
        }.store(in: &store)
    }

    func makeContentConfiguration(maxWidth: CGFloat) -> UIContentConfiguration {
        SimpleTableBlockContentConfiguration(
            info: info,
            dependenciesBuilder: dependenciesBuilder
        ).cellBlockConfiguration(indentationSettings: nil, dragConfiguration: nil)
    }

    func didSelectRowInTableView(editorEditingState: EditorEditingState) {}
    
    func set(focus: BlockFocusPosition) {
        guard let computedTable = ComputedTable(blockInformation: info, infoContainer: infoContainer),
              let firstRowId = computedTable.allRowIds.first,
              let firstColumnId = computedTable.allColumnIds.first  else {
            return
        }
        
        Task { @MainActor in
            try await tableService.rowListFill(
                contextId: document.objectId,
                targetIds: [firstRowId]
            )
            
            dependenciesBuilder.cursorManager.blockFocus = .init(
                id: "\(firstRowId)-\(firstColumnId)",
                position: .beginning
            )
        }
    }
}
