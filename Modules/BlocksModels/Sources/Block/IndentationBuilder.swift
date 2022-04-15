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
                guard var child = container.get(id: childrenId.value) else { return }

                let indentationStyles = parentIndentationStyles(
                    child: child,
                    parent: parent,
                    indentationRecursion: indentationRecursionData
                )

                let calloutBackground = calloutBottomBackground(
                    child: child,
                    parent: parent,
                    indentationRecursion: indentationRecursionData
                )

                child = child.updated(
                    metadata: BlockInformationMetadata(
                        parentId: parent.id.value,
                        parentBackgroundColors: parentBackgroundColors(child: child, parent: parent),
                        parentIndentationStyle: indentationStyles,
                        backgroundColor: child.relativeBackgroundColor,
                        indentationStyle: child.content.indentationStyle(isSingleChild: child.childrenIds.isEmpty),
                        calloutBackgroundColor: calloutBackground
                    )
                )

                container.add(child)
                privateBuild(
                    container: container,
                    id: childrenId.value,
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
            previousBackgroundColors = parent.configurationData.parentBackgroundColors
            let previousNotDefaultColor = previousBackgroundColors.last { $0 != .default }

            if parent.backgroundColor == .default || parent.relativeBackgroundColor == nil {
                previousBackgroundColors.append(previousNotDefaultColor ?? nil)
            } else {
                previousBackgroundColors.append(parent.relativeBackgroundColor)
            }
        } else {
            previousBackgroundColors = parent.configurationData.parentBackgroundColors
        }

        return previousBackgroundColors
    }

    private static func parentIndentationStyles(
        child: BlockInformation,
        parent: BlockInformation,
        indentationRecursion: IndentationStyleRecursiveData
    ) -> [BlockIndentationStyle] {
        var previousIndentationStyles = parent.configurationData.parentIndentationStyle

        if let closingBlocks = indentationRecursion.hightlightedChildBlockIdToClosingIndexes[child.id.value] {
            if child.childrenIds.count > 0, let last = child.childrenIds.last {
                closingBlocks.forEach { indentationRecursion.addClosing(for: last.value, at: $0) }
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
                indentationRecursion.addClosing(for: lastChildId.value, at: previousIndentationStyles.count)
            }

            previousIndentationStyles.append(indentationStyle)
        } else {
            previousIndentationStyles = parent.configurationData.parentIndentationStyle
        }

        return previousIndentationStyles
    }

    private static func calloutBottomBackground(
        child: BlockInformation,
        parent: BlockInformation,
        indentationRecursion: IndentationStyleRecursiveData
    ) -> MiddlewareColor? {
        if let calloutLastBackground = indentationRecursion.lastChildCalloutBlocks[child.id.value] {
            if child.childrenIds.isEmpty {
                return calloutLastBackground
            } else if let lastChild = child.childrenIds.last {
                indentationRecursion.lastChildCalloutBlocks[lastChild.value] = calloutLastBackground
            }
        }
        
        let isLastInParent: Bool = {
            guard let last = parent.childrenIds.last else { return false }
            return last == child.id
        }()
        
        if case .callout = parent.content.indentationStyle(isLastChild: isLastInParent) {
            if let lastChildId = parent.childrenIds.last, lastChildId == child.id, child.childrenIds.isEmpty {
                return parent.relativeBackgroundColor
            } else {
                child.childrenIds.last.map {
                    indentationRecursion.lastChildCalloutBlocks[$0.value] = parent.relativeBackgroundColor
                }
            }
        }

        return nil
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
