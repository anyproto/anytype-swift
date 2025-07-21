import SwiftUI
import Services

struct SetFiltersListView: View {
    @StateObject private var viewModel: SetFiltersListViewModel
    
    @State private var editMode = EditMode.inactive
    
    init(data: SetFiltersListModuleData, output: (any SetFiltersListCoordinatorOutput)?, subscriptionDetailsStorage: ObjectDetailsStorage) {
        _viewModel = StateObject(wrappedValue: SetFiltersListViewModel(
            data: data,
            output: output,
            subscriptionDetailsStorage: subscriptionDetailsStorage
        ))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            NavigationView {
                content
                    .navigationTitle(Loc.EditSet.Popup.Filters.NavigationView.title)
                    .navigationBarTitleDisplayMode(.inline)
                    .environment(\.editMode, $editMode)
                    .onChange(of: viewModel.rows) { newValue in
                        if editMode == .active && viewModel.rows.count == 0 {
                            editMode = .inactive
                        }
                    }
            }
            .navigationViewStyle(.stack)
        }
        .background(Color.Background.secondary)
    }
    
    private var addButton: some View {
        Group {
            if editMode == .inactive {
                Button {
                    viewModel.addButtonTapped()
                } label: {
                    Image(asset: .X32.plus)
                        .foregroundColor(.Control.secondary)
                }
            }
        }
    }
    
    private var content: some View {
        Group {
            if viewModel.rows.isNotEmpty {
                filtersList
            } else {
                emptyState
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                addButton
            }
        }
    }
    
    private var emptyState: some View {
        VStack {
            Spacer()
            AnytypeText(
                Loc.EditSet.Popup.Filters.EmptyView.title,
                style: .uxCalloutRegular
            )
            .foregroundColor(.Text.secondary)
            .frame(height: 68)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(Color.Background.secondary)
    }
    
    private var filtersList: some View {
        List {
            ForEach(viewModel.rows) {
                row(with: $0)
                    .divider(leadingPadding: 60)
                    .listRowSeparator(.hidden)
                    .listRowInsets(.init(top: 0, leading: 20, bottom: 0, trailing: 20))
            }
            .onDelete {
                viewModel.delete($0)
            }
            .listRowBackground(Color.Background.secondary)
        }
        .listStyle(.plain)
        .buttonStyle(BorderlessButtonStyle())
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                EditButton()
                    .foregroundColor(Color.Control.secondary)
            }
        }
        .background(Color.Background.secondary)
    }
    
    private func row(with configuration: SetFilterRowConfiguration) -> some View {
        SetFilterRow(configuration: configuration)
            .environment(\.editMode, $editMode)
    }
    
}
