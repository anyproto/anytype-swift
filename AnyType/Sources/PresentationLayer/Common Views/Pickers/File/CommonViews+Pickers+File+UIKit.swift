//
//  CommonViews+Pickers+File+UIKit.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 20.07.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import UIKit
import UniformTypeIdentifiers

fileprivate typealias Namespace = CommonViews.Pickers.File

extension CommonViews.Pickers {
    enum File {}
}

// MARK: - Custom
private extension Namespace.Picker {
    class UIKitPickerViewController: UIDocumentPickerViewController {
        var barTintColor: UIColor?
        override func viewDidLoad() {
            super.viewDidLoad()
            self.applyAppearanceForNavigationBar()
        }
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            self.applyAppearanceForNavigationBar()
        }
        override func viewDidDisappear(_ animated: Bool) {
            super.viewDidDisappear(animated)
            self.resetAppearanceForNavigationBar()
        }
    }
}

// MARK: - Appearance
// We need this to change appearance for UINavigationBar in UIImagePickerController
// This class is intended to be used as-is and does not support subclassing. The view hierarchy for this class is private and must not be modified
extension Namespace.Picker.UIKitPickerViewController {
    private func applyAppearanceForNavigationBar() {
        // Save color to reset it back later
        self.barTintColor = UINavigationBar.appearance().tintColor
        UINavigationBar.appearance().tintColor = .orange
    }
    private func resetAppearanceForNavigationBar() {
        UINavigationBar.appearance().tintColor = self.barTintColor
    }
}


private extension Namespace.Picker.UIKitPickerViewController {
    private func configureNavigation(_ navigationItem: UINavigationItem) {
        let appearance = UINavigationBarAppearance()
        
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .red
        appearance.titleTextAttributes = [.foregroundColor: UIColor.lightText] // With a red background, make the title more readable.
        appearance.shadowColor = .clear
        
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.compactAppearance = appearance // For iPhone small navigation bar in landscape.
        
        // Make all buttons with green text.
        let buttonAppearance = UIBarButtonItemAppearance()
        buttonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.systemGray]
        navigationItem.standardAppearance?.buttonAppearance = buttonAppearance
        navigationItem.compactAppearance?.buttonAppearance = buttonAppearance // For iPhone small navigation bar in landscape.
        
        navigationItem.standardAppearance?.backButtonAppearance = buttonAppearance
        
        // Make the done style button with yellow text.
        let doneButtonAppearance = UIBarButtonItemAppearance()
        doneButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.systemGray]
        navigationItem.standardAppearance?.doneButtonAppearance = doneButtonAppearance
        navigationItem.compactAppearance?.doneButtonAppearance = doneButtonAppearance // For iPhone small navigation bar in landscape.
    }

}

// MARK: - Picker
extension Namespace {
    class Picker: UIViewController {
        var viewModel: ViewModel
        var barTintColor: UIColor?
        
        init(_ model: ViewModel) {
            self.viewModel = model
            super.init(nibName: nil, bundle: nil)
        }
        
        required public init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

// MARK: Appearance
extension Namespace.Picker {
    private func applyAppearanceForNavigationBar() {
        // Save color to reset it back later
        self.barTintColor = UINavigationBar.appearance().tintColor
        UINavigationBar.appearance().tintColor = .orange
    }
    private func resetAppearanceForNavigationBar() {
        UINavigationBar.appearance().tintColor = self.barTintColor
    }
}

// MARK: Controller
private extension Namespace.Picker {
    func createPickerController() -> UIViewController {
        let picker = UIKitPickerViewController.init(forOpeningContentTypes: self.viewModel.types, asCopy: true)
        picker.allowsMultipleSelection = false
        picker.delegate = self
        return picker
    }
    
    func setupUIElements() {
        let controller = self.createPickerController()

        if let view = controller.view {
            self.view.addSubview(view)
        }

        self.addChild(controller)
        self.addLayout(for: controller)
        self.didMove(toParent: controller)
    }

    func addLayout(for controller: UIViewController) {
        if let view = controller.view, let superview = view.superview {
            NSLayoutConstraint.activate([
                view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                view.topAnchor.constraint(equalTo: superview.topAnchor),
                view.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
            ])
        }
    }
}

// MARK: View Lifecycle
extension Namespace.Picker {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.applyAppearanceForNavigationBar()
        self.setupUIElements()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.applyAppearanceForNavigationBar()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.resetAppearanceForNavigationBar()
    }
}

// MARK: - ViewModel
extension Namespace.Picker {
    class ViewModel {        
        // TODO: Move to Mime Type Provider.
        private(set) var types: [UTType] = [
            .text,
            .spreadsheet,
            .presentation,
            .pdf,
            .image,
            .audio,
            .video,
            .archive
        ]
        @Published var resultInformation: ResultInformation?
        
        init() {}
        
        func process(_ information: [URL]) {
            guard !information.isEmpty else { return }
            let url = information[0]
            self.resultInformation = .init(documentUrl: url)
        }
    }
}

// MARK: - Information
extension Namespace.Picker {
    struct ResultInformation {
//        var documentsUrls: [URL] = []
        var documentUrl: URL
        var filePath: String { self.documentUrl.relativePath }
    }
}

// MARK: - UIDocumentPickerDelegate
extension Namespace.Picker: UIDocumentPickerDelegate {
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        self.viewModel.process(urls)
        controller.dismiss(animated: true, completion: nil)
    }
}
