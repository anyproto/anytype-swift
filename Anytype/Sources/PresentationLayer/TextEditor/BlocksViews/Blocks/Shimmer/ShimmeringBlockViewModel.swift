import UIKit

struct ShimmeringBlockViewModel: SystemContentConfiguationProvider {
    enum SpacerCase: CGFloat {
        case firstRowOffset = 14
    }

    func didSelectRowInTableView(editorEditingState: EditorEditingState) {}

    var hashable: AnyHashable {
        "shimmering" as AnyHashable
    }

    func makeContentConfiguration(maxWidth: CGFloat) -> UIContentConfiguration {
        return ShimmeringBlockConfiguration(image: ImageAsset.TextEditor.shimmering)
            .cellBlockConfiguration(indentationSettings: nil, dragConfiguration: nil)
    }
}

struct ShimmeringBlockConfiguration: BlockConfiguration {
    typealias View = ShimmeringBlockView

    let image: ImageAsset
}

