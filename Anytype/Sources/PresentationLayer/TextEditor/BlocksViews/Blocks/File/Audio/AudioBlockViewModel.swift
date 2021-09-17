//
//  AudioBlockViewModel.swift
//  Anytype
//
//  Created by Denis Batvinkin on 14.09.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import BlocksModels
import UIKit


struct AudioBlockViewModel: BlockViewModelProtocol {
    var upperBlock: BlockModelProtocol?

    var hashable: AnyHashable {
        [
            indentationLevel,
            information
        ] as [AnyHashable]
    }

    let indentationLevel: Int
    let information: BlockInformation
    let fileData: BlockFile

    let contextualMenuHandler: DefaultContextualMenuHandler
    let showAudioPicker: (BlockId) -> ()
    let downloadAudio: (FileId) -> ()

    func didSelectRowInTableView() {
        switch fileData.state {
        case .empty, .error:
            showAudioPicker(blockId)
        case .uploading, .done:
            return
        }
    }

    func makeContextualMenu() -> [ContextualMenu] {
        BlockFileContextualMenuBuilder.contextualMenu(fileData: fileData)
    }

    func handle(action: ContextualMenu) {
        switch action {
        case .replace:
            showAudioPicker(blockId)
        case .download:
            downloadAudio(fileData.metadata.hash)
        default:
            contextualMenuHandler.handle(action: action, info: information)
        }
    }

    func makeContentConfiguration(maxWidth _ : CGFloat) -> UIContentConfiguration {
        switch fileData.state {
        case .empty:
            return emptyViewConfiguration(state: .default)
        case .uploading:
            return emptyViewConfiguration(state: .uploading)
        case .error:
            return emptyViewConfiguration(state: .error)
        case .done:
            return AudioBlockContentConfiguration(fileData: fileData)
        }
    }

    private func emptyViewConfiguration(state: BlocksFileEmptyViewState) -> UIContentConfiguration {
        BlocksFileEmptyViewConfiguration(
            image: UIImage.blockFile.empty.video,
            text: "Upload a audio".localized,
            state: state
        )
    }
}
