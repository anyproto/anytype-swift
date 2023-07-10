import Services
import UIKit
import AVFoundation
import AnytypeCore


final class AudioBlockViewModel: BlockViewModelProtocol {
    private(set) var playerItem: AVPlayerItem?

    var hashable: AnyHashable { [ info ] as [AnyHashable] }

    let info: BlockInformation
    let fileData: BlockFile
    let audioSessionService: AudioSessionServiceProtocol

    let showAudioPicker: (BlockId) -> ()

    // Player properties
    let audioPlayer = AnytypeSharedAudioplayer.sharedInstance
    var currentTimeInSeconds: Double = 0.0
    weak var audioPlayerView: AudioPlayerViewInput?

    init(
        info: BlockInformation,
        fileData: BlockFile,
        audioSessionService: AudioSessionServiceProtocol,
        showAudioPicker: @escaping (BlockId) -> ()
    ) {
        self.info = info
        self.fileData = fileData
        self.audioSessionService = audioSessionService
        self.showAudioPicker = showAudioPicker

        if let url = fileData.metadata.contentUrl {
            self.playerItem = AVPlayerItem(url: url)
        }
    }

    func didSelectRowInTableView(editorEditingState: EditorEditingState) {
        if case .locked = editorEditingState { return }
        switch fileData.state {
        case .empty, .error:
            showAudioPicker(blockId)
        case .uploading, .done:
            return
        }
    }

    func makeContentConfiguration(maxWidth _ : CGFloat) -> UIContentConfiguration {
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
                indentationSettings: .init(with: info.configurationData),
                dragConfiguration: .init(id: info.id)
            )
        }
    }

    private func emptyViewConfiguration(text: String, state: BlocksFileEmptyViewState) -> UIContentConfiguration {
        BlocksFileEmptyViewConfiguration(
            imageAsset: .X32.video,
            text: text,
            state: state
        ).cellBlockConfiguration(
            indentationSettings: .init(with: info.configurationData),
            dragConfiguration: .init(id: info.id)
        )
    }
    
    func setAudioSessionCategorypPlayback() {
        if FeatureFlags.fixAudioSession {
            audioSessionService.setCategorypPlayback()
        } else {
            audioSessionService.setAudioSessionActiveLegacy()
        }
    }
    
    func setAudioSessionCategorypPlaybackMixWithOthers() {
        if FeatureFlags.fixAudioSession {
            audioSessionService.setCategorypPlaybackMixWithOthers()
        }
    }
}
