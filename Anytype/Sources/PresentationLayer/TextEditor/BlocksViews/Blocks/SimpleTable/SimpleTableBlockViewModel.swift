import BlocksModels
import Combine
import UIKit

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
    private var cancellables: [AnyCancellable]
    private let resetSubject: PassthroughSubject<Void, Never>
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
        self.cancellables = [AnyCancellable]()

        let resetSubject = PassthroughSubject<Void, Never>()
        self.resetSubject = resetSubject

        self.cancellables = textBlocks.map { textBlockViewModel -> AnyCancellable in
            textBlockViewModel.setNeedsLayoutSubject.eraseToAnyPublisher().sink { _ in
                resetSubject.send(())
                blockDelegate.textBlockSetNeedsLayout()
            }
        }
    }

    func makeContentConfiguration(maxWidth: CGFloat) -> UIContentConfiguration {
        let contentConfigurations = textBlocks.enumerated().map { item -> SimpleTableCellConfiguration in
            SimpleTableCellConfiguration(
                item: item.element.textBlockContentConfiguration(),
                backgroundColor: item.element.info.backgroundColor.map { UIColor.Background.uiColor(from: $0) }
            )
        }

        let widths: [CGFloat] = [400, 150, 100, 200, 300]
        let configurations = contentConfigurations.chunked(into: widths.count)

        return SimpleTableBlockContentConfiguration(
            widths: widths,
            items: configurations,
            relativePositionProvider: relativePositionProvider,
            resetPublisher: resetSubject.eraseToAnyPublisher(),
            heightDidChanged: blockDelegate.textBlockSetNeedsLayout
        ).cellBlockConfiguration(indentationSettings: nil, dragConfiguration: nil)
    }

    func didSelectRowInTableView(editorEditingState: EditorEditingState) {}
}
