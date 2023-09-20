import Services
import UIKit
import AVFoundation
import AnytypeCore

final class AudioBlockViewModel: BlockViewModelProtocol {
    private(set) var playerItem: AVPlayerItem?

    var hashable: AnyHashable { info.id }
    var info: BlockInformation { informantionProvider.info }
    let informantionProvider: BlockModelInfomationProvider
    var fileData: BlockFile? {
        guard case let .file(fileData) = info.content else { return nil }
        guard fileData.contentType == .audio else {
            anytypeAssertionFailure(
                "Wrong content type, audio expected", info: ["contentType": "\(fileData.contentType)"]
            )
            return nil
        }
        
        return fileData
    }
    let audioSessionService: AudioSessionServiceProtocol

    let showAudioPicker: (BlockId) -> ()

    // Player properties
    let audioPlayer = AnytypeSharedAudioplayer.sharedInstance
    var currentTimeInSeconds: Double = 0.0
    weak var audioPlayerView: AudioPlayerViewInput?

    init(
        informationProvider: BlockModelInfomationProvider,
        audioSessionService: AudioSessionServiceProtocol,
        showAudioPicker: @escaping (BlockId) -> ()
    ) {
        self.informantionProvider = informationProvider
        self.audioSessionService = audioSessionService
        self.showAudioPicker = showAudioPicker

        if let url = fileData?.contentUrl {
            self.playerItem = AVPlayerItem(url: url)
        }
    }

    func didSelectRowInTableView(editorEditingState: EditorEditingState) {
        if case .readonly = editorEditingState { return }
        guard let fileData = fileData else { return }
        switch fileData.state {
        case .empty, .error:
            showAudioPicker(blockId)
        case .uploading, .done:
            return
        }
    }

    func makeContentConfiguration(maxWidth width: CGFloat) -> UIContentConfiguration {
        guard let fileData = fileData else {
            return UnsupportedBlockViewModel(info: info)
                .makeContentConfiguration(maxWidth: width)
        }
        switch fileData.state {
        case .empty:
            return emptyViewConfiguration(text: Loc.Content.Audio.upload, state: .default)
        case .uploading:
            return emptyViewConfiguration(text: Loc.Content.Common.uploading, state: .uploading)
        case .error:
            return emptyViewConfiguration(text: Loc.Content.Common.error, state: .error)
        case .done:
            guard playerItem != nil else {
                return emptyViewConfiguration(text: Loc.Content.Common.error, state: .error)
            }
            audioPlayer.updateDelegate(audioId: info.id, delegate: self)
            return AudioBlockContentConfiguration(
                file: fileData,
                trackId: info.id,
                audioPlayerViewDelegate: self
            ).cellBlockConfiguration(
                dragConfiguration: .init(id: info.id),
                styleConfiguration: .init(backgroundColor: info.backgroundColor?.backgroundColor.color)
            )
        }
    }

    private func emptyViewConfiguration(text: String, state: BlocksFileEmptyViewState) -> UIContentConfiguration {
        BlocksFileEmptyViewConfiguration(
            imageAsset: .X32.video,
            text: text,
            state: state
        ).cellBlockConfiguration(
            dragConfiguration: .init(id: info.id),
            styleConfiguration: .init(backgroundColor: info.backgroundColor?.backgroundColor.color)
        )
    }
    
    func setAudioSessionCategorypPlayback() {
        audioSessionService.setCategorypPlayback()
    }
    
    func setAudioSessionCategorypPlaybackMixWithOthers() {
        audioSessionService.setCategorypPlaybackMixWithOthers()
    }
}
