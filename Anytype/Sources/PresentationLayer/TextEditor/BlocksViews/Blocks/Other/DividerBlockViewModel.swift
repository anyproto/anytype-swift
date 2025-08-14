import Services
import UIKit
import AnytypeCore

struct DividerBlockViewModel: BlockViewModelProtocol {
    let className = "DividerBlockViewModel"
    nonisolated var info: BlockInformation { blockInformationProvider.info }
    
    private let blockInformationProvider: BlockModelInfomationProvider

    init(blockInformationProvider: BlockModelInfomationProvider) {
        self.blockInformationProvider = blockInformationProvider
    }
    
    func makeContentConfiguration(maxWidth width : CGFloat) -> any UIContentConfiguration {
        guard case let .divider(dividerContent) = info.content else {
            anytypeAssertionFailure("DividerBlockViewModel blockInformation has wrong content type")
            return UnsupportedBlockViewModel(info: info)
                .makeContentConfiguration(maxWidth: width)
        }
        
        return DividerBlockContentConfiguration(content: dividerContent)
            .cellBlockConfiguration(
                dragConfiguration: .init(id: info.id),
                styleConfiguration: CellStyleConfiguration(backgroundColor: info.backgroundColor?.backgroundColor.color)
            )
    }
    
    func didSelectRowInTableView(editorEditingState: EditorEditingState) {}
}
