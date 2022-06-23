import BlocksModels
import Combine
import UIKit
import AnytypeCore

struct SimpleTableBlockViewModel: BlockViewModelProtocol {

    let info: BlockInformation

    var hashable: AnyHashable {
        info.id as AnyHashable
    }

    private weak var blockDelegate: BlockDelegate?
    private let simpleTableViewModelBuilder: () -> SimpleTableViewModel
    private weak var relativePositionProvider: RelativePositionProvider?

    init(
        document: BaseDocumentProtocol,
        info: BlockInformation,
        cellsBuilder: SimpleTableCellsBuilder,
        blockDelegate: BlockDelegate,
        cursorManager: EditorCursorManager,
        relativePositionProvider: RelativePositionProvider?
    ) {
        self.info = info
        self.blockDelegate = blockDelegate
        self.relativePositionProvider = relativePositionProvider
        self.simpleTableViewModelBuilder = { SimpleTableViewModel(
            document: document,
            tableBlockInfo: info,
            cellBuilder: cellsBuilder,
            cursorManager: cursorManager
            )
        }
    }

    func makeContentConfiguration(maxWidth: CGFloat) -> UIContentConfiguration {
        let contentConfiguration = SimpleTableBlockContentConfiguration(
            blockDelegate: blockDelegate,
            relativePositionProvider: relativePositionProvider,
            viewModelBuilder: simpleTableViewModelBuilder
        )

        return CellBlockConfiguration(
            blockConfiguration: contentConfiguration,
            indentationSettings: nil,
            dragConfiguration: nil
        )
    }

    func didSelectRowInTableView(editorEditingState: EditorEditingState) {}
}
