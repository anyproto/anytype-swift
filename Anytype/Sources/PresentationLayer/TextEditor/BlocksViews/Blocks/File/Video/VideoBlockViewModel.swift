import Services
import UIKit
import AnytypeCore

struct VideoBlockViewModel: BlockViewModelProtocol {    
    nonisolated var hashable: AnyHashable { info.id }
    nonisolated var info: BlockInformation { informantionProvider.info }
    let informantionProvider: BlockModelInfomationProvider
    var fileData: BlockFile? {
        guard case let .file(fileData) = info.content else { return nil }
        guard fileData.contentType == .video else {
            anytypeAssertionFailure(
                "Wrong content type, image expected", info: ["contentType": "\(fileData.contentType)"]
            )
            return nil
        }
        
        return fileData
    }

    let audioSessionService: any AudioSessionServiceProtocol
    let showVideoPicker: (String) -> ()
    
    func didSelectRowInTableView(editorEditingState: EditorEditingState) {
        if case .readonly = editorEditingState { return }
        guard let fileData else { return }

        switch fileData.state {
        case .empty, .error:
            showVideoPicker(blockId)
        case .uploading, .done:
            return
        }
    }
    
    func makeContentConfiguration(maxWidth: CGFloat) -> any UIContentConfiguration {
        guard let fileData else {
            return UnsupportedBlockViewModel(info: info).makeContentConfiguration(maxWidth: maxWidth)
        }
        
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
                dragConfiguration: .init(id: info.id),
                styleConfiguration: CellStyleConfiguration(backgroundColor: info.backgroundColor?.backgroundColor.color)
            )
        }
    }
    
    private func emptyViewConfiguration(text: String, state: BlocksFileEmptyViewState) -> some UIContentConfiguration {
        BlocksFileEmptyViewConfiguration(
            imageAsset: .X32.video,
            text: text,
            state: state
        ).cellBlockConfiguration(
            dragConfiguration: .init(id: info.id),
            styleConfiguration: CellStyleConfiguration(backgroundColor: info.backgroundColor?.backgroundColor.color)
        )
    }
}
