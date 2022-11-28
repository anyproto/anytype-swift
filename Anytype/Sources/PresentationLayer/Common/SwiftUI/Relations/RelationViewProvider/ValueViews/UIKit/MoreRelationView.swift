import UIKit

final class MoreRelationView: UIView {
    let count: Int

    private var textView: AnytypeLabel!

    init(count: Int) {
        self.count = count

        super.init(frame: .zero)

        setupView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    override var intrinsicContentSize: CGSize {
        CGSize(width: textView.intrinsicContentSize.width + Constants.padding * 2, height: textView.intrinsicContentSize.height)
    }

    private func setupView() {
        backgroundColor = .strokeTertiary

        layer.cornerCurve = .continuous
        layer.cornerRadius = Constants.cornerRadius

        textView = AnytypeLabel(style: .relation2Regular)
        textView.setText("+\(count)")
        textView.textColor = .textSecondary

        addSubview(textView) {
            $0.pinToSuperview(insets: UIEdgeInsets(top: 0, left: Constants.padding, bottom: 0, right: Constants.padding))
        }
    }
}

extension MoreRelationView {
    enum Constants {
        static let padding: CGFloat = 4
        static let cornerRadius: CGFloat = 3
    }
}
