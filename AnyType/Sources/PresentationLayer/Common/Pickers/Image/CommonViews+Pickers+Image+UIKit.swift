//
//  CommonViews+Pickers+Image+UIKit.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 21.10.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import PhotosUI

fileprivate typealias Namespace = CommonViews.Pickers.Image

extension CommonViews.Pickers {
    enum Image {}
}

// MARK: - Custom
private extension Namespace.Picker {
    typealias UIKitPickerViewController = PHPickerViewController
}

// MARK: - FilePicker

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
private extension Namespace.Picker {
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
        // TODO: Move to Mime Type Provider.
        var configuration: PHPickerConfiguration = .init()
        configuration.filter = .images
        configuration.selectionLimit = 1
        let picker = UIKitPickerViewController.init(configuration: configuration)
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
        fileprivate var types: [UTType] = [.image]
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
        var documentUrl: URL
        var filePath: String { self.documentUrl.relativePath }
    }
}

// MARK: - Process
extension Namespace.Picker {
    func process(chosen itemProvider: NSItemProvider) {
        if self.viewModel.types.map(\.identifier).first(where: itemProvider.hasItemConformingToTypeIdentifier) != nil {
            itemProvider.loadFileRepresentation(forTypeIdentifier: self.viewModel.types[0].identifier) { [weak self] (value, error) in
                self?.viewModel.process([value].compactMap({$0}))
            }
        }
    }
}

// MARK: - UIDocumentPickerDelegate
extension Namespace.Picker: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        // do something
        /// We should load photo via item provider.
        self.dismiss(animated: true)
        if let chosen = results.first?.itemProvider {
            self.process(chosen: chosen)
        }
    }
}
