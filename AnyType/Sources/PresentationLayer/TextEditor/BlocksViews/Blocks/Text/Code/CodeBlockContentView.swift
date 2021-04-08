//
//  CodeBlockContentView.swift
//  AnyType
//
//  Created by Denis Batvinkin on 05.04.2021.
//  Copyright © 2021 AnyType. All rights reserved.
//

import UIKit

/// Content view for code block
final class CodeBlockContentView: UIView & UIContentView {

    // MARK: - Constants

    private enum Constants {
        static let insets: UIEdgeInsets = .init(top: 1, left: 20, bottom: 1, right: 20)
    }

    // MARK: - Properties
    private let textView: TextView.UIKitTextView = .init()
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
        self.addSubview(textView)

        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: Constants.insets.left),
            textView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -Constants.insets.right),
            textView.topAnchor.constraint(equalTo: self.topAnchor, constant: Constants.insets.top),
            textView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -Constants.insets.bottom),
        ])

        self.textView.textView.font = .bodyFont
        self.textView.textView?.defaultFontColor = .textColor
    }

    // MARK: - Apply configuration

    private func apply(configuration: CodeBlockContentConfiguration) {
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
            self.currentConfiguration.contextMenuHolder?.refreshTextViewModel(textViewModel)
        }

        typealias ColorConverter = MiddlewareModelsModule.Parsers.Text.Color.Converter
        self.textView.backgroundColor = ColorConverter.asModel(self.currentConfiguration.information.backgroundColor)
    }
}
