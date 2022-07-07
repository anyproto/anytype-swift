import BlocksModels
import UIKit
import AnytypeCore

final class SimpleTableViewModelBuilder {
    private let document: BaseDocumentProtocol
    private let router: EditorRouterProtocol
    private let handler: BlockActionHandlerProtocol
    private let pasteboardService: PasteboardServiceProtocol
    private let delegate: BlockDelegate
    private let markdownListener: MarkdownListener
    private let cursorManager: EditorCursorManager
    private let focusSubjectHolder: FocusSubjectsHolder
    private let stateManager: SimpleTableStateManager

    private weak var relativePositionProvider: RelativePositionProvider?

    init(
        document: BaseDocumentProtocol,
        router: EditorRouterProtocol,
        handler: BlockActionHandlerProtocol,
        pasteboardService: PasteboardServiceProtocol,
        delegate: BlockDelegate,
        markdownListener: MarkdownListener,
        relativePositionProvider: RelativePositionProvider?,
        cursorManager: EditorCursorManager,
        focusSubjectHolder: FocusSubjectsHolder,
        stateManager: SimpleTableStateManager
    ) {
        self.document = document
        self.router = router
        self.handler = handler
        self.pasteboardService = pasteboardService
        self.delegate = delegate
        self.markdownListener = markdownListener
        self.relativePositionProvider = relativePositionProvider
        self.cursorManager = cursorManager
        self.focusSubjectHolder = focusSubjectHolder
        self.stateManager = stateManager
    }

    func buildViewModel(from tableInfo: BlockInformation) -> SimpleTableBlockViewModel {
        let viewModel = SimpleTableBlockViewModel(
            document: document,
            info: tableInfo,
            cellsBuilder: .init(
                document: document,
                router: router,
                handler: handler,
                pasteboardService: pasteboardService,
                delegate: delegate,
                markdownListener: markdownListener,
                cursorManager: cursorManager,
                focusSubjectHolder: focusSubjectHolder
            ),
            blockDelegate: delegate,
            cursorManager: cursorManager,
            stateManager: stateManager,
            relativePositionProvider: relativePositionProvider
        )

        stateManager.tableBlockInformation = tableInfo

        return viewModel
    }
}
