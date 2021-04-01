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
        let insets: UIEdgeInsets = .init(top: 1, left: 20, bottom: 1, right: 20)
    }
    
    private enum Constants {
        
        enum Text {
            static let textContainerInsets: UIEdgeInsets = .init(top: 4, left: 4, bottom: 4, right: 4)
        }
        
        enum Quote {
            static let viewWidth: CGFloat = 14
            static let textContainerInsets: UIEdgeInsets = .init(top: 4, left: 14, bottom: 4, right: 8)
        }
        
        enum Bulleted {
            static let viewSide: CGFloat = 28
            static let dotTopOffset: CGFloat = 11
            static let textContainerInsets: UIEdgeInsets = .init(top: 4, left: 0, bottom: 4, right: 8)
            static let dotImageName: String = "TextEditor/Style/Text/Bulleted/Bullet"
        }
        
        enum Checkbox {
            static let textContainerInsets: UIEdgeInsets = .init(top: 4, left: 4, bottom: 4, right: 8)
            static let checkedImageName: String = "TextEditor/Style/Text/Checkbox/checked"
            static let uncheckedImageName: String = "TextEditor/Style/Text/Checkbox/unchecked"
            static let buttonTag = 1
            static let buttonTopOffset: CGFloat = 2
        }
        
        enum Numbered {
            static let labelTopOffset: CGFloat = 5
            static let leadingViewWidth: CGFloat = 27
            static let textContainerInsets: UIEdgeInsets = .init(top: 4, left: 1, bottom: 4, right: 8)
            static let numberToPlaceTextLeft: Int = 20
        }
    }
    private let layout: Layout = .init()
    /// Views
    private let topView: BlocksViews.New.Text.Base.TopWithChildUIKitView = .init()
    private let textView: TextView.UIKitTextView = .init()
    
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
        self.topView.translatesAutoresizingMaskIntoConstraints = false
        _ = self.topView.configured(leftChild: .empty())
        self.addSubview(self.topView)
        _ = self.topView.configured(textView: self.textView)
    }

    private func addLayout() {
        if let superview = self.topView.superview {
            let view = self.topView
            NSLayoutConstraint.activate([
                view.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: self.layout.insets.left),
                view.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -self.layout.insets.right),
                view.topAnchor.constraint(equalTo: superview.topAnchor, constant: self.layout.insets.top),
                view.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -self.layout.insets.bottom)
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

        // it's important to clean old attributed string
        self.textView.textView.attributedText = nil

        if let textViewModel = self.currentConfiguration.contextMenuHolder?.getUIKitViewModel() {
            textViewModel.update = .unknown
            _ = self.textView.configured(.init(liveUpdateAvailable: true)).configured(textViewModel)

        guard case let .text(text) = self.currentConfiguration.information.content else { return }
            // In case of configurations is not equal we should check what exactly we should change
            // Because configurations for checkbox block and numbered block may not be equal, so we must rebuld whole view
            switch text.contentType {
            case .title:
                self.setupForTitle()
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
            case .header:
                self.setupForHeader1()
            case .header2:
                self.setupForHeader2()
            case .header3:
                self.setupForHeader3()
            case .header4, .callout, .toggle:
                break
            }
            self.currentConfiguration.contextMenuHolder?.refreshTextViewModel(textViewModel)
        }
        typealias ColorConverter = MiddlewareModelsModule.Parsers.Text.Color.Converter
        self.textView.backgroundColor = ColorConverter.asModel(self.currentConfiguration.information.backgroundColor, background: true)
    }
    
    private func setupForPlainText() {
        guard self.topView.leftView != nil else  { return }
        _ = self.topView.configured(leftChild: .empty())
        self.textView.textView?.textContainerInset = Constants.Text.textContainerInsets
    }
    
    private func setupForText() {
        self.setupForPlainText()
        self.setupText(placeholer: "", font: .bodyFont)
    }
    
    private func setupForTitle() {
        self.setupForPlainText()
        self.setupText(placeholer: NSLocalizedString("Title", comment: ""), font: .titleFont)
    }
    
    private func setupForHeader1() {
        self.setupForPlainText()
        self.setupText(placeholer: NSLocalizedString("Header 1", comment: ""), font: .header1Font)
    }
    
    private func setupForHeader2() {
        self.setupForPlainText()
        self.setupText(placeholer: NSLocalizedString("Header 2", comment: ""), font: .header2Font)
    }
    
    private func setupForHeader3() {
        self.setupForPlainText()
        self.setupText(placeholer: NSLocalizedString("Header 3", comment: ""), font: .header3Font)
    }
    
    private func setupText(placeholer: String, font: UIFont, backgroundColor: UIColor = .systemBackground) {
        self.backgroundColor = backgroundColor
        let attributes: [NSAttributedString.Key: Any] = [.font: font,
                                                         .foregroundColor: UIColor.secondaryTextColor]

        self.textView.textView?.update(placeholder: .init(string: placeholer, attributes: attributes))
        self.textView.textView.font = font
        self.textView.textView.typingAttributes = [.font: font]
        self.textView.textView?.defaultFontColor = .textColor
    }
    
    private func setupForCheckbox(checked: Bool) {
        if let button = self.topView.leftView.subviews.first as? UIButton,
           button.tag == Constants.Checkbox.buttonTag {
            button.isSelected = checked
        } else {
            let button: UIButton = .init()
            button.translatesAutoresizingMaskIntoConstraints = false
            button.tag = Constants.Checkbox.buttonTag
            button.setImage(.init(imageLiteralResourceName: Constants.Checkbox.uncheckedImageName), for: .normal)
            button.setImage(.init(imageLiteralResourceName: Constants.Checkbox.checkedImageName), for: .selected)
            button.imageView?.contentMode = .scaleAspectFill
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
                button.topAnchor.constraint(equalTo: container.topAnchor, constant: Constants.Checkbox.buttonTopOffset)
            ])
            _ = self.topView.configured(leftChild: container, setConstraints: true)
        }
        self.setupText(placeholer: NSLocalizedString("Checkbox placeholder", comment: ""), font: .bodyFont)
        self.textView.textView?.textContainerInset = Constants.Checkbox.textContainerInsets
        // selected color
        textView.textView.selectedColor = checked ? UIColor.secondaryTextColor : nil
    }
    
    @objc private func didTapCheckboxButton(_ button: UIButton) {
        self.currentConfiguration.checkedAction(!button.isSelected)
    }
    
    private func setupForBulleted() {
        self.setupText(placeholer: NSLocalizedString("Bulleted placeholder", comment: ""), font: .bodyFont)
        self.textView.textView?.textContainerInset = Constants.Bulleted.textContainerInsets
        let isBulletedView = self.topView.leftView.subviews.first is UIImageView
        guard !isBulletedView else { return }
        
        let view: UIView = .init()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let dotView: UIImageView = .init(image: .init(imageLiteralResourceName: Constants.Bulleted.dotImageName))
        dotView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dotView)
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.Bulleted.viewSide),
            view.widthAnchor.constraint(equalToConstant: Constants.Bulleted.viewSide),
            dotView.topAnchor.constraint(equalTo: view.topAnchor, constant: Constants.Bulleted.dotTopOffset),
            dotView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        _ = self.topView.configured(leftChild: view, setConstraints: true)
    }
    
    private func setupForNumbered(number: Int) {
        if let label = self.topView.leftView.subviews.first as? UILabel {
            label.textAlignment = number >= Constants.Numbered.numberToPlaceTextLeft ? .left : .center
            label.text = String(number) + "."
        } else {
            let label: UILabel = .init()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.font = .bodyFont
            label.textAlignment = number >= Constants.Numbered.numberToPlaceTextLeft ? .left : .center
            label.text = String(number) + "."
            
            let container: UIView = .init()
            container.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(label)
            NSLayoutConstraint.activate([
                container.widthAnchor.constraint(equalToConstant: Constants.Numbered.leadingViewWidth),
                label.widthAnchor.constraint(equalTo: container.widthAnchor),
                container.heightAnchor.constraint(greaterThanOrEqualTo: label.heightAnchor),
                label.centerXAnchor.constraint(equalTo: container.centerXAnchor),
                label.topAnchor.constraint(equalTo: container.topAnchor, constant: Constants.Numbered.labelTopOffset)
            ])
            _ = self.topView.configured(leftChild: container, setConstraints: true)
        }
        self.textView.textView?.textContainerInset = Constants.Numbered.textContainerInsets
        self.setupText(placeholer: NSLocalizedString("Numbered placeholder", comment: ""), font: .bodyFont)
    }
    
    private func setupForQuote() {
        self.textView.textView?.textContainerInset = Constants.Quote.textContainerInsets
        self.setupText(placeholer: NSLocalizedString("Quote placeholder", comment: ""), font: .highlightFont)
        let isQuoteViewExist = self.topView.leftView.subviews.first is QuoteBlockLeadingView
        guard !isQuoteViewExist else { return }
        let view: QuoteBlockLeadingView = .init()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.widthAnchor.constraint(equalToConstant: Constants.Quote.viewWidth).isActive = true
        _ = self.topView.configured(leftChild: view, setConstraints: true)
    }
}
