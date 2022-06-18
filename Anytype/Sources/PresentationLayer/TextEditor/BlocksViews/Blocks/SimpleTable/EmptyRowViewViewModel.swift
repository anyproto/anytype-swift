import UIKit
import BlocksModels
import CoreGraphics

struct EmptyRowViewViewModel {
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

    func emptyRowConfiguration() -> EmptyRowConfiguration {
        EmptyRowConfiguration {
            tablesService.rowListFill(
                contextId: contextId,
                targetIds: [info.id]
            )

            cursorManager.blockFocus = .init(id: columnRowId, position: .beginning)
        }
    }
}

struct EmptyRowConfiguration: BlockConfiguration {
    typealias View = EmptyRowView

    @EquatableNoop private(set) var action: () -> Void
}

final class EmptyRowView: UIView, BlockContentView {
    private var actionHandler: (() -> Void)?

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

    static var size: CGSize?

    func setup() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))

        addGestureRecognizer(tapGestureRecognizer)

        translatesAutoresizingMaskIntoConstraints = false

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

        let constraint = heightAnchor.constraint(equalToConstant: EmptyRowView.size?.height ?? 15)
        
        constraint.isActive = true
    }

    @objc func handleTap() {
        actionHandler?()
    }
}
