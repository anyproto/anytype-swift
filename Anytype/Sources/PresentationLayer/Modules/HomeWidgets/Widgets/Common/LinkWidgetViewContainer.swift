import SwiftUI

struct LinkWidgetViewContainer<Content>: View where Content: View {
    
    var title: String
    var description: String?
    @Binding var isExpanded: Bool
    var isEditalbeMode: Bool
    var content: () -> Content
    
    init(title: String, description: String? = nil, isExpanded: Binding<Bool>, isEditalbeMode: Bool = false, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.description = description
        self._isExpanded = isExpanded
        self.isEditalbeMode = isEditalbeMode
        self.content = content
    }
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 0) {
                Spacer.fixedHeight(6)
                header
                if !isExpanded {
                    Spacer.fixedHeight(6)
                } else {
                    content()
                        .allowsHitTesting(!isEditalbeMode)
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
            
            if isEditalbeMode {
                Button(action: {
                    // TODO: Add menu action
                }, label: {
                    Image(asset: .Widget.remove)
                })
                .offset(x: 8, y: -8)
            }
        }
    }
    
    // MARK: - Private
    
    private var header: some View {
        HStack(spacing: 0) {
            Spacer.fixedWidth(16)
            AnytypeText(title, style: .subheading, color: .Text.primary)
                .lineLimit(1)
                .layoutPriority(-1)
            // TODO: Waiting designer. Fix description style and spacer after title.
            if let description {
                Spacer.fixedWidth(8)
                AnytypeText(description, style: .body, color: .Text.secondary)
                    .lineLimit(1)
            }
            Spacer()
            if isEditalbeMode {
                Button(action: {
                    // TODO: Add menu action
                }, label: {
                    Image(asset: .Widget.settings)
                })
                Spacer.fixedWidth(16)
            }
            Button(action: {
                withAnimation {
                    isExpanded = !isExpanded
                }
            }, label: {
                Image(asset: .Widget.collapse)
                    .rotationEffect(.degrees(isExpanded ? 90 : 0))
            })
                .allowsHitTesting(!isEditalbeMode)
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
                    isExpanded: .constant(true),
                    isEditalbeMode: false
                ) {
                    Text("Content")
                }
                Spacer.fixedHeight(10)
                LinkWidgetViewContainer(
                    title: "Name",
                    description: "1",
                    isExpanded: .constant(false),
                    isEditalbeMode: false
                ) {
                    Text("Content")
                }
                Spacer.fixedHeight(10)
                LinkWidgetViewContainer(
                    title: "Very long text very long text very long text very long text",
                    description: nil,
                    isExpanded: .constant(false),
                    isEditalbeMode: false
                ) {
                    Text("Content")
                }
                Spacer.fixedHeight(10)
                LinkWidgetViewContainer(
                    title: "Very long text very long text very long text very long text very long text",
                    description: "1 111",
                    isExpanded: .constant(true),
                    isEditalbeMode: true
                ) {
                    Text("Content")
                }
            }
        }
    }
}
