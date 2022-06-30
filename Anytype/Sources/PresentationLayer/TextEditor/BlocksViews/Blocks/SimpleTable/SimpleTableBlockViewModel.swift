import BlocksModels
import Combine
import UIKit
import AnytypeCore

struct SimpleTableBlockViewModel: BlockViewModelProtocol {
    let info: BlockInformation

    var hashable: AnyHashable {
        [
            [info.id],
            textBlocks.map { $0.content }
        ].compactMap { $0 } as [AnyHashable]
    }

    private let textBlocks: [TextBlockViewModel]
    private let blockDelegate: BlockDelegate

    private weak var relativePositionProvider: RelativePositionProvider?

    init(
        info: BlockInformation,
        textBlocks: [TextBlockViewModel],
        blockDelegate: BlockDelegate,
        relativePositionProvider: RelativePositionProvider?
    ) {
        self.info = info
        self.textBlocks = textBlocks
        self.blockDelegate = blockDelegate
        self.relativePositionProvider = relativePositionProvider
    }

    func makeContentConfiguration(maxWidth: CGFloat) -> UIContentConfiguration {
        let widths: [CGFloat] = [400, 150, 100, 200, 300]

        let textBlocksChunked = textBlocks.chunked(into: widths.count)

        let items = textBlocksChunked.map { sections -> [SimpleTableBlockProtocol] in
            return sections.map { row -> SimpleTableBlockProtocol in
                let tableBlock = SimpleTableCellConfiguration(
                    item: row.textBlockContentConfiguration(),
                    backgroundColor: row.info.backgroundColor.map { UIColor.Background.uiColor(from: $0) }
                )

                return tableBlock
            }
        }

        let contentConfiguration = SimpleTableBlockContentConfiguration(
            widths: widths,
            items: items,
            blockDelegate: blockDelegate,
            relativePositionProvider: relativePositionProvider
        )

        return CellBlockConfiguration(
            blockConfiguration: contentConfiguration,
            indentationSettings: nil,
            dragConfiguration: nil
        )
    }

    func didSelectRowInTableView(editorEditingState: EditorEditingState) {}
}
