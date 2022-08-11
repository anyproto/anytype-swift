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
        let shimmeringImage = UIImage(asset: ImageAsset.TextEditor.shimmering)

        return ShimmeringBlockConfiguration(shimmeringImage: shimmeringImage)
            .cellBlockConfiguration(indentationSettings: nil, dragConfiguration: nil)
    }
}

struct ShimmeringBlockConfiguration: BlockConfiguration {
    typealias View = ShimmeringBlockView

    let shimmeringImage: UIImage?
}

