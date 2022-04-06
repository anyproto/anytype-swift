import UIKit


final class TextBlockIconView: UIView {
    
    enum ViewType {
        case titleCheckbox(isSelected: Bool)
        case checkbox(isSelected: Bool)
        case toggle(toggled: Bool)
        case numbered(Int)
        case bulleted
        case quote
        case empty
    }

    private var currentView: UIView?
    private let type: ViewType
    private let action: (() -> Void)?

    override var intrinsicContentSize: CGSize {
        currentView?.intrinsicContentSize ?? .zero
    }
    
    init(viewType: ViewType, action: (() -> Void)? = nil) {
        self.type = viewType
        self.action = action
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToSuperview() {
        guard superview != nil else { return }
        removeAllSubviews()
        addContentView()
    }
    
    private func addContentView() {
        switch type {
        case let .titleCheckbox(isSelected):
            let painer = ObjectIconImagePainter.shared
            let imageGuideline = ObjectIconImageUsecase.openedObject.objectIconImageGuidelineSet.todoImageGuideline
            
            let uncheckedImage: UIImage? = imageGuideline.flatMap {
                painer.todoImage(isChecked: false, imageGuideline: $0)
            }
            let checkedImage: UIImage? = imageGuideline.flatMap {
                painer.todoImage(isChecked: true, imageGuideline: $0)
            }
            
            currentView = createCheckboxView(
                isSelected: isSelected,
                uncheckedImage: uncheckedImage,
                checkedImage: checkedImage,
                viewSize: Constants.TitleCheckbox.viewSize,
                imageSize: Constants.TitleCheckbox.imageSize
            )
        case let .checkbox(isSelected):
            currentView = createCheckboxView(
                isSelected: isSelected,
                uncheckedImage: UIImage(
                    imageLiteralResourceName: Constants.Checkbox.uncheckedImageName
                ),
                checkedImage: UIImage(
                    imageLiteralResourceName: Constants.Checkbox.checkedImageName
                ),
                viewSize: Constants.size,
                imageSize: Constants.Checkbox.imageSize
            )
        case let .numbered(number):
            let numberedView = createNumberedView()
            currentView = numberedView
            numberedView.textAlignment = number >= Constants.Numbered.numberToPlaceTextLeft ? .left : .center
            numberedView.text = String(number) + "."
        case let .toggle(isToggled):
            let toggleView = createToggleView()
            currentView = toggleView
            toggleView.isSelected = isToggled
            let action = UIAction(handler: { [weak toggleView, weak self] reciver in
                toggleView?.isSelected.toggle()
                self?.action?()
            })
            toggleView.addAction(action, for: .touchUpInside)
        case .bulleted:
            currentView = createBulletedView()
        case .quote:
            let quoteView = createQuoteView()
            currentView = quoteView
        case .empty:
            setContentHuggingPriority(.required, for: .horizontal)
            return
        }
    }
}

extension TextBlockIconView {
    private func createToggleView() -> UIButton {
        let toggleButton = UIButton(type: .custom)

        let originalImage = UIImage(
            imageLiteralResourceName: Constants.Toggle.foldedImageName
        ).withTintColor(.textPrimary)

        let transformedImage = originalImage
            .rotate(radians: .pi/2)
            .withTintColor(.textPrimary)

        toggleButton.setImage(originalImage, for: .normal)
        toggleButton.setImage(transformedImage, for: .selected)
        toggleButton.contentMode = .center
        toggleButton.imageView?.contentMode = .scaleAspectFit

        addSubview(toggleButton)  {
            $0.width.equal(to: Constants.size.width)
            $0.height.equal(to: Constants.size.height)
            $0.leading.equal(to: leadingAnchor)
            $0.top.equal(to: topAnchor)
            $0.bottom.equal(to: bottomAnchor)
            $0.trailing.equal(to: trailingAnchor)
        }
        return toggleButton
    }

    private func createCheckboxView(
        isSelected: Bool,
        uncheckedImage: UIImage?,
        checkedImage: UIImage?,
        viewSize: CGSize,
        imageSize: CGSize
    ) -> UIButton {
        let checkboxView = UIButton()
        checkboxView.setImage(uncheckedImage, for: .normal)
        checkboxView.setImage(checkedImage, for: .selected)
        checkboxView.contentMode = .center
        checkboxView.isSelected = isSelected
        checkboxView.addAction(
            UIAction(
                handler: { [weak self] _ in
                    self?.action?()
                }
            ),
            for: .touchUpInside
        )

        addSubview(checkboxView) {
            $0.width.equal(to: viewSize.width)
            $0.height.equal(to: viewSize.height)
            $0.leading.equal(to: leadingAnchor)
            $0.top.equal(to: topAnchor)
            $0.bottom.equal(to: bottomAnchor)
            $0.trailing.equal(to: trailingAnchor)
        }
        return checkboxView
    }

    private func createNumberedView() -> UILabel {
        let numberedView = UILabel()
        numberedView.font = .bodyRegular
        numberedView.textAlignment = .center
        setContentHuggingPriority(.defaultLow + 1, for: .horizontal)

        addSubview(numberedView) {
            $0.centerX.equal(to: centerXAnchor)
            $0.centerY.equal(to: centerYAnchor)
        }
        layoutUsing.anchors {
            $0.width.greaterThanOrEqual(to: Constants.size.width)
            $0.height.equal(to: Constants.size.height)
        }
        return numberedView
    }

    private func createBulletedView() -> UIView {
        let label = UILabel()
        label.text = "•"
        label.font = .systemFont(ofSize: 30)
        label.textColor = .textPrimary

        addSubview(label) {
            $0.centerY.equal(to: centerYAnchor)
            $0.centerX.equal(to: centerXAnchor)
        }
        layoutUsing.anchors {
            $0.width.equal(to: Constants.size.width)
            $0.height.equal(to: Constants.size.height)
        }
        return label
    }

    private func createQuoteView() -> UIView {
        let quoteView = UIView()
        quoteView.backgroundColor = UIColor.System.amber

        addSubview(quoteView) {
            $0.width.equal(to: 2)
            $0.leading.equal(to: leadingAnchor, constant: 11)
            $0.top.equal(to: topAnchor)
            $0.bottom.equal(to: bottomAnchor)
        }
        layoutUsing.anchors {
            $0.width.equal(to: Constants.size.width, priority: .defaultHigh)
            if let superview = superview {
                $0.top.equal(to: superview.topAnchor, priority: .defaultHigh)
                $0.bottom.equal(to: superview.bottomAnchor)
            }
        }

        return quoteView
    }
}

private extension TextBlockIconView {
    private enum Constants {
        static let size = CGSize(width: 24, height: 24)

        enum Quote {
            static let viewWidth: CGFloat = 14
        }

        enum Bulleted {
            static let size: CGFloat = 6
            static let dotTopOffset: CGFloat = 11
        }

        enum TitleCheckbox {
            static let imageSize = CGSize(width: 28, height: 28)
            static let viewSize = CGSize(width: 28, height: 32) // height is equel to height of 1 line in text view
        }
        enum Checkbox {
            static let checkedImageName = "TextEditor/Text/checked"
            static let uncheckedImageName = "TextEditor/Text/unchecked"
            static let imageSize = CGSize(width: 18, height: 18)
        }

        enum Numbered {
            static let numberToPlaceTextLeft: Int = 20
        }

        enum Toggle {
            static let foldedImageName = "TextEditor/Text/folded"
        }
    }
}
