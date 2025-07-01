import UIKit

struct ShimmeringBlockViewModel: SystemContentConfiguationProvider {
    enum SpacerCase: CGFloat {
        case firstRowOffset = 14
    }

    func didSelectRowInTableView(editorEditingState: EditorEditingState) {}

    var hashable: AnyHashable {
        "ShimmeringBlockViewModel" as AnyHashable
    }

    func makeContentConfiguration(maxWidth: CGFloat) -> any UIContentConfiguration {
        ShimmeringBlockConfiguration(image: ImageAsset.TextEditor.shimmering)
            .cellBlockConfiguration(dragConfiguration: nil, styleConfiguration: nil)
    }
}

struct ShimmeringBlockConfiguration: BlockConfiguration {
    typealias View = ShimmeringBlockView

    let image: ImageAsset
}

