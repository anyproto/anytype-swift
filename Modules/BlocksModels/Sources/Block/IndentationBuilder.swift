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
            var updatedBlockNumber = 0

            parent.childrenIds.forEach { childrenId in
                guard let child = container.get(id: childrenId) else { return }

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

                let updatedMetadataChild = child.updated(
                    metadata: BlockInformationMetadata(
                        parentId: parent.id,
                        parentBackgroundColors: parentBackgroundColors(child: child, parent: parent),
                        parentIndentationStyle: indentationStyles,
                        backgroundColor: child.relativeBackgroundColor,
                        indentationStyle: child.content.indentationStyle(isSingleChild: child.childrenIds.isEmpty),
                        calloutBackgroundColor: calloutBackground
                    )
                )


                let updatedChild = updatedNumberedValueIfNeeded(
                    container: container,
                    child: updatedMetadataChild,
                    numberValue: &updatedBlockNumber
                )

                if child != updatedChild {
                    container.add(updatedChild)
                }

                privateBuild(
                    container: container,
                    id: childrenId,
                    indentationRecursionData: indentationRecursionData
                )
            }
        }
    }

    
    private static func updatedNumberedValueIfNeeded(
        container: InfoContainerProtocol,
        child: BlockInformation,
        numberValue: inout Int
    ) -> BlockInformation {
        switch child.content {
        case let .text(text) where text.contentType == .numbered:
            numberValue += 1
            let content = BlockContent.text(text.updated(number: numberValue))

            return child.updated(content: content)
        default:
            numberValue = 0
        }

        return child
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

        if let closingBlocks = indentationRecursion.hightlightedChildBlockIdToClosingIndexes[child.id] {
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
            previousIndentationStyles = parent.configurationData.parentIndentationStyle
        }

        return previousIndentationStyles
    }

    private static func calloutBottomBackground(
        child: BlockInformation,
        parent: BlockInformation,
        indentationRecursion: IndentationStyleRecursiveData
    ) -> MiddlewareColor? {
        if let calloutLastBackground = indentationRecursion.lastChildCalloutBlocks[child.id] {
            if child.childrenIds.isEmpty {
                return calloutLastBackground
            } else if let lastChild = child.childrenIds.last {
                indentationRecursion.lastChildCalloutBlocks[lastChild] = calloutLastBackground
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
                    indentationRecursion.lastChildCalloutBlocks[$0] = parent.relativeBackgroundColor
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
