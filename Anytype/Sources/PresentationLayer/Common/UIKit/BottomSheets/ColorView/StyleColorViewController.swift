import UIKit
import BlocksModels

final class StyleColorViewController: UIViewController {
    // MARK: - Viwes

    private(set) var colorView: ColorView!

    // MARK: - Properties

    private let blockId: BlockId
    private var actionHandler: BlockActionHandlerProtocol
    private var viewDidCloseHandler: () -> Void

    // MARK: - Lifecycle

    /// Init style view controller
    /// - Parameter color: Foreground color
    /// - Parameter backgroundColor: Background color
    init(
        blockId: BlockId,
        color: UIColor = .textPrimary,
        backgroundColor: UIColor = .backgroundPrimary,
        actionHandler: BlockActionHandlerProtocol,
        viewDidClose: @escaping () -> Void
    ) {
        self.blockId = blockId
        self.actionHandler = actionHandler
        self.viewDidCloseHandler = viewDidClose

        super.init(nibName: nil, bundle: nil)

        colorView = ColorView(
            color: color,
            backgroundColor: backgroundColor,
            colorViewSelectedAction: { [weak actionHandler] colorItem in
                switch colorItem {
                case .text(let blockColor):
                    actionHandler?.setTextColor(blockColor, blockId: blockId)
                case .background(let blockBackgroundColor):
                    actionHandler?.setBackgroundColor(blockBackgroundColor, blockId: blockId)
                }
            },
            viewDidClose: { [weak self] in
                self?.removeFromParentEmbed()
                self?.viewDidCloseHandler()
            })
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
    }

    private func setupViews() {
        view.addSubview(colorView) {
            $0.pinToSuperview()
        }
    }
}
