//
//  DocumentViewRouting+File.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 17.04.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation

// MARK: FileBlocksViewsRouter
extension DocumentViewRouting {
    class FileBlocksViewsRouter: BaseCompoundRouter {
         
        // MARK: Subclassing
        override func match(action: BlocksViews.UserAction) -> BaseRouter? {
            switch action {
            case .specific(.file): return self.router(of: ImageRouter.self)
            default: return nil
            }
        }
        override func defaultRouters() -> [DocumentViewRouting.BaseRouter] {
            [ImageRouter()]
        }
    }
}

// MARK: FileBlocksViewsRouter / ImageRouter
extension DocumentViewRouting.FileBlocksViewsRouter {
    typealias BaseRouter = DocumentViewRouting.BaseRouter
    class ImageRouter: BaseRouter {
        private func handle(action: FileBlocksViews.UserAction.ImageAction) {
            switch action {
            case let .shouldShowImagePicker(model):
                guard let documentId = model.findRoot()?.information.id else { return }
                let blockId = model.information.id
                let imagePicker: ImagePickerUIKit = .init(model: .init(documentId: documentId, blockId: blockId))
                self.send(event: .showViewController(imagePicker))
            }
        }
        
        override func receive(action: BlocksViews.UserAction) {
            switch action {
            case let .specific(.file(.image(value))): self.handle(action: value)
            default: return
            }
        }
    }
}
