import SwiftUI
import Loc

struct BinListView: View {
    
    @StateObject private var model: BinListViewModel
    
    init(spaceId: String, output: (any WidgetObjectListCommonModuleOutput)?) {
        self._model = StateObject(wrappedValue: BinListViewModel(spaceId: spaceId, output: output))
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                PageNavigationHeader(title: Loc.bin) {
                    editButton
                }
                SearchBar(
                    text: $model.searchText,
                    focused: false,
                    placeholder: Loc.search
                )
                content
            }
            optionsView
        }
        .task {
            await model.startSubscriptions()
        }
        .throwingTask(id: model.searchText) {
            try? await model.onSearch()
        }
        .onAppear {
            AnytypeAnalytics.instance().logScreenBin()
        }
        .environment(\.editMode, $model.viewEditMode)
        .ignoresSafeArea(.keyboard)
        .navigationBarTitle("")
        .navigationBarHidden(true)
        .animation(.default, value: model.viewEditMode)
        .homeBottomPanelHidden(model.showOptionsView, animated: false)
        .anytypeSheet(item: $model.binAlertData) { data in
            BinConfirmationAlert(data: data)
        }
    }

    @ViewBuilder
    private var editButton: some View {
        if model.rows.isNotEmpty && model.allowEdit {
            if model.viewEditMode.isEditing {
                Button {
                    model.onTapDone()
                } label: {
                    AnytypeText(Loc.done, style: .uxBodyRegular)
                        .foregroundColor(.Control.secondary)
                }
            } else {
                Menu {
                    Button(Loc.selectObjects) {
                        model.onTapSelecObjects()
                    }
                    
                    AsyncButton(Loc.Widgets.Actions.emptyBin, role: .destructive) {
                        try await model.onTapEmptyBin()
                    }
                    
                } label: {
                    AnytypeText("...", style: .uxBodyRegular)
                        .foregroundColor(.Control.secondary)
                }
            }
        }
    }
    
    @ViewBuilder
    private var content: some View {
        if model.rows.isNotEmpty {
            list
        } else {
            emptyView
        }
    }
    
    @ViewBuilder
    private var list: some View {
        PlainList {
            ForEach(model.rows) { row in
                BinListRowView(
                    model: row,
                    onTap: {
                        model.onTapRow(row: row)
                    },
                    onCheckboxTap: {
                        model.onCheckboxTap(row: row)
                    },
                    onDelete: {
                        model.onDelete(row: row)
                    },
                    onRestore: {
                        model.onRestore(row: row)
                    }
                )
            }
            AnytypeNavigationSpacer(minHeight: 130)
        }
        .scrollIndicators(.never)
        .scrollDismissesKeyboard(.immediately)
    }
    
    @ViewBuilder
    private var optionsView: some View {
        if model.showOptionsView {
            SelectionOptionsView(viewModel: SelectionOptionsViewModel(itemProvider: model))
                .frame(height: 100)
                .cornerRadius(16, style: .continuous)
                .shadow(radius: 16)
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
        }
    }
    
    private var emptyView: some View {
        EmptyStateView(
            title: Loc.EmptyView.Bin.title,
            subtitle: Loc.EmptyView.Bin.subtitle,
            style: .plain
        )
    }
}
