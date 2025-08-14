import SwiftUI
import AnytypeCore

struct LinkWidgetViewContainer<Header, Content, MenuContent>: View where Header: View, Content: View, MenuContent: View {
    
    @Binding var isExpanded: Bool
    let dragId: String?
    @Binding var homeState: HomeWidgetsState
    let allowMenuContent: Bool
    let allowContent: Bool
    let allowContextMenuItems: Bool
    let header: Header
    let menu: () -> MenuContent
    let content: Content
    let removeAction: (() -> Void)?
    let createObjectAction: (() -> Void)?
    
    @Environment(\.anytypeDragState) @Binding private var dragState
    
    init(
        isExpanded: Binding<Bool>,
        dragId: String? = nil,
        homeState: Binding<HomeWidgetsState>,
        allowMenuContent: Bool = false,
        allowContent: Bool = true,
        allowContextMenuItems: Bool = true,
        removeAction: (() -> Void)? = nil,
        createObjectAction: (() -> Void)? = nil,
        @ViewBuilder header: () -> Header,
        @ViewBuilder menu: @escaping () -> MenuContent = { EmptyView() },
        @ViewBuilder content: () -> Content
    ) {
        self._isExpanded = isExpanded
        self.dragId = dragId
        self._homeState = homeState
        self.allowMenuContent = allowMenuContent
        self.allowContent = allowContent
        self.allowContextMenuItems = allowContextMenuItems
        self.removeAction = removeAction
        self.header = header()
        self.createObjectAction = createObjectAction
        self.menu = menu
        self.content = content()
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack(spacing: 0) {
                Spacer.fixedHeight(6)
                headerContainer
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
    
    private var headerContainer: some View {
        HStack(spacing: 0) {
            header
                .allowsHitTesting(!homeState.isEditWidgets)
            HStack(spacing: 16) {
                createObjectButton
                menuButton
                arrowButton
            }
            Spacer.fixedWidth(16)
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
