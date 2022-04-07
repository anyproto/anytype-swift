import Foundation

public enum IndentationBuilder {
    public static func build(container: InfoContainerProtocol, id: BlockId) {
        if let parent = container.get(id: id) {
            parent.childrenIds.forEach { childrenId in
                guard var child = container.get(id: childrenId) else { return }

                child = child.updated(
                    metadata: BlockInformationMetadata(
                        parentId: parent.id,
                        parentBackgroundColors: parentBackgroundColors(child: child, parent: parent),
                        parentIndentationStyle: parentIndentationStyles(child: child, parent: parent),
                        backgroundColor: child.backgroundColor,
                        indentationStyle: child.content.indentationStyle
                    )
                )

                container.add(child)
                build(container: container, id: childrenId)
            }
        }
    }

    private static func parentBackgroundColors(
        child: BlockInformation,
        parent: BlockInformation
    ) -> [MiddlewareColor?] {
        var previousBackgroundColors: [MiddlewareColor?]

        if parent.kind != .meta, child.kind != .meta {
            previousBackgroundColors = parent.metadata.parentBackgroundColors
            let previousNotDefaultColor = previousBackgroundColors.last { $0 != .default }

            if parent.backgroundColor == .default || parent.backgroundColor == nil {
                previousBackgroundColors.append(previousNotDefaultColor ?? nil)
            } else {
                previousBackgroundColors.append(parent.backgroundColor)
            }
        } else {
            previousBackgroundColors = parent.metadata.parentBackgroundColors
        }

        return previousBackgroundColors
    }

    private static func parentIndentationStyles(
        child: BlockInformation,
        parent: BlockInformation
    ) -> [BlockIndentationStyle] {
        var previousIndentationStyles = [BlockIndentationStyle]()

        if parent.kind != .meta, child.kind != .meta {
            previousIndentationStyles = parent.metadata.parentIndentationStyle

            previousIndentationStyles.append(parent.content.indentationStyle)
        } else {
            previousIndentationStyles = parent.metadata.parentIndentationStyle
        }

        return previousIndentationStyles
    }
}

public extension BlockContent {
    var indentationStyle: BlockIndentationStyle {
        switch self {
        case .text(let blockText):
            switch blockText.contentType {
            case .quote: return .highlighted
            case .callout: return .callout
            default: return .none
            }
        default: return .none
        }
    }
}
