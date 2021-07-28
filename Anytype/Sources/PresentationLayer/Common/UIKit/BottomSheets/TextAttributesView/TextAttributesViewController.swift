//
//  TextAttributesViewController.swift
//  AnyType
//
//  Created by Denis Batvinkin on 29.04.2021.
//  Copyright © 2021 AnyType. All rights reserved.
//

import UIKit


final class TextAttributesViewController: UIViewController {
    typealias ActionHandler = (_ action: BlockHandlerActionType) -> Void

    struct AttributesState {
        var hasBold: Bool?
        var hasItalic: Bool?
        var hasStrikethrough: Bool?
        var hasCodeStyle: Bool?
        var alignment: NSTextAlignment = .left
        var url: String = ""
    }

    private var containerStackView: UIStackView = {
        let containerStackView = UIStackView()
        containerStackView.axis = .horizontal
        containerStackView.distribution = .fillProportionally
        containerStackView.spacing = 8.0

        return containerStackView
    }()

    private var leftTopStackView: UIStackView = {
        let leftTopStackView = UIStackView()
        leftTopStackView.axis = .horizontal
        leftTopStackView.distribution = .fillEqually
        leftTopStackView.spacing = 8.0

        return leftTopStackView
    }()

    private var leftBottomStackView: UIStackView = {
        let leftBottomStackView = UIStackView()
        leftBottomStackView.axis = .horizontal
        leftBottomStackView.distribution = .fillEqually

        return leftBottomStackView
    }()

    private var leftStackView: UIStackView = {
        let leftStackView = UIStackView()
        leftStackView.axis = .vertical
        leftStackView.distribution = .fillEqually
        leftStackView.spacing = 16.0

        return leftStackView
    }()

    private var rightStackView: UIStackView = {
        let rightStackView = UIStackView()
        rightStackView.axis = .vertical
        rightStackView.distribution = .fillEqually
        rightStackView.spacing = 16.0

        return rightStackView
    }()

    private let attributesState: AttributesState
    private let actionHandler: ActionHandler

    // MARK: - Lifecycle

    /// Init text attributes view controller
    /// - Parameter attributesState: Attributes  state
    init(attributesState: AttributesState, actionHandler: @escaping ActionHandler) {
        self.actionHandler = actionHandler
        self.attributesState = attributesState

        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
    }

    // MARK: -  Setup views

    private func setupViews() {
        containerStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerStackView)

        containerStackView.addArrangedSubview(leftStackView)
        containerStackView.addArrangedSubview(rightStackView)

        containerStackView.edgesToSuperview(insets: UIEdgeInsets(top: 24.0, left: 16, bottom: 20, right: 16))

        setupLeftStackView()
        setupRightStackView()
    }

    private func setupLeftStackView() {
        setupLeftTopStackView()
        setupLeftBottomStackView()
        leftStackView.addArrangedSubview(leftTopStackView)
        leftStackView.addArrangedSubview(leftBottomStackView)
    }

    private func setupRightStackView() {
        let codeButton = makeRoundedButton(
            image: UIImage.textAttributes.code,
            selector: #selector(codeButtonHandler(sender:)),
            isSelected: attributesState.hasCodeStyle ?? false,
            isEnabled: attributesState.hasCodeStyle != nil
        )
        let urlButton = makeRoundedButton(
            image: UIImage.textAttributes.url,
            selector: #selector(urlButtonHandler(sender:)),
            isSelected: !attributesState.url.isEmpty,
            isEnabled: true
        )

        rightStackView.addArrangedSubview(codeButton)
        rightStackView.addArrangedSubview(urlButton)
    }

    private func setupLeftTopStackView() {
        let boldButton = makeRoundedButton(
            image: UIImage.textAttributes.bold,
            selector: #selector(boldButtonHandler(sender:)),
            isSelected: attributesState.hasBold ?? false,
            isEnabled: attributesState.hasBold != nil
        )
        let italicButton = makeRoundedButton(
            image: UIImage.textAttributes.italic,
            selector: #selector(italicButtonHandler(sender:)),
            isSelected: attributesState.hasItalic ?? false,
            isEnabled: attributesState.hasItalic != nil
        )
        let strikethroughButton = makeRoundedButton(
            image: UIImage.textAttributes.strikethrough,
            selector: #selector(strikethrougButtonHandler(sender:)),
            isSelected: attributesState.hasStrikethrough ?? false,
            isEnabled: attributesState.hasStrikethrough != nil
        )
        leftTopStackView.addArrangedSubview(boldButton)
        leftTopStackView.addArrangedSubview(italicButton)
        leftTopStackView.addArrangedSubview(strikethroughButton)
    }
    
    private func makeRoundedButton(
        image: UIImage?,
        selector: Selector,
        isSelected: Bool,
        isEnabled: Bool
    ) -> ButtonWithImage {
        let button = ButtonsFactory.roundedBorderуButton(image: image)
        button.isSelected = isSelected
        button.isEnabled = isEnabled
        button.addTarget(self, action: selector, for: .touchUpInside)
        return button
    }

    private func setupLeftBottomStackView() {
        let leftAlignButton = ButtonsFactory.makeButton(image: UIImage.textAttributes.alignLeft)
        leftAlignButton.isSelected = .left == attributesState.alignment
        leftAlignButton.addBorders(edges: .right, width: 1.0, color: UIColor.grayscale30)
        leftAlignButton.addTarget(self, action: #selector(leftAlignButtonHandler(sender:)), for: .touchUpInside)

        let centerAlignButton = ButtonsFactory.makeButton(image: UIImage.textAttributes.alignCenter)
        centerAlignButton.isSelected = .center == attributesState.alignment
        centerAlignButton.addBorders(edges: .right, width: 1.0, color: UIColor.grayscale30)
        centerAlignButton.addTarget(self, action: #selector(centerAlignButtonHandler(sender:)), for: .touchUpInside)

        let rightAlignButton = ButtonsFactory.makeButton(image: UIImage.textAttributes.alignRight)
        rightAlignButton.isSelected = .right == attributesState.alignment
        rightAlignButton.addTarget(self, action: #selector(rightAlignButtonHandler(sender:)), for: .touchUpInside)

        leftBottomStackView.addArrangedSubview(leftAlignButton)
        leftBottomStackView.addArrangedSubview(centerAlignButton)
        leftBottomStackView.addArrangedSubview(rightAlignButton)

        leftBottomStackView.layer.borderWidth = 1.0
        leftBottomStackView.clipsToBounds = true
        leftBottomStackView.layer.cornerRadius = 10
        leftBottomStackView.layer.borderColor = UIColor.grayscale30.cgColor
    }

    // MARK: - Action handler

    @objc private func leftAlignButtonHandler(sender: ButtonWithImage) {
        leftBottomStackView.arrangedSubviews.forEach { view in
            guard let view = view as? UIControl else { return }

            view.backgroundColor = .clear
            view.isSelected = false
        }
        sender.isSelected = true
        sender.backgroundColor = sender.isSelected ? UIColor.selected : .clear
        actionHandler(.setAlignment(.left))
    }

    @objc private func centerAlignButtonHandler(sender: ButtonWithImage) {

        leftBottomStackView.arrangedSubviews.forEach { view in
            guard let view = view as? UIControl else { return }

            view.backgroundColor = .clear
            view.isSelected = false
        }
        sender.isSelected = true
        sender.backgroundColor = sender.isSelected ? UIColor.selected : .clear
        actionHandler(.setAlignment(.center))
    }

    @objc private func rightAlignButtonHandler(sender: ButtonWithImage) {

        leftBottomStackView.arrangedSubviews.forEach { view in
            guard let view = view as? UIControl else { return }

            view.backgroundColor = .clear
            view.isSelected = false
        }
        sender.isSelected = true
        sender.backgroundColor = sender.isSelected ? UIColor.selected : .clear
        actionHandler(.setAlignment(.right))
    }

    @objc private func codeButtonHandler(sender: ButtonWithImage) {
        sender.isSelected.toggle()
        sender.backgroundColor = sender.isSelected ? UIColor.selected : .clear
        actionHandler(.toggleFontStyle(.keyboard))
    }

    @objc private func urlButtonHandler(sender: ButtonWithImage) {
        sender.isSelected.toggle()
        sender.backgroundColor = sender.isSelected ? UIColor.selected : .clear
    }

    @objc private func boldButtonHandler(sender: ButtonWithImage) {
        sender.isSelected.toggle()
        sender.backgroundColor = sender.isSelected ? UIColor.selected : .clear
        actionHandler(.toggleFontStyle(.bold))
    }

    @objc private func italicButtonHandler(sender: ButtonWithImage) {
        sender.isSelected.toggle()
        sender.backgroundColor = sender.isSelected ? UIColor.selected : .clear
        actionHandler(.toggleFontStyle(.italic))
    }

    @objc private func strikethrougButtonHandler(sender: ButtonWithImage) {
        sender.isSelected.toggle()
        sender.backgroundColor = sender.isSelected ? UIColor.selected : .clear
        actionHandler(.toggleFontStyle(.strikethrough))
    }
}
