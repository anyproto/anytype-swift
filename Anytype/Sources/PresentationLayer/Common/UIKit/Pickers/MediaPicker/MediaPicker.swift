//
//  MediaPicker.swift
//  Anytype
//
//  Created by Dmitry Lobanov on 21.10.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import PhotosUI

final class MediaPicker: UIViewController {
    
    private let viewModel: ViewModel
    
    private var barTintColor: UIColor?
    
    // MARK: - Initializer
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Override functions
    
    override func loadView() {
        super.loadView()
        
        configureView()
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

// MARK: - Appearance

private extension MediaPicker {
    
    func configureView() {
        var configuration = PHPickerConfiguration()
        configuration.filter = viewModel.type.filter
        configuration.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        
        embedChild(picker)
        picker.view.pinAllEdges(to: view)
    }
    
    func applyAppearanceForNavigationBar() {
        // Save color to reset it back later
        self.barTintColor = UINavigationBar.appearance().tintColor
        
        UINavigationBar.appearance().tintColor = .orange
    }
    
    func resetAppearanceForNavigationBar() {
        UINavigationBar.appearance().tintColor = self.barTintColor
    }
    
}

// MARK: - UIDocumentPickerDelegate
extension MediaPicker: PHPickerViewControllerDelegate {
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        /// We should load photo via item provider.
        self.dismiss(animated: true)
        
        if let chosen = results.first?.itemProvider {
            self.process(chosen: chosen)
        }
    }
    
}

// MARK: - Process

private extension MediaPicker {
    
    func process(chosen itemProvider: NSItemProvider) {
        itemProvider.loadFileRepresentation(
            forTypeIdentifier: viewModel.type.typeIdentifier
        ) { [weak self] url, error in
            
            self?.viewModel.process(url)
        }
    }
    
}
