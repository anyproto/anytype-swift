//
//  ImagePickerUIKit.swift
//  AnyType
//
//  Created by Valentine Eyiubolu on 3/30/20.
//  Copyright © 2020 AnyType. All rights reserved.
//

import UIKit
import CoreServices

// MARK: - ImagePickerUIKit
open class ImagePickerUIKit: UIViewController {
    // MARK: Variables
    var model: ViewModel
    var barTintColor: UIColor?

    // MARK: Native ImagePicker
    private func createPickerController() -> UIImagePickerController {
        let controller: UIImagePickerController = .init()
        controller.allowsEditing = false
        controller.mediaTypes = [kUTTypeImage as String]
        controller.delegate = self
        controller.sourceType = .photoLibrary
        return controller
    }
    
    // MARK: Initialization
    init(model: ViewModel) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - View Lifecycle
extension ImagePickerUIKit {
    private func setupUIElements() {
        let controller = self.createPickerController()
        
        if let view = controller.view {
            self.view.addSubview(view)
        }
        
        self.addChild(controller)
        self.addLayout(for: controller)
        self.didMove(toParent: controller)
    }
    
    private func addLayout(for controller: UIViewController) {
        if let view = controller.view, let superview = view.superview {
            NSLayoutConstraint.activate([
                view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                view.topAnchor.constraint(equalTo: superview.topAnchor),
                view.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
            ])
        }
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUIElements()
        self.applyAppearanceForNavigationBar()
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.resetAppearanceForNavigationBar()
    }

}

// MARK: - Appearance
// We need this to change appearance for UINavigationBar in UIImagePickerController
// This class is intended to be used as-is and does not support subclassing. The view hierarchy for this class is private and must not be modified
extension ImagePickerUIKit {
    private func applyAppearanceForNavigationBar() {
        // Save color to reset it back later
        self.barTintColor = UINavigationBar.appearance().tintColor
        
        UINavigationBar.appearance().tintColor = nil
    }
    private func resetAppearanceForNavigationBar() {
        UINavigationBar.appearance().tintColor = self.barTintColor
    }
}

// MARK: - ResultInformation
extension ImagePickerUIKit {
    struct ResultInformation {
        var imageURL: URL
        var blockId: String
        var documentId: String
        var filePath: String { self.imageURL.relativePath }
    }
}

// MARK: - ViewModel
// TODO: Remove documentId/blockId(?)
extension ImagePickerUIKit {
    class ViewModel {
        private var documentId: String
        private var blockId: String
        @Published var resultInformation: ResultInformation?
        
        init(documentId: String, blockId: String) {
            self.documentId = documentId
            self.blockId = blockId
        }
        
        func process(information: [UIImagePickerController.InfoKey: Any]) {
            guard let imageURL = information[.imageURL] as? URL else { return }
            self.resultInformation = .init(imageURL: imageURL, blockId: self.blockId, documentId: self.documentId)
        }
    }
}

// MARK: - UIImagePickerControllerDelegate
extension ImagePickerUIKit: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        self.model.process(information: info)
        picker.dismiss(animated: true, completion: nil)
    }
    
}
