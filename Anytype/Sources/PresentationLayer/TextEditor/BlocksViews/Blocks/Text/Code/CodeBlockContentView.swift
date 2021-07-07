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


/// Protocol for interacting with code block view
protocol CodeBlockViewInteractable: AnyObject {
    /// Code language did changed
    /// - Parameter language: code language
    func languageDidChange(language: String)
}

/// Content view for code block
final class CodeBlockContentView: UIView & UIContentView {

    // MARK: - Constants

    private enum LayoutConstants {
        static let selectionViewInsets: UIEdgeInsets = .init(top: 6, left: 8, bottom: -6, right: -8)
        static let insets: UIEdgeInsets = .init(top: 6, left: 0, bottom: -6, right: 0)
        static let textInsets: UIEdgeInsets = .init(top: 50, left: 20, bottom: 24, right: 20)
    }

    private enum Constants {
        static let defaultLanguage: String = "Swift"
        static let defaultTheme: String = "github-gist"
    }

    // MARK: - State properties

    private var subscriptions: Set<AnyCancellable> = []

    let textStorage = CodeAttributedString()
    private var textSize: CGSize?
    weak var userInteractionDelegate: TextViewUserInteractionProtocol?

    private var currentConfiguration: CodeBlockContentConfiguration
    /// Block content configuration
    var configuration: UIContentConfiguration {
        get { self.currentConfiguration }
        set {
            guard let configuration = newValue as? CodeBlockContentConfiguration else { return }
            self.apply(configuration: configuration)
        }
    }
    // MARK: - Views

    private lazy var textView: UITextView = {
        textStorage.language = Constants.defaultLanguage
        textStorage.highlightr.setTheme(to: Constants.defaultTheme)
        codeSelectButton.label.text = Constants.defaultLanguage

        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)

        let textContainer = NSTextContainer()
        layoutManager.addTextContainer(textContainer)

        let textView = UITextView(frame: .zero, textContainer: textContainer)
        textView.isScrollEnabled = false
        textView.delegate = self
        textStorage.highlightr.theme.boldCodeFont = .codeFont
        codeSelectButton.setText(Constants.defaultLanguage)

        return textView
    }()

    private var codeSelectButton: ButtonWithImage = {
        let button = ButtonWithImage()
        button.translatesAutoresizingMaskIntoConstraints = false

        button.label.font = UIFont.bodyFont
        button.label.textColor = MiddlewareColor.grey.color()
        let image = UIImage(named: "TextEditor/Toolbar/turn_into_arrow")
        button.setImage(image)

        return button
    }()

    private let selectionView = UIView()

    // MARK: - Life cycle

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Initializer
    init(configuration: CodeBlockContentConfiguration) {
        self.currentConfiguration = configuration
        super.init(frame: .zero)
        self.setupViews()
        self.applyNewConfiguration()
    }

    // MARK: - Setup view

    private func setupViews() {
        textView.textContainerInset = LayoutConstants.textInsets
        setupBackgroundColor()

        userInteractionDelegate = currentConfiguration.viewModel
        textView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(textView)
        addSubview(codeSelectButton)

        textView.edgesToSuperview(insets: LayoutConstants.insets)

        NSLayoutConstraint.activate([
            codeSelectButton.topAnchor.constraint(equalTo: topAnchor, constant: 13),
            codeSelectButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20)
        ])

        codeSelectButton.addAction(UIAction(handler: { [weak self] action in
            guard let codeLanguages = self?.textStorage.highlightr.supportedLanguages() else { return }

            self?.currentConfiguration.viewModel?.router.showCodeLanguageView(languages: codeLanguages) { language in
                self?.textStorage.language = language
                self?.codeSelectButton.setText(language)

                self?.currentConfiguration.viewModel?.setCodeLanguage(language)
            }
        }), for: .touchUpInside)

        selectionView.layer.cornerRadius = 6
        selectionView.layer.cornerCurve = .continuous
        selectionView.isUserInteractionEnabled = false
        selectionView.clipsToBounds = true

        addSubview(selectionView)
        selectionView.pinAllEdges(to: self, insets: LayoutConstants.selectionViewInsets)
    }

    // MARK: - Apply configuration

    private func apply(configuration: CodeBlockContentConfiguration) {
        guard currentConfiguration != configuration else { return }
        currentConfiguration = configuration
        applyNewConfiguration()
    }

    private func applyNewConfiguration() {
        currentConfiguration.viewModel?.codeBlockView = self
        codeSelectButton.setText(currentConfiguration.viewModel?.codeLanguage ?? Constants.defaultLanguage)

        if case let .text(content) = currentConfiguration.information.content {
            textView.textStorage.setAttributedString(content.attributedText)
        }

        selectionView.layer.borderWidth = 0.0
        selectionView.layer.borderColor = nil
        selectionView.backgroundColor = .clear

        if currentConfiguration.isSelected {
            selectionView.layer.borderWidth = 2.0
            selectionView.layer.borderColor = UIColor.pureAmber.cgColor
            selectionView.backgroundColor = UIColor.pureAmber.withAlphaComponent(0.1)
        }
        setupBackgroundColor()
    }

    private func setupBackgroundColor() {
        let color = MiddlewareColor(name: currentConfiguration.information.backgroundColor)?.color(background: true) ?? UIColor.lightColdGray
        textView.backgroundColor = color
    }
}

// MARK: - CodeBlockViewInteractable

extension CodeBlockContentView: CodeBlockViewInteractable {
    func languageDidChange(language: String) {
        DispatchQueue.main.async {
            self.codeSelectButton.setText(language)
            self.textStorage.language = language
        }
    }
}

extension CodeBlockContentView: UITextViewDelegate {

    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        self.currentConfiguration.viewModel?.becomeFirstResponder()
        return true
    }

    func textViewDidChange(_ textView: UITextView) {
        let contentSize = textView.intrinsicContentSize

        userInteractionDelegate?.didReceiveAction(
            .changeText(textView)
        )

        guard textSize?.height != contentSize.height else { return }
        textSize = contentSize
        self.currentConfiguration.viewModel?.blockDelegate?.blockSizeChanged()
    }
}
