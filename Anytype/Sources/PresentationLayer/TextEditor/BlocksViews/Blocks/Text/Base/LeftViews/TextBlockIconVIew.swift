//
//  TextBlockIconVIew.swift
//  Anytype
//
//  Created by Denis Batvinkin on 22.06.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import UIKit


final class TextBlockIconVIew: UIView {
    enum ViewType {
        case checkbox(isSelected: Bool)
        case toggle(toggled: Bool)
        case numbered(Int)
        case bulleted
        case quote
        case empty
    }

    private var currentView: UIView?

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        currentView?.intrinsicContentSize ?? .zero
    }

    func showView(as viewType: ViewType, action: (() -> Void)? = nil) {
        isHidden = false
        removeAllSubviews()

        switch viewType {
        case let .checkbox(isSelected):
            let checkboxView = createCheckboxView()
            currentView = checkboxView
            checkboxView.isSelected = isSelected
            checkboxView.addAction(UIAction(handler: { [weak checkboxView] _ in
                checkboxView?.isSelected.toggle()
                action?()
            }), for: .touchUpInside)
        case let .numbered(number):
            let numberedView = createNumberedView()
            currentView = numberedView
            numberedView.textAlignment = number >= Constants.Numbered.numberToPlaceTextLeft ? .left : .center
            numberedView.text = String(number) + "."
        case let .toggle(isToggled):
            let toggleView = createToggleView()
            currentView = toggleView
            toggleView.isSelected = isToggled
            let action = UIAction(handler: { [weak toggleView] reciver in
                toggleView?.isSelected.toggle()
                action?()
            })
            toggleView.addAction(action, for: .touchUpInside)
        case .bulleted:
            let bulletedView = createBulletedView()
            currentView = bulletedView
        case .quote:
            let quoteView = createQuoteView()
            currentView = quoteView
        case .empty:
            isHidden = true
            return
        }
    }
}

extension TextBlockIconVIew {
    private func createToggleView() -> UIButton {
        let toggleView = UIButton()
        toggleView.setImage(UIImage(imageLiteralResourceName: Constants.Toggle.foldedImageName), for: .normal)
        toggleView.setImage(UIImage(imageLiteralResourceName: Constants.Toggle.unfoldedImageName), for: .selected)
        toggleView.contentMode = .center
        toggleView.imageView?.contentMode = .scaleAspectFit

        addSubview(toggleView)  {
            $0.width.equal(to: Constants.size)
            $0.height.equal(to: Constants.size)
            $0.leading.equal(to: leadingAnchor)
            $0.top.equal(to: topAnchor)
            $0.bottom.equal(to: bottomAnchor)
            $0.trailing.equal(to: trailingAnchor)
        }
        return toggleView
    }

    private func createCheckboxView() -> UIButton {
        let checkboxView = UIButton()
        checkboxView.setImage(.init(imageLiteralResourceName: Constants.Checkbox.uncheckedImageName), for: .normal)
        checkboxView.setImage(.init(imageLiteralResourceName: Constants.Checkbox.checkedImageName), for: .selected)
        checkboxView.contentMode = .center

        addSubview(checkboxView) {
            $0.width.equal(to: Constants.size)
            $0.height.equal(to: Constants.size)
            $0.leading.equal(to: leadingAnchor)
            $0.top.equal(to: topAnchor)
            $0.bottom.equal(to: bottomAnchor)
            $0.trailing.equal(to: trailingAnchor)
        }
        checkboxView.imageView?.layoutUsing.anchors {
            $0.width.equal(to: Constants.Checkbox.imageSize)
            $0.height.equal(to: Constants.Checkbox.imageSize)
        }
        return checkboxView
    }

    private func createNumberedView() -> UILabel {
        let numberedView = UILabel()
        numberedView.font = .bodyFont
        numberedView.textAlignment = .center
        setContentHuggingPriority(.defaultLow + 1, for: .horizontal)

        addSubview(numberedView) {
            $0.centerX.equal(to: centerXAnchor)
            $0.centerY.equal(to: centerYAnchor)
        }
        layoutUsing.anchors {
            $0.width.greaterThanOrEqual(to: Constants.size)
            $0.height.equal(to: Constants.size)
        }
        return numberedView
    }

    private func createBulletedView() -> UIImageView {
        let bulletedView = UIImageView(image: .init(imageLiteralResourceName: Constants.Bulleted.dotImageName))
        bulletedView.contentMode = .scaleAspectFit

        addSubview(bulletedView) {
            $0.centerY.equal(to: centerYAnchor)
            $0.centerX.equal(to: centerXAnchor)
        }
        layoutUsing.anchors {
            $0.width.equal(to: Constants.size)
            $0.height.equal(to: Constants.size)
        }
        return bulletedView
    }

    private func createQuoteView() -> UIView {
        let quoteView = UIView()
        quoteView.backgroundColor = .highlighterColor

        addSubview(quoteView) {
            $0.width.equal(to: 2)
            $0.leading.equal(to: leadingAnchor, constant: 11)
            $0.top.equal(to: topAnchor)
            $0.bottom.equal(to: bottomAnchor)
        }
        layoutUsing.anchors {
            $0.width.equal(to: Constants.size)
            if let superview = superview {
                $0.top.equal(to: superview.topAnchor)
                $0.bottom.equal(to: superview.bottomAnchor)
            }
        }
        return quoteView
    }
}

private extension TextBlockIconVIew {
    private enum Constants {
        static let size: CGFloat = 30

        enum Quote {
            static let viewWidth: CGFloat = 14
        }

        enum Bulleted {
            static let size: CGFloat = 6
            static let dotTopOffset: CGFloat = 11
            static let dotImageName: String = "TextEditor/Style/Text/Bulleted/Bullet"
        }

        enum Checkbox {
            static let checkedImageName: String = "TextEditor/Style/Text/Checkbox/checked"
            static let uncheckedImageName: String = "TextEditor/Style/Text/Checkbox/unchecked"
            static let imageSize: CGFloat = 18
        }

        enum Numbered {
            static let numberToPlaceTextLeft: Int = 20
        }

        enum Toggle {
            static let foldedImageName = "TextEditor/Style/Text/Toggle/folded"
            static let unfoldedImageName = "TextEditor/Style/Text/Toggle/unfolded"
        }
    }
}
