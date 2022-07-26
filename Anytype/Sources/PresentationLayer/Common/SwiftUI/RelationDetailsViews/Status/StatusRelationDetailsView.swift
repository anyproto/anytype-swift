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
                AnytypeText(Loc.noRelatedOptionsHere, style: .uxCalloutRegular, color: .textTertiary)
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
            AnytypeText(Loc.clear, style: .uxBodyRegular, color: .buttonActive)
        }
    }
    
    var addButton: some View {
        Button {
            viewModel.didTapAddButton()
        } label: {
            Image(asset: .relationNew).frame(width: 24, height: 24)
        }
    }
    
}
