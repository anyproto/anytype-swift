import SwiftUI
import UniformTypeIdentifiers

public extension View {

    func onDragIf(
        _ condition: Bool,
        data: @escaping () -> NSItemProvider
    ) -> some View {
        modifier(ConditionalDragModifier(condition: condition, data: data))
    }

    func onDragIf<V>(
        _ condition: Bool,
        data: @escaping () -> NSItemProvider,
        @ViewBuilder preview: @escaping () -> V
    ) -> some View where V: View {
        modifier(ConditionalDragWithPreviewModifier(condition: condition, data: data, preview: preview))
    }

    func onDropIf(
        _ condition: Bool,
        of supportedContentTypes: [UTType],
        delegate: any DropDelegate
    ) -> some View {
        modifier(
            ConditionalDropModifier(
                condition: condition,
                supportedContentTypes: supportedContentTypes,
                delegate: delegate
            )
        )
    }
}

private struct ConditionalDragModifier: ViewModifier {
    let condition: Bool
    let data: () -> NSItemProvider

    @Namespace private var namespace
    
    func body(content: Content) -> some View {
        if condition {
            content
                .onDrag(data)
                .matchedGeometryEffect(id: "content", in: namespace)
        } else {
            content
                .matchedGeometryEffect(id: "content", in: namespace)
        }
    }
}

private struct ConditionalDragWithPreviewModifier<Preview: View>: ViewModifier {
    
    let condition: Bool
    let data: () -> NSItemProvider
    let preview: () -> Preview
    
    @Namespace private var namespace
    
    func body(content: Content) -> some View {
        if condition {
            content
                .onDrag(data, preview: preview)
                .matchedGeometryEffect(id: "content", in: namespace)
        } else {
            content
                .matchedGeometryEffect(id: "content", in: namespace)
        }
    }
}

private struct ConditionalDropModifier: ViewModifier {
    let condition: Bool
    let supportedContentTypes: [UTType]
    let delegate: any DropDelegate

    @Namespace private var namespace
    
    func body(content: Content) -> some View {
        if condition {
            content
                .onDrop(of: supportedContentTypes, delegate: delegate)
                .matchedGeometryEffect(id: "content", in: namespace)
        } else {
            content
                .matchedGeometryEffect(id: "content", in: namespace)
        }
    }
}
