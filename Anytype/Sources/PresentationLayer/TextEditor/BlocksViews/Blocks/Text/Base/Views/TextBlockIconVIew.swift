//
//  TextBlockIconVIew.swift
//  Anytype
//
//  Created by Denis Batvinkin on 22.06.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

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
            currentView = createCheckboxView(
                isSelected: isSelected,
                uncheckedImageName: Constants.TitleCheckbox.uncheckedImageName,
                checkedImageName: Constants.TitleCheckbox.checkedImageName,
                imageSize: Constants.TitleCheckbox.imageSize
            )
        case let .checkbox(isSelected):
            currentView = createCheckboxView(
                isSelected: isSelected,
                uncheckedImageName: Constants.Checkbox.uncheckedImageName,
                checkedImageName: Constants.Checkbox.checkedImageName,
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

extension TextBlockIconView {
    private func createToggleView() -> UIButton {
        let toggleView = UIButton()
        toggleView.setImage(UIImage(imageLiteralResourceName: Constants.Toggle.foldedImageName), for: .normal)
        toggleView.setImage(UIImage(imageLiteralResourceName: Constants.Toggle.unfoldedImageName), for: .selected)
        toggleView.contentMode = .center
        toggleView.imageView?.contentMode = .scaleAspectFit

        addSubview(toggleView)  {
            $0.width.equal(to: Constants.size.width)
            $0.height.equal(to: Constants.size.height)
            $0.leading.equal(to: leadingAnchor)
            $0.top.equal(to: topAnchor)
            $0.bottom.equal(to: bottomAnchor)
            $0.trailing.equal(to: trailingAnchor)
        }
        return toggleView
    }

    private func createCheckboxView(
        isSelected: Bool,
        uncheckedImageName: String,
        checkedImageName: String,
        imageSize: CGSize
    ) -> UIButton {
        let checkboxView = UIButton()
        checkboxView.setImage(.init(imageLiteralResourceName: uncheckedImageName), for: .normal)
        checkboxView.setImage(.init(imageLiteralResourceName: checkedImageName), for: .selected)
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
            $0.width.equal(to: Constants.size.width)
            $0.height.equal(to: Constants.size.height)
            $0.leading.equal(to: leadingAnchor)
            $0.top.equal(to: topAnchor)
            $0.bottom.equal(to: bottomAnchor)
            $0.trailing.equal(to: trailingAnchor)
        }
        checkboxView.imageView?.layoutUsing.anchors {
            $0.size(imageSize)
        }
        return checkboxView
    }

    private func createNumberedView() -> UILabel {
        let numberedView = UILabel()
        numberedView.font = .body
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

    private func createBulletedView() -> UIImageView {
        let bulletedView = UIImageView(image: .init(imageLiteralResourceName: Constants.Bulleted.dotImageName))
        bulletedView.contentMode = .scaleAspectFit

        addSubview(bulletedView) {
            $0.centerY.equal(to: centerYAnchor)
            $0.centerX.equal(to: centerXAnchor)
        }
        layoutUsing.anchors {
            $0.width.equal(to: Constants.size.width)
            $0.height.equal(to: Constants.size.height)
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
            $0.width.equal(to: Constants.size.width)
            if let superview = superview {
                $0.top.equal(to: superview.topAnchor)
                $0.bottom.equal(to: superview.bottomAnchor)
            }
        }
        return quoteView
    }
}

private extension TextBlockIconView {
    private enum Constants {
        static let size = CGSize(width: 30, height: 35)

        enum Quote {
            static let viewWidth: CGFloat = 14
        }

        enum Bulleted {
            static let size: CGFloat = 6
            static let dotTopOffset: CGFloat = 11
            static let dotImageName: String = "TextEditor/Style/Text/Bulleted/Bullet"
        }

        enum TitleCheckbox {
            static let checkedImageName = "title_todo_checkmark"
            static let uncheckedImageName = "title_todo_checkbox"
            static let imageSize = CGSize(width: 28, height: 28)
        }
        enum Checkbox {
            static let checkedImageName = "TextEditor/Style/Text/Checkbox/checked"
            static let uncheckedImageName = "TextEditor/Style/Text/Checkbox/unchecked"
            static let imageSize = CGSize(width: 18, height: 18)
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
