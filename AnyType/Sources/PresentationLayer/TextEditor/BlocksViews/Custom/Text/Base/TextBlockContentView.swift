//
//  TextBlockContentView.swift
//  AnyType
//
//  Created by Kovalev Alexander on 10.03.2021.
//  Copyright © 2021 AnyType. All rights reserved.
//

import UIKit

final class TextBlockContentView: UIView & UIContentView {

    struct Layout {
        let insets: UIEdgeInsets = .init(top: 5, left: 5, bottom: 5, right: 5)
    }
    
    private enum Constants {
        /// Text
        static let textBlockContainerInset: UIEdgeInsets = .init(top: 4, left: 4, bottom: 4, right: 4)
        
        /// Quote
        static let quoteViewWidth: CGFloat = 14
        static let quoteBlockTextContainerInset: UIEdgeInsets = .init(top: 4, left: 14, bottom: 4, right: 8)
        
        /// Bulleted
        static let viewSide: CGFloat = 28
        static let dotTopOffset: CGFloat = 11
        static let bulletedTextViewContainerInsets: UIEdgeInsets = .init(top: 4, left: 0, bottom: 4, right: 8)
        static let dotImageName: String = "TextEditor/Style/Text/Bulleted/Bullet"
        
        /// Checkbox
        static let checkboxTextContainerInset: UIEdgeInsets = .init(top: 4, left: 0, bottom: 4, right: 8)
        static let checkedImageName: String = "TextEditor/Style/Text/Checkbox/checked"
        static let uncheckedImageName: String = "TextEditor/Style/Text/Checkbox/unchecked"
        static let checkboxButtonTag = 1
        
        /// Toggle
        static let foldedImageName = "TextEditor/Style/Text/Toggle/folded"
        static let unfoldedImageName = "TextEditor/Style/Text/Toggle/unfolded"
        static let toggleTextContainerInsets: UIEdgeInsets = .init(top: 4, left: 0, bottom: 4, right: 8)
        static let toggleButtonTag = 2
        
        /// Numbered
        static let labelTopOffset: CGFloat = 3
        static let leadingViewWidth: CGFloat = 27
        static let numberedTextViewContainerInsets: UIEdgeInsets = .init(top: 4, left: 1, bottom: 4, right: 8)
        static let numberToPlaceTextLeft: Int = 20
    }

    /// Views
    private let topView: BlocksViews.New.Text.Base.TopWithChildUIKitView = .init()
    private let contentView: UIView = .init()
    private var textView: TextView.UIKitTextView? = nil
    
    private var currentConfiguration: TextBlockContentConfiguration
    var configuration: UIContentConfiguration {
        get { self.currentConfiguration }
        set {
            guard let configuration = newValue as? TextBlockContentConfiguration else { return }
            self.apply(configuration: configuration)
        }
    }

    /// Initialization
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Initializer
    init(configuration: TextBlockContentConfiguration) {
        self.currentConfiguration = configuration
        super.init(frame: .zero)
        self.setup()
        self.applyNewConfiguration()
    }
    
    private func setup() {
        self.setupUIElements()
        self.addLayout()
    }

    private func setupUIElements() {
        [self.contentView, self.topView].forEach { (value) in
            value.translatesAutoresizingMaskIntoConstraints = false
        }

        _ = self.topView.configured(leftChild: .empty())

        /// View hierarchy
        self.contentView.addSubview(self.topView)
        self.addSubview(self.contentView)

        textView = TextView.UIKitTextView()
        _ = self.topView.configured(textView: self.textView)
    }

    private func addLayout() {
        if let superview = self.contentView.superview {
            let view = self.contentView
            let layout: Layout = .init()
            NSLayoutConstraint.activate([
                view.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: layout.insets.left),
                view.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -layout.insets.right),
                view.topAnchor.constraint(equalTo: superview.topAnchor, constant: layout.insets.top),
                view.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -layout.insets.bottom),
            ])
        }

        if let superview = self.topView.superview {
            let view = self.topView
            NSLayoutConstraint.activate([
                view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                view.topAnchor.constraint(equalTo: superview.topAnchor),
                view.bottomAnchor.constraint(equalTo: superview.bottomAnchor),
            ])
        }
    }

    private func apply(configuration: TextBlockContentConfiguration) {
        guard self.currentConfiguration != configuration else { return }
        self.currentConfiguration = configuration
        self.applyNewConfiguration()
    }

    private func applyNewConfiguration() {
        self.currentConfiguration.contextMenuHolder?.addContextMenuIfNeeded(self)
        if let textViewModel = self.currentConfiguration.contextMenuHolder?.getUIKitViewModel() {
            textViewModel.update = .unknown
            _ = self.textView?.configured(.init(liveUpdateAvailable: true)).configured(textViewModel)
            self.currentConfiguration.contextMenuHolder?.refreshTextViewModel(textViewModel)
        }
        guard case let .text(text) = self.currentConfiguration.information.content else { return }
        switch text.contentType {
        case .title:
            self.setupText(placeholer: NSLocalizedString("Title", comment: ""), font: .titleFont)
        case .text:
            self.setupForText()
        case .bulleted:
            self.setupForBulleted()
        case .checkbox:
            self.setupForCheckbox(checked: text.checked)
        case .numbered:
            self.setupForNumbered(number: text.number)
        case .quote:
            self.setupForQuote()
        case .toggle:
            self.setupForToggle(toggled: self.currentConfiguration.block.isToggled)
        case .header:
            self.setupText(placeholer: NSLocalizedString("Header 1", comment: ""), font: .header1Font)
        case .header2:
            self.setupText(placeholer: NSLocalizedString("Header 2", comment: ""), font: .header2Font)
        case .header3:
            self.setupText(placeholer: NSLocalizedString("Header 3", comment: ""), font: .header3Font)
        case .header4, .callout:
            break
        }
    }
    
    private func setupForPlainText() {
        guard self.topView.leftView != nil else  { return }
        _ = self.topView.configured(leftChild: .empty())
        self.textView?.textView?.textContainerInset = Constants.textBlockContainerInset
    }
    
    private func setupForText() {
        self.setupForPlainText()
        self.topView.backgroundColor = .systemGray6
        self.textView?.textView?.update(placeholder: nil)
        self.textView?.textView.font = .bodyFont
    }
    
    private func setupText(placeholer: String, font: UIFont) {
        self.setupForPlainText()
        self.textView?.textView?.backgroundColor = .systemBackground
        let attributes: [NSAttributedString.Key: Any] = [.font: font,
                                                         .foregroundColor: UIColor.secondaryTextColor]
        self.textView?.textView?.update(placeholder: .init(string: placeholer, attributes: attributes))
        self.textView?.textView.font = font
    }
    
    private func setupForToggle(toggled: Bool) {
        if let toggleButton = self.topView.leftView.subviews.first as? UIButton, toggleButton.tag == Constants.toggleButtonTag {
            toggleButton.isSelected = toggled
        } else {
            self.textView?.textView?.textContainerInset = Constants.toggleTextContainerInsets
            self.topView.backgroundColor = .systemBackground
            self.textView?.textView?.textColor = .secondaryTextColor
            
            let button: UIButton = .init()
            button.tag = Constants.toggleButtonTag
            button.setImage(.init(imageLiteralResourceName: Constants.foldedImageName), for: .normal)
            button.setImage(.init(imageLiteralResourceName: Constants.unfoldedImageName), for: .selected)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setContentHuggingPriority(.required, for: .horizontal)
            button.addTarget(self, action: #selector(didTapToggleButton), for: .touchUpInside)
            button.isSelected = toggled
            
            let container: UIView = .init()
            container.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(button)
            NSLayoutConstraint.activate([
                container.widthAnchor.constraint(equalTo: button.widthAnchor),
                container.heightAnchor.constraint(greaterThanOrEqualTo: button.heightAnchor),
                button.centerXAnchor.constraint(equalTo: container.centerXAnchor),
                button.topAnchor.constraint(equalTo: container.topAnchor)
            ])
            _ = self.topView.configured(leftChild: container, setConstraints: true)
        }
    }
    
    @objc private func didTapToggleButton(_ button: UIButton) {
        button.isSelected.toggle()
        self.currentConfiguration.toggleAction()
    }
    
    private func setupForCheckbox(checked: Bool) {
        if let button = self.topView.leftView.subviews.first as? UIButton,
           button.tag == Constants.checkboxButtonTag {
            button.isSelected = checked
        } else {
            self.topView.backgroundColor = .systemBackground
            self.textView?.textView?.textContainerInset = Constants.checkboxTextContainerInset
            
            let button: UIButton = .init()
            button.translatesAutoresizingMaskIntoConstraints = false
            button.tag = Constants.checkboxButtonTag
            button.setImage(.init(imageLiteralResourceName: Constants.uncheckedImageName), for: .normal)
            button.setImage(.init(imageLiteralResourceName: Constants.checkedImageName), for: .selected)
            button.imageView?.contentMode = .scaleAspectFill
            button.contentEdgeInsets.left = 4
            button.contentVerticalAlignment = .bottom
            button.setContentHuggingPriority(.required, for: .horizontal)
            button.isSelected = checked
            button.addTarget(self, action: #selector(didTapCheckboxButton), for: .touchUpInside)
            
            let container: UIView = .init()
            container.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(button)
            NSLayoutConstraint.activate([
                container.widthAnchor.constraint(equalTo: button.widthAnchor),
                container.heightAnchor.constraint(greaterThanOrEqualTo: button.heightAnchor),
                button.centerXAnchor.constraint(equalTo: container.centerXAnchor),
                button.topAnchor.constraint(equalTo: container.topAnchor)
            ])
            _ = self.topView.configured(leftChild: container, setConstraints: true)
        }
        self.textView?.textView?.textColor = checked ? .secondaryTextColor : .textColor
    }
    
    @objc private func didTapCheckboxButton(_ button: UIButton) {
        self.currentConfiguration.checkedAction(!button.isSelected)
    }
    
    private func setupForBulleted() {
        let isBulletedView = self.topView.leftView.subviews.first is UIImageView
        guard !isBulletedView else { return }
        self.textView?.textView?.textContainerInset = Constants.bulletedTextViewContainerInsets
        self.topView.backgroundColor = .systemBackground
        
        let view: UIView = .init()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let dotView: UIImageView = .init(image: .init(imageLiteralResourceName: Constants.dotImageName))
        dotView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dotView)
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.viewSide),
            view.widthAnchor.constraint(equalToConstant: Constants.viewSide),
            dotView.topAnchor.constraint(equalTo: view.topAnchor, constant: Constants.dotTopOffset),
            dotView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        _ = self.topView.configured(leftChild: view, setConstraints: true)
    }
    
    private func setupForNumbered(number: Int) {
        if let label = self.topView.leftView.subviews.first as? UILabel {
            label.textAlignment = number >= Constants.numberToPlaceTextLeft ? .left : .center
            label.text = String(number) + "."
        } else {
            self.textView?.textView?.textContainerInset = Constants.numberedTextViewContainerInsets
            self.topView.backgroundColor = .systemBackground
            
            let label: UILabel = .init()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.font = .bodyFont
            label.textAlignment = number >= Constants.numberToPlaceTextLeft ? .left : .center
            label.text = String(number) + "."
            
            let container: UIView = .init()
            container.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(label)
            NSLayoutConstraint.activate([
                container.widthAnchor.constraint(equalToConstant: Constants.leadingViewWidth),
                label.widthAnchor.constraint(equalTo: container.widthAnchor),
                container.heightAnchor.constraint(greaterThanOrEqualTo: label.heightAnchor),
                label.centerXAnchor.constraint(equalTo: container.centerXAnchor),
                label.topAnchor.constraint(equalTo: container.topAnchor, constant: Constants.labelTopOffset)
            ])
            _ = self.topView.configured(leftChild: container, setConstraints: true)
        }
    }
    
    private func setupForQuote() {
        let isQuoteView = self.topView.leftView.subviews.first is QuoteBlockLeadingView
        guard !isQuoteView else { return }
        
        self.textView?.textView?.textContainerInset = Constants.quoteBlockTextContainerInset
        let attribures: [NSAttributedString.Key: Any] = [.font: UIFont.highlightFont,
                                                         .foregroundColor: UIColor.secondaryTextColor]
        self.textView?.textView?.update(placeholder: .init(string: NSLocalizedString("Quote",
                                                                                     comment: ""),
                                                           attributes: attribures))
        self.topView.backgroundColor = .systemBackground
        let view: QuoteBlockLeadingView = .init()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.widthAnchor.constraint(equalToConstant: Constants.quoteViewWidth).isActive = true
        _ = self.topView.configured(leftChild: view, setConstraints: true)
    }
}
