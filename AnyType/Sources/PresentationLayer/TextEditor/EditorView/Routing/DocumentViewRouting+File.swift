//
//  DocumentViewRouting+File.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 17.04.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import UIKit

// MARK: FileBlocksViewsRouter
extension DocumentViewRouting {
    class FileBlocksViewsRouter: BaseCompoundRouter {
         
        // MARK: Subclassing
        override func match(action: BlocksViews.UserAction) -> BaseRouter? {
            switch action {
            case .specific(.file(.file)): return self.router(of: FileRouter.self)
            case .specific(.file(.image)): return self.router(of: ImageRouter.self)
            default: return nil
            }
        }
        override func defaultRouters() -> [DocumentViewRouting.BaseRouter] {
            [ImageRouter(), FileRouter()]
        }
    }
}

extension DocumentViewRouting.FileBlocksViewsRouter {
    typealias BaseRouter = DocumentViewRouting.BaseRouter
}

// MARK: FileBlocksViewsRouter / ImageRouter
extension DocumentViewRouting.FileBlocksViewsRouter {
    class FileRouter: BaseRouter {
        private func handle(action: BlocksViews.UserAction.File.UserAction.FileAction) {
            switch action {
            case let .shouldShowFilePicker(model):
                self.send(event: .general(.show(CommonViews.Pickers.File.Picker.init(model.model))))
            default: return
            }
        }
        
        override func receive(action: BlocksViews.UserAction) {
            switch action {
            case let .specific(.file(.file(value))): self.handle(action: value)
            default: return
            }
        }
    }
}

// MARK: FileBlocksViewsRouter / ImageRouter
extension DocumentViewRouting.FileBlocksViewsRouter {
    class ImageRouter: BaseRouter {
        private func handle(action: BlocksViews.UserAction.File.UserAction.ImageAction) {
            switch action {
            case let .shouldShowImagePicker(model):
                self.send(event: .general(.show(CommonViews.Pickers.Image.Picker.init(model.model))))
            default: return
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
