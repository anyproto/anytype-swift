import SwiftUI

struct RelationListContainerView<Content>: View where Content: View {
    @Binding var searchText: String
    
    let title: String
    let isEditable: Bool
    let isEmpty: Bool
    let isClearAvailable: Bool
    let isCreateAvailable: Bool
    let listContent: () -> Content
    let onCreate: (_ title: String?) -> Void
    let onClear: () -> Void
    let onSearchTextChange: (_ text: String) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            navigationView
        }
        .background(Color.Background.secondary)
    }
    
    private var navigationView: some View {
        NavigationView {
            content
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(.inline)
                .if(isEditable, transform: {
                    $0.toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            if isClearAvailable {
                                clearButton
                            }
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            if isCreateAvailable {
                                createButton
                            }
                        }
                    }
                })
        }
        .navigationViewStyle(.stack)
    }
    
    private var content: some View {
        VStack(spacing: 0) {
            if isEditable, !isEmpty {
                SearchBar(text: $searchText, focused: false, placeholder: Loc.search)
                    .onChange(of: searchText) { text in
                        onSearchTextChange(text)
                    }
            }
            
            list
                .if(isEmpty) {
                    $0.overlay(alignment: .center) {
                        emptyState
                    }
                }
        }
        .background(Color.Background.secondary)
    }
    
    private var list: some View {
        PlainList {
            listContent()
            if isCreateAvailable, searchText.isNotEmpty {
                createRow
            }
        }
        .buttonStyle(BorderlessButtonStyle())
        .bounceBehaviorBasedOnSize()
    }
    
    private var clearButton: some View {
        Button {
            onClear()
        } label: {
            AnytypeText(Loc.clear, style: .uxBodyRegular, color: .Button.active)
        }
    }
    
    private var createButton: some View {
        Button {
            onCreate(nil)
        } label: {
            Image(asset: .X32.plus).foregroundColor(.Button.active)
        }
    }
    
    private var createRow: some View {
        Button {
            onCreate(searchText)
        } label: {
            HStack(spacing: 10) {
                Image(asset: .X32.plus).foregroundColor(.Button.active)
                AnytypeText(Loc.Relation.Create.Row.title(searchText), style: .uxBodyRegular, color: .Text.primary)
            }
        }
        .frame(height: 52)
        .padding(.horizontal, 20)
    }
    
    private var emptyState: some View {
        Group {
            if !isCreateAvailable || !isEditable {
                blockedEmptyState
            } else  {
                defaultEmptyState
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    private var defaultEmptyState: some View {
        EmptyStateView(
            title: Loc.Relation.EmptyState.title,
            subtitle: Loc.Relation.EmptyState.description,
            actionText: Loc.create
        ) {
            onCreate(nil)
        }
    }
    
    private var blockedEmptyState: some View {
        VStack(spacing: 0) {
            Spacer()
            ButtomAlertHeaderImageView(icon: .BottomAlert.error, style: .red)
            Spacer.fixedHeight(12)
            AnytypeText(Loc.Relation.EmptyState.Blocked.title, style: .uxCalloutMedium, color: .Text.primary)
            Spacer()
        }
    }
}
