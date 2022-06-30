import BlocksModels
import UIKit

struct VideoBlockViewModel: BlockViewModelProtocol {    
    var hashable: AnyHashable { [ info ] as [AnyHashable] }
    
    let info: BlockInformation
    let fileData: BlockFile
    
    let showVideoPicker: (BlockId) -> ()
    
    func didSelectRowInTableView(editorEditingState: EditorEditingState) {
        if case .locked = editorEditingState { return }

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
            return emptyViewConfiguration(state: .default)
        case .uploading:
            return emptyViewConfiguration(state: .uploading)
        case .error:
            return emptyViewConfiguration(state: .error)
        case .done:
            return VideoBlockConfiguration(file: fileData).cellBlockConfiguration(
                indentationSettings: .init(with: info.configurationData),
                dragConfiguration: .init(id: info.id)
            )
        }
    }
    
    private func emptyViewConfiguration(state: BlocksFileEmptyViewState) -> UIContentConfiguration {
        BlocksFileEmptyViewConfiguration(
            imageName: EmptyFileIconConstants.video,
            text: "Upload a video".localized,
            state: state
        ).cellBlockConfiguration(
                indentationSettings: .init(with: info.configurationData),
                dragConfiguration: .init(id: info.id)
            )
    }
}
