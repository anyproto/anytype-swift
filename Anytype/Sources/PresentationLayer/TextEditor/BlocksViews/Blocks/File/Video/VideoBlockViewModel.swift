import Services
import UIKit

struct VideoBlockViewModel: BlockViewModelProtocol {    
    var hashable: AnyHashable { [ info ] as [AnyHashable] }
    
    let info: BlockInformation
    let fileData: BlockFile
    let audioSessionService: AudioSessionServiceProtocol
    
    let showVideoPicker: (BlockId) -> ()
    
    func didSelectRowInTableView(editorEditingState: EditorEditingState) {
        if case .readonly = editorEditingState { return }

        switch fileData.state {
        case .empty, .error:
            showVideoPicker(blockId)
        case .uploading, .done:
            return
        }
    }
    
    func makeContentConfiguration(maxWidth _ : CGFloat) -> UIContentConfiguration {
        switch fileData.state {
        case .empty:
            return emptyViewConfiguration(text: Loc.Content.Video.upload, state: .default)
        case .uploading:
            return emptyViewConfiguration(text: Loc.Content.Common.uploading, state: .uploading)
        case .error:
            return emptyViewConfiguration(text: Loc.Content.Common.error, state: .error)
        case .done:
            return VideoBlockConfiguration(
                file: fileData,
                action: { status in
                    guard let status else { return }
                    switch status {
                    case .playing:
                        audioSessionService.setCategorypPlayback()
                    case .paused:
                        audioSessionService.setCategorypPlaybackMixWithOthers()
                    }
                }
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
}
