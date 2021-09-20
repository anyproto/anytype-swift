//
//  AudioBlockViewModel.swift
//  Anytype
//
//  Created by Denis Batvinkin on 14.09.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import BlocksModels
import UIKit
import AVFoundation


final class AudioBlockViewModel: BlockViewModelProtocol {
    private(set) var playerItem: AVPlayerItem?
    private(set) var duration: Double?

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

    init(
        indentationLevel: Int,
        information: BlockInformation,
        fileData: BlockFile,
        contextualMenuHandler: DefaultContextualMenuHandler,
        showAudioPicker: @escaping (BlockId) -> (),
        downloadAudio: @escaping (FileId) -> ()
    ) {
        self.indentationLevel = indentationLevel
        self.information = information
        self.fileData = fileData
        self.contextualMenuHandler = contextualMenuHandler
        self.showAudioPicker = showAudioPicker
        self.downloadAudio = downloadAudio

        if let url = UrlResolver.resolvedUrl(.file(id: fileData.metadata.hash)) {
            self.playerItem = AVPlayerItem(url: url)
            self.duration = playerItem?.asset.duration.seconds
        }
    }

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
            guard let playerItem = playerItem else {
                return emptyViewConfiguration(state: .error)
            }
            return AudioBlockContentConfiguration(file: fileData, playerItem: playerItem, duration: duration ?? 0)
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
