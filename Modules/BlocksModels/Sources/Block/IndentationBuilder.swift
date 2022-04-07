import Foundation

private class IndentationRecursionData {
    var closingBlockIndex = [BlockId: [Int]]()
}

public enum IndentationBuilder {
    public static func build(
        container: InfoContainerProtocol,
        id: BlockId
    ) {
        privateBuild(container: container, id: id)
    }

    private static func privateBuild(
        container: InfoContainerProtocol,
        id: BlockId,
        indentationRecursionData: IndentationRecursionData = IndentationRecursionData()
    ) {
        if let parent = container.get(id: id) {

            parent.childrenIds.forEach { childrenId in
                guard var child = container.get(id: childrenId) else { return }

                let indentationStyles = parentIndentationStyles(
                    child: child,
                    parent: parent,
                    indentationRecursion: indentationRecursionData
                )

                child = child.updated(
                    metadata: BlockInformationMetadata(
                        parentId: parent.id,
                        parentBackgroundColors: parentBackgroundColors(child: child, parent: parent),
                        parentIndentationStyle: indentationStyles,
                        backgroundColor: child.backgroundColor,
                        indentationStyle: child.content.indentationStyle(isSingleChild: child.childrenIds.isEmpty)
                    )
                )

                container.add(child)
                privateBuild(
                    container: container,
                    id: childrenId,
                    indentationRecursionData: indentationRecursionData
                )
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
        parent: BlockInformation,
        indentationRecursion: IndentationRecursionData
    ) -> [BlockIndentationStyle] {
        var previousIndentationStyles = parent.metadata.parentIndentationStyle

        if let indentationRecursionParams = indentationRecursion.closingBlockIndex[child.id] {
            if child.childrenIds.count > 0, let lastChild = child.childrenIds.last {
                indentationRecursion.closingBlockIndex[lastChild] = indentationRecursionParams
            } else {
                indentationRecursionParams.forEach {
                    previousIndentationStyles[$0] = .highlighted(.closing)
                }

            }
        }

        if parent.kind != .meta, child.kind != .meta {
            let isLastChild = parent.childrenIds.last == child.id
            let indentationStyle: BlockIndentationStyle = parent.content.indentationStyle(isLastChildBlock: isLastChild)

            if isLastChild,
                child.childrenIds.count > 0,
                let lastChildId = child.childrenIds.last,
                indentationStyle == .highlighted(.full) {
                indentationRecursion.closingBlockIndex[lastChildId] = [previousIndentationStyles.count]
            }

            previousIndentationStyles.append(parent.content.indentationStyle(isLastChildBlock: isLastChild))
        } else {
            previousIndentationStyles = parent.metadata.parentIndentationStyle
        }

        return previousIndentationStyles
    }
}

public extension BlockContent {
    func indentationStyle(
        isLastChildBlock: Bool = false,
        isSingleChild: Bool = false,
        hasChildrenBlocks: Bool = false
    ) -> BlockIndentationStyle {
        switch self {
        case .text(let blockText):
            switch blockText.contentType {
            case .quote: return .highlighted(isSingleChild ? .single : .full)
            case .callout: return .callout
            default: return .none
            }
        default: return .none
        }
    }
}
