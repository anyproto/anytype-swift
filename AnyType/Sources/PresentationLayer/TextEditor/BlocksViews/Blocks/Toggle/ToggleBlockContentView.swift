//
//  ToggleBlockContentView.swift
//  AnyType
//
//  Created by Kovalev Alexander on 23.03.2021.
//  Copyright © 2021 AnyType. All rights reserved.
//

import UIKit

/// ContentView for toggle block
final class ToggleBlockContentView: UIView & UIContentView {

    private enum Constants {
        struct ToggleAddChildButton {
            let titleEdgeInsets: UIEdgeInsets = .init(top: 0, left: 24, bottom: 0, right: 0)
        }
        static let toggleAddChildButton: ToggleAddChildButton = .init()
        static let insets: UIEdgeInsets = .init(top: 1, left: 20, bottom: 1, right: 20)
        static let foldedImageName = "TextEditor/Style/Text/Toggle/folded"
        static let unfoldedImageName = "TextEditor/Style/Text/Toggle/unfolded"
        static let textContainerInsets: UIEdgeInsets = .init(top: 4, left: 0, bottom: 4, right: 8)
        static let buttonTopOffset: CGFloat = 3
    }

    private var currentConfiguration: ToggleBlockContentConfiguration
    private let topView: BlocksViews.New.Text.Base.TopWithChildUIKitView = .init()
    private let textView: TextView.UIKitTextView = .init()
    private lazy var createChildBlockButton: UIButton = {
        let button: UIButton = .init(primaryAction: .init(handler: { [weak self] _ in
            guard let self = self else { return }
            let block = self.currentConfiguration.blockViewModel.getBlock()
            self.createChildBlockButton.isHidden = true
            self.currentConfiguration.blockViewModel.send(actionsPayload: .textView(.init(model: block,
                                                      action: .textView(.keyboardAction(.pressKey(.enterAtTheEndOfContent))))))
        }))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setAttributedTitle(.init(string: NSLocalizedString("Toogle empty Click and drop block inside",
                                                                  comment: ""),
                                        attributes: [.font: UIFont.bodyFont,
                                                     .foregroundColor: UIColor.textColor]),
                                  for: .normal)
        button.titleEdgeInsets = Constants.toggleAddChildButton.titleEdgeInsets
        button.contentHorizontalAlignment = .leading
        button.isHidden = true
        return button
    }()
    private lazy var toggleButton: UIButton = {
        let button: UIButton = .init()
        button.setImage(.init(imageLiteralResourceName: Constants.foldedImageName), for: .normal)
        button.setImage(.init(imageLiteralResourceName: Constants.unfoldedImageName), for: .selected)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setContentHuggingPriority(.required, for: .horizontal)
        button.addAction(.init(handler: { [weak self] _ in
            guard let self = self else { return }
            let blockViewModel = self.currentConfiguration.blockViewModel
            self.toggleButton.isSelected.toggle()
            blockViewModel.update { $0.isToggled.toggle() }
            let toggled = blockViewModel.getBlock().isToggled
            blockViewModel.send(textViewAction: .buttonView(.toggle(.toggled(toggled))))
            let oldValue = self.createChildBlockButton.isHidden
            self.updateCreateChildButtonState(toggled: toggled,
                                              hasChildren: !blockViewModel.getBlock().childrenIds().isEmpty)
            if oldValue != self.createChildBlockButton.isHidden {
                blockViewModel.send(sizeDidChange: .zero)
            }
        }), for: .touchUpInside)
        return button
    }()
    var configuration: UIContentConfiguration {
        get { self.currentConfiguration }
        set {
            guard let configuration = newValue as? ToggleBlockContentConfiguration else { return }
            self.apply(configuration: configuration)
        }
    }

    /// Initialization
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Initializer
    init(configuration: ToggleBlockContentConfiguration) {
        self.currentConfiguration = configuration
        super.init(frame: .zero)
        self.setup()
        self.applyNewConfiguration()
    }

    private func setup() {
        self.topView.translatesAutoresizingMaskIntoConstraints = false
        _ = self.topView.configured(textView: self.textView)
        
        let stack: UIStackView = .init(arrangedSubviews: [self.topView, self.createChildBlockButton])
        stack.axis = .vertical
        stack.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: Constants.insets.left),
            stack.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -Constants.insets.right),
            stack.topAnchor.constraint(equalTo: self.topAnchor, constant: Constants.insets.top),
            stack.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -Constants.insets.bottom),
        ])
        
        let container: UIView = .init()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(self.toggleButton)
        NSLayoutConstraint.activate([
            container.widthAnchor.constraint(equalTo: self.toggleButton.widthAnchor),
            container.heightAnchor.constraint(greaterThanOrEqualTo: self.toggleButton.heightAnchor),
            self.toggleButton.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            self.toggleButton.topAnchor.constraint(equalTo: container.topAnchor, constant: Constants.buttonTopOffset)
        ])
        _ = self.topView.configured(leftChild: container, setConstraints: true)

        let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.bodyFont,
                                                         .foregroundColor: UIColor.secondaryTextColor]

        self.textView.textView?.update(placeholder: .init(string: NSLocalizedString("Toggle placeholder", comment: ""),
                                                          attributes: attributes))
        self.textView.textView.font = .bodyFont
        self.textView.textView.typingAttributes = [.font: UIFont.bodyFont]
        self.textView.textView?.textContainerInset = Constants.textContainerInsets
        self.textView.textView?.defaultFontColor = .textColor
    }

    private func apply(configuration: ToggleBlockContentConfiguration) {
        guard self.currentConfiguration != configuration else { return }
        self.currentConfiguration = configuration
        self.applyNewConfiguration()
    }

    private func applyNewConfiguration() {
        self.currentConfiguration.blockViewModel.addContextMenuIfNeeded(self)
        // it's important to clean old attributed string
        self.textView.textView.attributedText = nil

        let textViewModel = self.currentConfiguration.blockViewModel.getUIKitViewModel()
        textViewModel.update = .unknown
        _ = self.textView.configured(.init(liveUpdateAvailable: true)).configured(textViewModel)
        self.currentConfiguration.blockViewModel.refreshTextViewModel(textViewModel)
        let toggled = self.currentConfiguration.blockViewModel.getBlock().isToggled
        toggleButton.isSelected = toggled
        let hasChildren = self.currentConfiguration.blockViewModel.getBlock().childrenIds().isEmpty
        self.updateCreateChildButtonState(toggled: toggled, hasChildren: hasChildren)

        typealias ColorConverter = MiddlewareModelsModule.Parsers.Text.Color.Converter
        self.textView.backgroundColor = ColorConverter.asModel(self.currentConfiguration.information.backgroundColor)
    }

    private func updateCreateChildButtonState(toggled: Bool, hasChildren: Bool) {
        let shouldShowCreateButton = toggled && !hasChildren
        self.createChildBlockButton.isHidden = !shouldShowCreateButton
    }
}
