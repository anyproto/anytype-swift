import BlocksModels
import UIKit
import AVFoundation


final class AudioBlockViewModel: BlockViewModelProtocol {
    private(set) var playerItem: AVPlayerItem?

    var hashable: AnyHashable { [ info ] as [AnyHashable] }

    let info: BlockInformation
    let fileData: BlockFile

    let showAudioPicker: (BlockId) -> ()
    let downloadAudio: (FileId) -> ()

    // Player properties
    let audioPlayer = AnytypeSharedAudioplayer.sharedInstance
    var currentTimeInSeconds: Double = 0.0
    weak var audioPlayerView: AudioPlayerViewInput?

    init(
        info: BlockInformation,
        fileData: BlockFile,
        showAudioPicker: @escaping (BlockId) -> (),
        downloadAudio: @escaping (FileId) -> ()
    ) {
        self.info = info
        self.fileData = fileData
        self.showAudioPicker = showAudioPicker
        self.downloadAudio = downloadAudio

        if let url = UrlResolver.resolvedUrl(.file(id: fileData.metadata.hash)) {
            self.playerItem = AVPlayerItem(url: url)
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

    func makeContentConfiguration(maxWidth _ : CGFloat) -> UIContentConfiguration {
        switch fileData.state {
        case .empty:
            return emptyViewConfiguration(state: .default)
        case .uploading:
            return emptyViewConfiguration(state: .uploading)
        case .error:
            return emptyViewConfiguration(state: .error)
        case .done:
            guard playerItem != nil else {
                return emptyViewConfiguration(state: .error)
            }
            audioPlayer.updateDelegate(audioId: info.id, delegate: self)
            return AudioBlockContentConfiguration(
                file: fileData,
                trackId: info.id,
                audioPlayerViewDelegate: self
            ).asCellBlockConfiguration
        }
    }

    private func emptyViewConfiguration(state: BlocksFileEmptyViewState) -> UIContentConfiguration {
        BlocksFileEmptyViewConfiguration(
            image: UIImage.blockFile.empty.video,
            text: "Upload a audio".localized,
            state: state
        ).asCellBlockConfiguration
    }
}
