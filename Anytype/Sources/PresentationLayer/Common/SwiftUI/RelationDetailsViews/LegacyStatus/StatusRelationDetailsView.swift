import SwiftUI

struct StatusRelationDetailsView: View {
    
    @ObservedObject var viewModel: StatusRelationDetailsViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            InlineNavigationBar {
                TitleView(title: "Status")
            } rightButton: {
                rightButton
            }
            content
            Spacer()
        }
        .sheet(isPresented: $viewModel.isSearchPresented) { viewModel.makeSearchView() }
    }
    
    private var rightButton: some View {
        Group {
            if viewModel.currentStatusModel.isNil {
                addButton
            } else {
                clearButton
            }
        }
    }
    
    private var content: some View {
        Group {
            if let currentStatusModel = viewModel.currentStatusModel {
                Button {
                    viewModel.didTapAddButton()
                } label: {
                    StatusSearchRowView(viewModel: currentStatusModel, selectionIndicatorViewModel: nil)
                }
            } else {
                AnytypeText(Loc.noRelatedOptionsHere, style: .uxCalloutRegular, color: .Text.tertiary)
                    .frame(height: 48)
            }
        }
    }
    
}

// MARK: - NavigationBarView

private extension StatusRelationDetailsView {
    
    var clearButton: some View {
        Button {
            withAnimation(.fastSpring) {
                viewModel.didTapClearButton()
            }
        } label: {
            AnytypeText(Loc.clear, style: .uxBodyRegular, color: .Button.active)
        }
        .disabled(!viewModel.isEditable)
    }
    
    var addButton: some View {
        Button {
            viewModel.didTapAddButton()
        } label: {
            Image(asset: .X32.plus)
                .foregroundColor(.Button.active)
        }
        .disabled(!viewModel.isEditable)
    }
    
}
