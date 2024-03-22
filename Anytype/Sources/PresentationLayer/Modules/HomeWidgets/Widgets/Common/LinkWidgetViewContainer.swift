import SwiftUI

struct LinkWidgetViewContainer<Content, MenuContent>: View where Content: View, MenuContent: View {
    
    let title: String
    let icon: ImageAsset?
    @Binding var isExpanded: Bool
    let dragId: String?
    let homeState: HomeWidgetsState
    let allowMenuContent: Bool
    let allowContent: Bool
    let menu: () -> MenuContent
    let content: Content
    let headerAction: (() -> Void)
    let removeAction: (() -> Void)?
    
    @Environment(\.anytypeDragState) @Binding private var dragState
    
    init(
        title: String,
        icon: ImageAsset?,
        isExpanded: Binding<Bool>,
        dragId: String? = nil,
        homeState: HomeWidgetsState = .readonly,
        allowMenuContent: Bool = false,
        allowContent: Bool = true,
        headerAction: @escaping (() -> Void),
        removeAction: (() -> Void)? = nil,
        @ViewBuilder menu: @escaping () -> MenuContent = { EmptyView() },
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.icon = icon
        self._isExpanded = isExpanded
        self.dragId = dragId
        self.homeState = homeState
        self.allowMenuContent = allowMenuContent
        self.allowContent = allowContent
        self.headerAction = headerAction
        self.removeAction = removeAction
        self.menu = menu
        self.content = content()
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack(spacing: 0) {
                Spacer.fixedHeight(6)
                header
                if !isExpanded || !allowContent {
                    Spacer.fixedHeight(6)
                } else {
                    content
                        .allowsHitTesting(!homeState.isEditWidgets)
                        .frame(
                            minWidth: 0,
                            maxWidth: .infinity,
                            alignment: .topLeading
                        )
                }
            }
            .background(Color.Widget.card)
            .cornerRadius(16, style: .continuous)
            .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 16, style: .continuous))
            .contentShape(.dragPreview, RoundedRectangle(cornerRadius: 16, style: .continuous))
            .if(homeState.isReadWrite) {
                $0.ifLet(dragId) { view, dragId in
                    view.anytypeVerticalDrag(itemId: dragId)
                }
            }
            
            removeButton
                .zIndex(1)
        }
        .animation(.default, value: homeState)
        .opacity(isDragging() ? 0 : 1)
    }
    
    // MARK: - Private
    
    private var header: some View {
        HStack(spacing: 0) {
            HStack(spacing: 0) {
                if let icon {
                    Spacer.fixedWidth(14)
                    Image(asset: icon)
                        .foregroundColor(.Text.primary)
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
            .fixTappableArea()
            .onTapGesture {
                headerAction()
            }
            .allowsHitTesting(!homeState.isEditWidgets)
            menuButton
            arrowButton
            Spacer.fixedWidth(12)
        }
        .frame(height: 40)
    }
    
    @ViewBuilder
    private var arrowButton: some View {
        if allowContent {
            Image(asset: .Widget.collapse)
                .foregroundColor(.Text.primary)
                .rotationEffect(.degrees(isExpanded ? 90 : 0))
                .increaseTapGesture(EdgeInsets(side: 10)) {
                    withAnimation {
                        isExpanded = !isExpanded
                    }
                }
        }
    }
    
    @ViewBuilder
    private var menuButton: some View {
        if homeState.isEditWidgets, allowMenuContent {
            Menu {
                menu()
            } label: {
                Image(asset: .Widget.settings)
                    .foregroundColor(.Text.primary)
                    .padding(EdgeInsets(horizontal: 16, vertical: 10))
            }
        }
    }
    
    @ViewBuilder
    private var removeButton: some View {
        if homeState.isEditWidgets, let removeAction {
            ZStack {
                Color.Background.material
                    .background(.ultraThinMaterial)
                    .cornerRadius(12, style: .continuous)
                Color.white.frame(height: 1.5)
                    .cornerRadius(0.75)
                    .frame(width: 10)
            }
            .frame(width: 24, height: 24)
            .offset(x: -8, y: -8)
            .onTapGesture {
                removeAction()
            }
        }
    }
    
    private func isDragging() -> Bool {
        dragState.dragInitiateId == dragId && dragState.dragInProgress
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
                    homeState: .editWidgets,
                    headerAction: {}
                ) {
                    Text("Content")
                }
                Spacer.fixedHeight(10)
                LinkWidgetViewContainer(
                    title: "Name",
                    icon: ImageAsset.Widget.bin,
                    isExpanded: .constant(false),
                    homeState: .readonly,
                    headerAction: {}
                ) {
                    Text("Content")
                }
                Spacer.fixedHeight(10)
                LinkWidgetViewContainer(
                    title: "Very long text very long text very long text very long text",
                    icon: nil,
                    isExpanded: .constant(false),
                    homeState: .readwrite,
                    headerAction: {}
                ) {
                    Text("Content")
                }
                Spacer.fixedHeight(10)
                LinkWidgetViewContainer(
                    title: "Very long text very long text very long text very long text very long text",
                    icon: nil,
                    isExpanded: .constant(true),
                    homeState: .readwrite,
                    headerAction: {}
                ) {
                    Text("Content")
                }
            }
        }
    }
}
