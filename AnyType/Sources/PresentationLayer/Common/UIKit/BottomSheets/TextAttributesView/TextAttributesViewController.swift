//
//  TextAttributesViewController.swift
//  AnyType
//
//  Created by Denis Batvinkin on 29.04.2021.
//  Copyright © 2021 AnyType. All rights reserved.
//

import UIKit


final class TextAttributesViewController: UIViewController {

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

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
    }

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
        let codeButton = ButtonsFactory.roundedBorderуButton(image: UIImage(named: "TextAttributes/code"))
        let urlButton = ButtonsFactory.roundedBorderуButton(image: UIImage(named: "TextAttributes/url"))

        codeButton.addTarget(self, action: #selector(codeButtonHandler(sender:)), for: .touchUpInside)
        urlButton.addTarget(self, action: #selector(urlButtonHandler(sender:)), for: .touchUpInside)

        rightStackView.addArrangedSubview(codeButton)
        rightStackView.addArrangedSubview(urlButton)
    }

    private func setupLeftTopStackView() {
        let boldButton = ButtonsFactory.roundedBorderуButton(image: UIImage(named: "TextAttributes/bold"))
        let italicButton = ButtonsFactory.roundedBorderуButton(image: UIImage(named: "TextAttributes/italic"))
        let strikethrougButton = ButtonsFactory.roundedBorderуButton(image: UIImage(named: "TextAttributes/strikethrough"))

        boldButton.addTarget(self, action: #selector(boldButtonHandler(sender:)), for: .touchUpInside)
        italicButton.addTarget(self, action: #selector(italicButtonHandler(sender:)), for: .touchUpInside)
        strikethrougButton.addTarget(self, action: #selector(strikethrougButtonHandler(sender:)), for: .touchUpInside)

        leftTopStackView.addArrangedSubview(boldButton)
        leftTopStackView.addArrangedSubview(italicButton)
        leftTopStackView.addArrangedSubview(strikethrougButton)
    }

    private func setupLeftBottomStackView() {
        let leftAlignButton = ButtonWithImage()
        leftAlignButton.setImage(UIImage(named: "TextAttributes/align_left"))
        leftAlignButton.addBorders(edges: .right, width: 1.0, color: UIColor.grayscale30)
        leftAlignButton.addTarget(self, action: #selector(leftAlignButtonHandler(sender:)), for: .touchUpInside)

        let centerAlignButton = ButtonWithImage()
        centerAlignButton.setImage(UIImage(named: "TextAttributes/align_center"))
        centerAlignButton.addBorders(edges: .right, width: 1.0, color: UIColor.grayscale30)
        centerAlignButton.addTarget(self, action: #selector(centerAlignButtonHandler(sender:)), for: .touchUpInside)

        let rightAlignButton = ButtonWithImage()
        rightAlignButton.setImage(UIImage(named: "TextAttributes/align_right"))
        rightAlignButton.addTarget(self, action: #selector(rightAlignButtonHandler(sender:)), for: .touchUpInside)

        leftBottomStackView.addArrangedSubview(leftAlignButton)
        leftBottomStackView.addArrangedSubview(centerAlignButton)
        leftBottomStackView.addArrangedSubview(rightAlignButton)

        leftBottomStackView.layer.borderWidth = 1.0
        leftBottomStackView.clipsToBounds = true
        leftBottomStackView.layer.cornerRadius = 10
        leftBottomStackView.layer.borderColor = UIColor.grayscale30.cgColor
    }

    @objc private func leftAlignButtonHandler(sender: ButtonWithImage) {
        leftBottomStackView.arrangedSubviews.forEach { view in
            guard let view = view as? UIControl else { return }

            view.backgroundColor = .clear
            view.isSelected = false
        }
        sender.isSelected = true
        sender.backgroundColor = sender.isSelected ? UIColor.pressed : .clear
    }

    @objc private func centerAlignButtonHandler(sender: ButtonWithImage) {

        leftBottomStackView.arrangedSubviews.forEach { view in
            guard let view = view as? UIControl else { return }

            view.backgroundColor = .clear
            view.isSelected = false
        }
        sender.isSelected = true
        sender.backgroundColor = sender.isSelected ? UIColor.pressed : .clear
    }

    @objc private func rightAlignButtonHandler(sender: ButtonWithImage) {

        leftBottomStackView.arrangedSubviews.forEach { view in
            guard let view = view as? UIControl else { return }

            view.backgroundColor = .clear
            view.isSelected = false
        }
        sender.isSelected = true
        sender.backgroundColor = sender.isSelected ? UIColor.pressed : .clear
    }

    @objc private func codeButtonHandler(sender: ButtonWithImage) {
        sender.isSelected.toggle()
        sender.backgroundColor = sender.isSelected ? UIColor.pressed : .clear
    }

    @objc private func urlButtonHandler(sender: ButtonWithImage) {
        sender.isSelected.toggle()
        sender.backgroundColor = sender.isSelected ? UIColor.pressed : .clear
    }

    @objc private func boldButtonHandler(sender: ButtonWithImage) {
        sender.isSelected.toggle()
        sender.backgroundColor = sender.isSelected ? UIColor.pressed : .clear
    }

    @objc private func italicButtonHandler(sender: ButtonWithImage) {
        sender.isSelected.toggle()
        sender.backgroundColor = sender.isSelected ? UIColor.pressed : .clear
    }

    @objc private func strikethrougButtonHandler(sender: ButtonWithImage) {
        sender.isSelected.toggle()
        sender.backgroundColor = sender.isSelected ? UIColor.pressed : .clear
    }
}
