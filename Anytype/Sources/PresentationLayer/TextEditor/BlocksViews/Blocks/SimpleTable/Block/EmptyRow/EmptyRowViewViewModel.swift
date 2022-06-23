import UIKit
import BlocksModels
import CoreGraphics

struct EmptyRowViewViewModel: SystemContentConfiguationProvider {
    var hashable: AnyHashable {
        [
            contextId,
            info.id,
            columnRowId
        ] as [AnyHashable]
    }

    init(
        contextId: BlockId,
        info: BlockInformation,
        columnRowId: BlockId,
        tablesService: BlockTableService,
        cursorManager: EditorCursorManager
    ) {
        self.contextId = contextId
        self.info = info
        self.columnRowId = columnRowId
        self.tablesService = tablesService
        self.cursorManager = cursorManager
    }

    private let contextId: BlockId
    private let info: BlockInformation
    private let columnRowId: BlockId
    private let tablesService: BlockTableService
    private let cursorManager: EditorCursorManager

    func didSelectRowInTableView(editorEditingState: EditorEditingState) {

    }

    func emptyRowConfiguration() -> EmptyRowConfiguration {
        EmptyRowConfiguration {
            tablesService.rowListFill(
                contextId: contextId,
                targetIds: [info.id]
            )

            cursorManager.blockFocus = .init(id: columnRowId, position: .beginning)
        }
    }

    func makeSpreadsheetConfiguration() -> UIContentConfiguration {
        emptyRowConfiguration().spreadsheetConfiguration(
            dragConfiguration: nil,
            styleConfiguration: .init(backgroundColor: .backgroundPrimary)
        )
    }

    func makeContentConfiguration(maxWidth: CGFloat) -> UIContentConfiguration {
        makeSpreadsheetConfiguration()
    }
}

struct EmptyRowConfiguration: BlockConfiguration {
    typealias View = EmptyRowView

    @EquatableNoop private(set) var action: () -> Void
}

final class EmptyRowView: UIView, BlockContentView {
    let button = UIButton()
    private var actionHandler: (() -> Void)?
    static var size: CGSize?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    func update(with configuration: EmptyRowConfiguration) {
        self.actionHandler = configuration.action
    }

    func setup() {
        if EmptyRowView.size == nil {
            let textView = TextBlockContentView(frame: .zero)
            let maxSize = CGSize(
                width: 170.0, // just non nil size
                height: .greatestFiniteMagnitude
            )
            EmptyRowView.size = textView.systemLayoutSizeFitting(
                maxSize,
                withHorizontalFittingPriority: .required,
                verticalFittingPriority: .fittingSizeLevel
            )
        }

        addSubview(button) {
            $0.pinToSuperview()
            $0.height.equal(to: EmptyRowView.size?.height ?? 15)
        }

        button.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
    }

    @objc func handleTap() {
        actionHandler?()
    }
}
