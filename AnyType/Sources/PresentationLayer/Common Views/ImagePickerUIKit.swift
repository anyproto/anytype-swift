//
//  ImagePickerUIKit.swift
//  AnyType
//
//  Created by Valentine Eyiubolu on 3/30/20.
//  Copyright © 2020 AnyType. All rights reserved.
//

import UIKit

//TODO: Better to change class to UIViewController!
open class ImagePickerUIKit: NSObject {
    
    static let `default`: ImagePickerUIKit = .init()
    
    struct ResultInformation {
        var imageURL: URL
        var blockID: String
        var rootID: String
    }
    
    @Published var resultInformation: ResultInformation?
    
    private let pickerController: UIImagePickerController
    
    private var rootID: String?
    private var blockID: String?

    public override init() {
        self.pickerController = UIImagePickerController()

        super.init()
        
        self.pickerController.allowsEditing = false
        self.pickerController.mediaTypes = ["public.image"]
        self.pickerController.delegate = self
    }
    
    public func present(presentationController: UIViewController, blockID: String, rootID: String) -> Self {
        self.blockID = blockID
        self.rootID = rootID
        self.pickerController.sourceType = .photoLibrary
        self.pickerController.delegate = self
        presentationController.present(self.pickerController, animated: true)
        
        return self
    }
    
}

extension ImagePickerUIKit: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let imageURL = info[.imageURL] as? URL , let block = self.blockID , let root = self.rootID else {
            return picker.dismiss(animated: true, completion: nil)
        }
        
        self.resultInformation = .init(imageURL: imageURL, blockID: block, rootID: root)
        picker.dismiss(animated: true, completion: nil)
    }
    
}
