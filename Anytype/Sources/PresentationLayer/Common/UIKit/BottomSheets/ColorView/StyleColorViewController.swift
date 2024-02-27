import UIKit
import Services

final class StyleColorViewController: UIViewController {
    // MARK: - Viwes

    private(set) var colorView: ColorView!

    // MARK: - Properties
    private var viewDidCloseHandler: (UIViewController) -> Void

    // MARK: - Lifecycle

    /// Init style view controller
    /// - Parameter color: Foreground color
    /// - Parameter backgroundColor: Background color
    init(
        selectedColor: UIColor?,
        selectedBackgroundColor: UIColor?,
        onColorSelection: @escaping (ColorView.ColorItem) -> Void,
        viewDidClose: @escaping (UIViewController) -> Void
    ) {
        self.viewDidCloseHandler = viewDidClose

        super.init(nibName: nil, bundle: nil)

        colorView = ColorView(
            colorViewSelectedAction: onColorSelection,
            viewDidClose: { [weak self] in
                self?.removeFromParentEmbed()
                self.map { self?.viewDidCloseHandler($0) }
            })
        
        colorView.selectedTextColor = selectedColor
        colorView.selectedBackgroundColor = selectedBackgroundColor
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
