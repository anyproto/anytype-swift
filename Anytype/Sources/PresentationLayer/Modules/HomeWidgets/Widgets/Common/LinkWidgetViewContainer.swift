import SwiftUI

struct LinkWidgetViewContainer<Content, MenuContent>: View where Content: View, MenuContent: View {
    
    let title: String
    let icon: ImageAsset?
    @Binding var isExpanded: Bool
    let isEditalbeMode: Bool
    let allowMenuContent: Bool
    let allowContent: Bool
    let menu: () -> MenuContent
    let content: () -> Content
    let headerAction: (() -> Void)
    let removeAction: (() -> Void)?
    
    init(
        title: String,
        icon: ImageAsset?,
        isExpanded: Binding<Bool>,
        isEditalbeMode: Bool = false,
        allowMenuContent: Bool = false,
        allowContent: Bool = true,
        headerAction: @escaping (() -> Void),
        removeAction: (() -> Void)? = nil,
        @ViewBuilder menu: @escaping () -> MenuContent = { EmptyView() },
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.icon = icon
        self._isExpanded = isExpanded
        self.isEditalbeMode = isEditalbeMode
        self.allowMenuContent = allowMenuContent
        self.allowContent = allowContent
        self.headerAction = headerAction
        self.removeAction = removeAction
        self.menu = menu
        self.content = content
    }
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 0) {
                Spacer.fixedHeight(6)
                header
                if !isExpanded || !allowContent {
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
            
            removeButton
                .zIndex(1)
        }
        .animation(.default, value: isEditalbeMode)
    }
    
    // MARK: - Private
    
    private var header: some View {
        HStack(spacing: 0) {
            Button {
                headerAction()
            } label: {
                if let icon {
                    Spacer.fixedWidth(14)
                    Image(asset: icon)
                        .frame(width: 20, height: 20)
                    Spacer.fixedWidth(8)
                } else {
                    Spacer.fixedWidth(16)
                }
                AnytypeText(title, style: .subheading, color: .Text.primary)
                    .lineLimit(1)
                    .layoutPriority(-1)
                Spacer.fixedWidth(16)
                Spacer()
            }
            menuButton
            arrowButton
            Spacer.fixedWidth(12)
        }
        .frame(height: 40)
    }
    
    @ViewBuilder
    private var arrowButton: some View {
        if allowContent {
            Button(action: {
                withAnimation {
                    isExpanded = !isExpanded
                }
            }, label: {
                Image(asset: .Widget.collapse)
                    .rotationEffect(.degrees(isExpanded ? 90 : 0))
            })
            .allowsHitTesting(!isEditalbeMode)
        }
    }
    
    @ViewBuilder
    private var menuButton: some View {
        if isEditalbeMode, allowMenuContent {
            Menu {
                menu()
            } label: {
                Image(asset: .Widget.settings)
            }
            Spacer.fixedWidth(16)
        }
    }
    
    @ViewBuilder
    private var removeButton: some View {
        VStack {
            if isEditalbeMode, let removeAction {
                Button(action: {
                    removeAction()
                }, label: {
                    Image(asset: .Widget.remove)
                })
                .transition(.scale)
            }
        }
        .offset(x: 8, y: -8)
    }
}

struct LinkWidgetViewContainer_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color(.black)
            VStack {
                LinkWidgetViewContainer(
                    title: "Name",
                    icon: nil,
                    isExpanded: .constant(true),
                    isEditalbeMode: false,
                    headerAction: {}
                ) {
                    Text("Content")
                }
                Spacer.fixedHeight(10)
                LinkWidgetViewContainer(
                    title: "Name",
                    icon: ImageAsset.Widget.bin,
                    isExpanded: .constant(false),
                    isEditalbeMode: false,
                    headerAction: {}
                ) {
                    Text("Content")
                }
                Spacer.fixedHeight(10)
                LinkWidgetViewContainer(
                    title: "Very long text very long text very long text very long text",
                    icon: nil,
                    isExpanded: .constant(false),
                    isEditalbeMode: false,
                    headerAction: {}
                ) {
                    Text("Content")
                }
                Spacer.fixedHeight(10)
                LinkWidgetViewContainer(
                    title: "Very long text very long text very long text very long text very long text",
                    icon: nil,
                    isExpanded: .constant(true),
                    isEditalbeMode: true,
                    headerAction: {}
                ) {
                    Text("Content")
                }
            }
        }
    }
}
