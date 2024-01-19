import SwiftUI

struct RelationContainerView: View {
    
    @StateObject var viewModel: RelationContainerViewModel
    @State var searchText = ""
    
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
                .navigationTitle(viewModel.title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        clearButton
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        addButton
                    }
                }
        }
        .navigationViewStyle(.stack)
    }
    
    private var content: some View {
        VStack(spacing: 0) {
            SearchBar(text: $searchText, focused: false, placeholder: Loc.search)
                .onChange(of: searchText) { text in
                    viewModel.searchTextChanged(text)
                }
//            if isEmpty {
                emptyState
//            } else {
//                list
//            }
        }
    }
    
    private var list: some View {
        PlainList {
            
        }
        .buttonStyle(BorderlessButtonStyle())
        .bounceBehaviorBasedOnSize()
        .background(Color.Background.secondary)
        .border(.orange, width: 1)
    }
    
    private var clearButton: some View {
        Button {
            viewModel.clearButtonTapped()
        } label: {
            AnytypeText(Loc.clear, style: .uxBodyRegular, color: .Button.active)
        }
    }
    
    private var addButton: some View {
        Button {
            viewModel.addButtonTapped()
        } label: {
            Image(asset: .X32.plus).foregroundColor(.Button.active)
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 0) {
            Spacer()
            ButtomAlertHeaderImageView(icon: .BottomAlert.error, style: .red)
            Spacer.fixedHeight(12)
            AnytypeText(Loc.Relations.EmptyState.title, style: .uxCalloutMedium, color: .Text.primary)
            AnytypeText(Loc.Relations.EmptyState.description, style: .uxCalloutMedium, color: .Text.primary)
            Spacer.fixedHeight(12)
            StandardButton(Loc.create, style: .secondarySmall) {
                viewModel.addButtonTapped()
            }
            Spacer.fixedHeight(48)
            Spacer()
        }
    }
}

struct RelationContainerView_Previews: PreviewProvider {
    static var previews: some View {
        RelationContainerView(
            viewModel: RelationContainerViewModel(
                title: "",
                output: nil
            )
        )
    }
}
