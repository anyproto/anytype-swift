import UIKit
import Services
import CoreGraphics

struct EmptyRowViewViewModel: SystemContentConfiguationProvider {
    var hashable: AnyHashable {
        "\(rowId) - \(columnId)"
    }

    init(
        contextId: BlockId,
        rowId: BlockId,
        columnId: BlockId,
        tablesService: BlockTableServiceProtocol,
        cursorManager: EditorCursorManager,
        isHeaderRow: Bool
    ) {
        self.contextId = contextId
        self.rowId = rowId
        self.columnId = columnId
        self.tablesService = tablesService
        self.cursorManager = cursorManager
        self.isHeaderRow = isHeaderRow
    }

    private let contextId: BlockId
    private let rowId: BlockId
    private let columnId: BlockId
    private let tablesService: BlockTableServiceProtocol
    private let cursorManager: EditorCursorManager
    private let isHeaderRow: Bool

    func didSelectRowInTableView(editorEditingState: EditorEditingState) {

    }

    func emptyRowConfiguration() -> EmptyRowConfiguration {
        EmptyRowConfiguration(id: "\(rowId)-\(columnId)") {
            fillAndSetFocus()
        }
    }

    func makeSpreadsheetConfiguration() -> UIContentConfiguration {
        emptyRowConfiguration().spreadsheetConfiguration(
            dragConfiguration: nil,
            styleConfiguration: .init(backgroundColor: isHeaderRow ? UIColor.headerRowColor : .Background.primary)
        )
    }

    func makeContentConfiguration(maxWidth: CGFloat) -> UIContentConfiguration {
        makeSpreadsheetConfiguration()
    }

    func set(focus: BlockFocusPosition) {
        fillAndSetFocus()
    }

    private func fillAndSetFocus() {
        Task { @MainActor in
            try await tablesService.rowListFill(
                contextId: contextId,
                targetIds: [rowId]
            )
            
            cursorManager.blockFocus = .init(id: "\(rowId)-\(columnId)", position: .beginning)
        }
    }
}

struct EmptyRowConfiguration: BlockConfiguration {
    typealias View = EmptyRowView

    let id: BlockId

    @EquatableNoop private(set) var action: () -> Void

    var spreadsheetInsets: UIEdgeInsets { .zero }
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

    func update(with state: UICellConfigurationState) {
        button.isHidden = state.isLocked
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
            ) + .init(width: 0, height: 18) // Spreadsheet top and bottom insets
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
