//
//  CommonViews+Pickers+File+UIKit.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 20.07.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import UIKit
import UniformTypeIdentifiers

// MARK: - Custom
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

// MARK: - Appearance
// We need this to change appearance for UINavigationBar in UIImagePickerController
// This class is intended to be used as-is and does not support subclassing. The view hierarchy for this class is private and must not be modified
extension UIKitPickerViewController {
    private func applyAppearanceForNavigationBar() {
        // Save color to reset it back later
        self.barTintColor = UINavigationBar.appearance().tintColor
        UINavigationBar.appearance().tintColor = .orange
    }
    private func resetAppearanceForNavigationBar() {
        UINavigationBar.appearance().tintColor = self.barTintColor
    }
}

// MARK: - Picker
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

// MARK: Appearance
extension Picker {
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
private extension Picker {
    func createPickerController() -> UIViewController {
        let picker = UIKitPickerViewController(forOpeningContentTypes: self.viewModel.types, asCopy: true)
        picker.allowsMultipleSelection = false
        picker.delegate = self
        return picker
    }
}

// MARK: View Lifecycle
extension Picker {
    override func viewDidLoad() {
        super.viewDidLoad()
        applyAppearanceForNavigationBar()
        let pickerViewController = createPickerController()
        embedChild(pickerViewController)
        pickerViewController.view.pinAllEdges(to: view)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        applyAppearanceForNavigationBar()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        resetAppearanceForNavigationBar()
    }
}

// MARK: - ViewModel
extension Picker {
    final class ViewModel: BaseFilePickerViewModel {
        private(set) var types: [UTType] = [
            .item
        ]

        init(types: [UTType] = [.item]) {
            self.types = types
        }
    }
}

// MARK: - UIDocumentPickerDelegate
extension Picker: UIDocumentPickerDelegate {
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        self.viewModel.process(urls)
        controller.dismiss(animated: true, completion: nil)
    }
}
