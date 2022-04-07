import Foundation

public enum IndentationBuilder {
    public static func build(container: InfoContainerProtocol, id: BlockId) {
        privateBuild(container: container, id: id)
    }

    private static func privateBuild(
        container: InfoContainerProtocol,
        id: BlockId,
        indentationRecursionData: IndentationStyleRecursiveData = IndentationStyleRecursiveData()
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
        indentationRecursion: IndentationStyleRecursiveData
    ) -> [BlockIndentationStyle] {
        var previousIndentationStyles = parent.metadata.parentIndentationStyle

        if let closingBlocks = indentationRecursion.childBlockIdToClosingIndexes[child.id] {
            if child.childrenIds.count > 0, let last = child.childrenIds.last {
                closingBlocks.forEach { indentationRecursion.addClosing(for: last, at: $0) }
            } else {
                closingBlocks.forEach { index in
                    previousIndentationStyles[index] = .highlighted(.closing)
                }
            }
        }

        if parent.kind != .meta, child.kind != .meta {
            let isLastChild = parent.childrenIds.last == child.id
            let indentationStyle: BlockIndentationStyle = parent.content.indentationStyle(
                isLastChild: isLastChild && child.childrenIds.count == 0
            )

            if case .highlighted = indentationStyle,
                isLastChild,
                child.childrenIds.count > 0,
                let lastChildId = child.childrenIds.last {
                indentationRecursion.addClosing(for: lastChildId, at: previousIndentationStyles.count)
            }

            previousIndentationStyles.append(indentationStyle)
        } else {
            previousIndentationStyles = parent.metadata.parentIndentationStyle
        }

        return previousIndentationStyles
    }
}

public extension BlockContent {
    func indentationStyle(isSingleChild: Bool) -> BlockIndentationStyle {
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

    func indentationStyle(isLastChild: Bool) -> BlockIndentationStyle {
        switch self {
        case .text(let blockText):
            switch blockText.contentType {
            case .quote: return .highlighted(isLastChild ? .closing : .full)
            case .callout: return .callout
            default: return .none
            }
        default: return .none
        }
    }
}
