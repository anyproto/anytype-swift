//
//  CodeBlockContentView.swift
//  AnyType
//
//  Created by Denis Batvinkin on 05.04.2021.
//  Copyright © 2021 AnyType. All rights reserved.
//

import Combine
import UIKit
import Highlightr


/// Content view for code block
final class CodeBlockContentView: UIView & UIContentView {

    // MARK: - Constants

    private enum Constants {
        static let insets: UIEdgeInsets = .init(top: 6, left: 0, bottom: 6, right: 0)
        static let textInsets: UIEdgeInsets = .init(top: 50, left: 20, bottom: 24, right: 20)
        static let defaultLanguage: String = "Swift"
        static let defaultTheme: String = "github-gist"
    }

    let textStorage = CodeAttributedString()

    // MARK: - Properties

    private lazy var textView: UITextView = {
        textStorage.language = Constants.defaultLanguage
        textStorage.highlightr.setTheme(to: Constants.defaultTheme)
        codeSelectButton.label.text = Constants.defaultLanguage

        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)

        let textContainer = NSTextContainer()
        layoutManager.addTextContainer(textContainer)

        let textView = UITextView(frame: bounds, textContainer: textContainer)
        textView.isScrollEnabled = false
        textView.backgroundColor = .clear

        return textView
    }()

    private var codeSelectButton: ButtonWithImage = {
        let button = ButtonWithImage()
        button.translatesAutoresizingMaskIntoConstraints = false

        button.label.font = UIFont.bodyFont
        button.label.textColor = MiddlewareModelsModule.Parsers.Text.Color.Converter.Colors.grey.color()
        let image = UIImage(named: "TextEditor/Toolbar/turn_into_arrow")
        button.setImage(image)

        return button
    }()
    
    private var setFocusSubscription: AnyCancellable?

    private var currentConfiguration: CodeBlockContentConfiguration

    /// Block content configuration
    var configuration: UIContentConfiguration {
        get { self.currentConfiguration }
        set {
            guard let configuration = newValue as? CodeBlockContentConfiguration else { return }
            self.apply(configuration: configuration)
        }
    }

    // MARK: - Life cycle

    /// Initialization
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Initializer
    init(configuration: CodeBlockContentConfiguration) {
        self.currentConfiguration = configuration
        super.init(frame: .zero)
        self.setup()
        self.applyNewConfiguration()
    }

    private func setup() {
        textView.delegate = self
        textView.textContainerInset = Constants.textInsets

        textView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(textView)
        addSubview(codeSelectButton)

        textView.edgesToSuperview(insets: Constants.insets)

        NSLayoutConstraint.activate([
            codeSelectButton.topAnchor.constraint(equalTo: topAnchor, constant: 13),
            codeSelectButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20)
        ])

        codeSelectButton.addAction(UIAction(handler: { [weak self] action in
            guard let codeLanguages = self?.textStorage.highlightr.supportedLanguages() else { return }

            self?.currentConfiguration.contextMenuHolder?.needsShowCodeLanguageView(with: codeLanguages) { language in
                self?.textStorage.language = language
                self?.codeSelectButton.setText(language)
            }
        }), for: .touchUpInside)
    }

    // MARK: - Apply configuration

    private func apply(configuration: CodeBlockContentConfiguration) {
        guard self.currentConfiguration != configuration else { return }
        self.currentConfiguration = configuration
        self.applyNewConfiguration()
    }

    private func applyNewConfiguration() {
        self.currentConfiguration.contextMenuHolder?.addContextMenuIfNeeded(self)
        let setFocusPublisher = currentConfiguration.contextMenuHolder?.textViewModel.setFocusPublisher
        setFocusSubscription = setFocusPublisher?.sink(receiveValue: { [weak self] value in
            guard let position = value.position else { return }
            self?.textView.setFocus(position)
        })
        if case let .text(content) = self.currentConfiguration.information.content {
            self.textView.text = content.attributedText.string
        }
        typealias ColorConverter = MiddlewareModelsModule.Parsers.Text.Color.Converter
        self.textView.backgroundColor = ColorConverter.Colors.grey.color(background: true)
    }
}

// MARK: - UITextViewDelegate

extension CodeBlockContentView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let currentSize = textView.bounds.size
        let newSize = textView.attributedText.size()
        
        if newSize.height != currentSize.height {
            self.currentConfiguration.contextMenuHolder?.needsUpdateLayout()
        }
    }
}
