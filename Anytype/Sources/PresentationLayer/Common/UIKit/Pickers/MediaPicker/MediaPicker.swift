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
        guard let chosen = results.first?.itemProvider else {
            self.dismiss(animated: true)
            return
        }
        
        chosen.loadFileRepresentation(
            forTypeIdentifier: viewModel.type.typeIdentifier
        ) { [weak self] url, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
            
            self.viewModel.process(url)
        }
    }
    
}
