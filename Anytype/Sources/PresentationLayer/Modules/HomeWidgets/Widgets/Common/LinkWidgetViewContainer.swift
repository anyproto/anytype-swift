import SwiftUI

struct LinkWidgetViewContainer<Content>: View where Content: View {
    
    var title: String
    var description: String?
    @Binding var isExpanded: Bool
    var content: () -> Content
    
    init(title: String, description: String? = nil, isExpanded: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.description = description
        self._isExpanded = isExpanded
        self.content = content
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer.fixedHeight(6)
            header
            if !isExpanded {
                Spacer.fixedHeight(6)
            } else {
                content()
                .frame(
                    minWidth: 0,
                    maxWidth: .infinity,
                    alignment: .topLeading
                )
                Spacer.fixedHeight(16)
            }
        }
        .background(Color.Dashboard.card)
        .cornerRadius(16, style: .continuous)
        .contentShapeLegacy(.contextMenuPreview, RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
    
    // MARK: - Private
    
    private var header: some View {
        HStack(spacing: 0) {
            Spacer.fixedWidth(16)
            AnytypeText(title, style: .subheading, color: .Text.primary)
                .lineLimit(1)
                .layoutPriority(-1)
            // TODO: Fix description style and spacer after title
            if let description {
                Spacer.fixedWidth(8)
                AnytypeText(description, style: .body, color: .Text.secondary)
                    .lineLimit(1)
            }
            Spacer()
            Button(action: {
                withAnimation {
                    isExpanded = !isExpanded
                }
            }, label: {
                Image(asset: .Widget.collapse)
                    .rotationEffect(.degrees(isExpanded ? 90 : 0))
            })
            Spacer.fixedWidth(12)
        }
        .frame(height: 40)
    }
}

struct LinkWidgetViewContainer_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color(.black)
            VStack {
                LinkWidgetViewContainer(
                    title: "Name",
                    description: nil,
                    isExpanded: .constant(true)
                ) {
                    Text("Content")
                }
                Spacer.fixedHeight(10)
                LinkWidgetViewContainer(
                    title: "Name",
                    description: "1",
                    isExpanded: .constant(false)
                ) {
                    Text("Content")
                }
                Spacer.fixedHeight(10)
                LinkWidgetViewContainer(
                    title: "Very long text very long text very long text very long text",
                    description: nil,
                    isExpanded: .constant(false)
                ) {
                    Text("Content")
                }
                Spacer.fixedHeight(10)
                LinkWidgetViewContainer(
                    title: "Very long text very long text very long text very long text very long text",
                    description: "1 111",
                    isExpanded: .constant(true)
                ) {
                    Text("Content")
                }
            }
        }
    }
}
