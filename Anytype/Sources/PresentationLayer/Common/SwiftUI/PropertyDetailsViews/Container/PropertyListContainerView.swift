import SwiftUI

struct PropertyListContainerView<Content>: View where Content: View {
    @Binding var searchText: String
    
    let title: String
    let isEditable: Bool
    let isEmpty: Bool
    let isClearAvailable: Bool
    let isCreateAvailable: Bool
    let listContent: () -> Content
    let onCreate: (_ title: String?) -> Void
    let onClear: () -> Void
    
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
            AnytypeText(Loc.clear, style: .uxBodyRegular)
                .foregroundColor(.Control.secondary)
        }
    }
    
    private var createButton: some View {
        Button {
            onCreate(nil)
        } label: {
            Image(asset: .X32.plus).foregroundColor(.Control.secondary)
        }
    }
    
    private var createRow: some View {
        Button {
            onCreate(searchText)
        } label: {
            HStack(spacing: 10) {
                Image(asset: .X32.plus).foregroundColor(.Control.secondary)
                AnytypeText(Loc.Relation.Create.Row.title(searchText), style: .uxBodyRegular)
                    .foregroundColor(.Text.primary)
            }
        }
        .frame(height: 52)
        .padding(.horizontal, 20)
    }
    
    private var emptyState: some View {
        Group {
            if !isCreateAvailable || !isEditable {
                PropertyListEmptyState()
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
            style: .withImage,
            buttonData: EmptyStateView.ButtonData(
                title: Loc.create,
                action: { onCreate(nil) }
            )
        )
    }
}
