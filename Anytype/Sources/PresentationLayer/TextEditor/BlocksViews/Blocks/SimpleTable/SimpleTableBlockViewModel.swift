import BlocksModels
import Combine
import UIKit
import AnytypeCore

struct SimpleTableBlockViewModel: BlockViewModelProtocol {
    let info: BlockInformation
    let models: [[SimpleTableBlockProtocol]]

    var hashable: AnyHashable {
        [info.id, modelsHashable] as [AnyHashable]
    }

    private let blockDelegate: BlockDelegate

    private weak var relativePositionProvider: RelativePositionProvider?

    init(
        info: BlockInformation,
        models: [[SimpleTableBlockProtocol]],
        blockDelegate: BlockDelegate,
        relativePositionProvider: RelativePositionProvider?
    ) {
        self.info = info
        self.models = models
        self.blockDelegate = blockDelegate
        self.relativePositionProvider = relativePositionProvider

        self.modelsHashable = models.hashable
    }

    private let modelsHashable: AnyHashable

    func makeContentConfiguration(maxWidth: CGFloat) -> UIContentConfiguration {
        let numberOfColumns = models.first?.count ?? 0

        var widths = [CGFloat]()
        for _ in 0..<numberOfColumns {
            widths.append(170)
        }

        let contentConfiguration = SimpleTableBlockContentConfiguration(
            widths: widths,
            items: models,
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
