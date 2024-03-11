import Services
import UIKit
import AnytypeCore

struct DividerBlockViewModel: BlockViewModelProtocol {
    var hashable: AnyHashable { info.id }
    var info: BlockInformation { blockInformationProvider.info }
    
    private let blockInformationProvider: BlockModelInfomationProvider

    init(blockInformationProvider: BlockModelInfomationProvider) {
        self.blockInformationProvider = blockInformationProvider
    }
    
    func makeContentConfiguration(maxWidth width : CGFloat) -> UIContentConfiguration {
        guard case let .divider(dividerContent) = info.content else {
            anytypeAssertionFailure("DividerBlockViewModel blockInformation has wrong content type")
            return UnsupportedBlockViewModel(info: info)
                .makeContentConfiguration(maxWidth: width)
        }
        
        return DividerBlockContentConfiguration(content: dividerContent)
            .cellBlockConfiguration(
                dragConfiguration: .init(id: info.id),
                styleConfiguration: .init(backgroundColor: info.backgroundColor?.backgroundColor.color)
            )
    }
    
    func didSelectRowInTableView(editorEditingState: EditorEditingState) {}
}
