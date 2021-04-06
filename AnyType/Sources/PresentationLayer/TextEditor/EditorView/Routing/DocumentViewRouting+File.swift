//
//  DocumentViewRouting+File.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 17.04.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import os
import UIKit

// MARK: FileBlocksViewsRouter
extension DocumentViewRouting {
    class FileBlocksViewsRouter: BaseCompoundRouter {
         
        // MARK: Subclassing
        override func match(action: BlocksViews.UserAction) -> BaseRouter? {
            switch action {
            case .specific(.file): return self.router(of: FileRouter.self)
            default: return nil
            }
        }
        override func defaultRouters() -> [DocumentViewRouting.BaseRouter] {
            [FileRouter()]
        }
    }
}

extension DocumentViewRouting.FileBlocksViewsRouter {
    typealias BaseRouter = DocumentViewRouting.BaseRouter
}

// MARK: FileBlocksViewsRouter / ImageRouter
extension DocumentViewRouting.FileBlocksViewsRouter {
    class FileRouter: BaseRouter {
        
        private var fileLoader: FileLoader?
        
        private func handle(action: BlocksViews.UserAction.File.FileAction) {
            switch action {
            case let .shouldShowFilePicker(model):
                self.send(event: .general(.show(CommonViews.Pickers.File.Picker.init(model.model))))
            case let .shouldShowImagePicker(model):
                self.send(event: .general(.show(CommonViews.Pickers.Picker.init(model.model))))
            case let .shouldSaveFile(model):
                self.saveFile(model: model)
            default: return
            }
        }
        
        private func saveFile(model: BlocksViews.UserAction.File.FileAction.ShouldSaveFile) {
            self.fileLoader = .init(remoteFileURL: model.filrURL)
            self.fileLoader?.loadFile(completion: { url in
                DispatchQueue.main.async {
                    let controller = UIDocumentPickerViewController(forExporting: [url], asCopy: true)
                    self.send(event: .general(.show(controller)))
                }
            })
        }
        
        override func receive(action: BlocksViews.UserAction) {
            switch action {
            case let .specific(.file(value)): self.handle(action: value)
            default: return
            }
        }
        
        
    }
}
