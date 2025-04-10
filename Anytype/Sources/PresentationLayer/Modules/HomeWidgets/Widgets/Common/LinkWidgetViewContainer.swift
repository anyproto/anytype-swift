import SwiftUI
import AnytypeCore

struct LinkWidgetViewContainer<Content, MenuContent>: View where Content: View, MenuContent: View {
    
    let title: String
    let icon: ImageAsset?
    @Binding var isExpanded: Bool
    let dragId: String?
    @Binding var homeState: HomeWidgetsState
    let allowMenuContent: Bool
    let allowContent: Bool
    let allowContextMenuItems: Bool
    let menu: () -> MenuContent
    let content: Content
    let headerAction: (() -> Void)
    let removeAction: (() -> Void)?
    let createObjectAction: (() -> Void)?
    
    @Environment(\.anytypeDragState) @Binding private var dragState
    
    init(
        title: String,
        icon: ImageAsset?,
        isExpanded: Binding<Bool>,
        dragId: String? = nil,
        homeState: Binding<HomeWidgetsState>,
        allowMenuContent: Bool = false,
        allowContent: Bool = true,
        allowContextMenuItems: Bool = true,
        headerAction: @escaping (() -> Void),
        removeAction: (() -> Void)? = nil,
        createObjectAction: (() -> Void)? = nil,
        @ViewBuilder menu: @escaping () -> MenuContent = { EmptyView() },
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.icon = icon
        self._isExpanded = isExpanded
        self.dragId = dragId
        self._homeState = homeState
        self.allowMenuContent = allowMenuContent
        self.allowContent = allowContent
        self.allowContextMenuItems = allowContextMenuItems
        self.headerAction = headerAction
        self.removeAction = removeAction
        self.createObjectAction = createObjectAction
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
                }
            }
            .background(Color.Background.widget)
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
        .setZeroOpacity(isDragging())
        .if(homeState.isReadWrite && allowContextMenuItems) {
            $0.contextMenu {
                contextMenuItems
            }
        }
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
                AnytypeText(title, style: .subheading)
                    .foregroundColor(.Text.primary)
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
            HStack(spacing: 0) {
                if FeatureFlags.plusButtonOnWidgets {
                    createObjectButton
                }
                menuButton
                arrowButton
            }
            // 12 - 8 = 4. (8 - increase button size for big tap area).
            // We can't using increaseTapGesture, because Menu doesnt support it
            Spacer.fixedWidth(4)
        }
        .frame(height: 40)
    }
    
    @ViewBuilder
    private var arrowButton: some View {
        if allowContent {
            Button {
                withAnimation {
                    isExpanded = !isExpanded
                }
            } label: {
                Image(asset: .X18.Disclosure.right)
                    .foregroundColor(.Text.primary)
                    .rotationEffect(.degrees(isExpanded ? 90 : 0))
                    .frame(width: 34, height: 34)
            }
        }
    }
    
    @ViewBuilder
    private var createObjectButton: some View {
        if !homeState.isEditWidgets, let createObjectAction {
            Button {
                createObjectAction()
            } label: {
                Image(asset: .X18.plus)
                    .foregroundColor(.Text.primary)
                    .frame(width: 34, height: 34)
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
                    .frame(width: 34, height: 34)
            }
        }
    }
    
    @ViewBuilder
    private var removeButton: some View {
        if homeState.isEditWidgets, let removeAction {
            ZStack {
                Color.BackgroundCustom.material
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
    
    @ViewBuilder
    private var contextMenuItems: some View {
        if homeState.isReadWrite {
            menu()
            Divider()
            Button(Loc.Widgets.Actions.editWidgets) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                    AnytypeAnalytics.instance().logEditWidget()
                    homeState = .editWidgets
                    UISelectionFeedbackGenerator().selectionChanged()
                }
            }
        }
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
                    homeState: .constant(.editWidgets),
                    headerAction: {}
                ) {
                    Text("Content")
                }
                Spacer.fixedHeight(10)
                LinkWidgetViewContainer(
                    title: "Name",
                    icon: ImageAsset.Widget.bin,
                    isExpanded: .constant(false),
                    homeState: .constant(.readonly),
                    headerAction: {}
                ) {
                    Text("Content")
                }
                Spacer.fixedHeight(10)
                LinkWidgetViewContainer(
                    title: "Very long text very long text very long text very long text",
                    icon: nil,
                    isExpanded: .constant(false),
                    homeState: .constant(.readwrite),
                    headerAction: {}
                ) {
                    Text("Content")
                }
                Spacer.fixedHeight(10)
                LinkWidgetViewContainer(
                    title: "Very long text very long text very long text very long text very long text",
                    icon: nil,
                    isExpanded: .constant(true),
                    homeState: .constant(.readwrite),
                    headerAction: {}
                ) {
                    Text("Content")
                }
            }
        }
    }
}
