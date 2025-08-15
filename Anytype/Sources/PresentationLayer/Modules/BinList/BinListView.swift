import SwiftUI
import Loc

struct BinListView: View {
    
    @StateObject private var model: BinListViewModel
    
    init(spaceId: String) {
        self._model = StateObject(wrappedValue: BinListViewModel(spaceId: spaceId))
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
        .anytypeSheet(
            item: $model.binAlertData,
            onDismiss: {
                model.confirmationDismissed()
            },
            content: { data in
                BinConfirmationAlert(data: data)
            }
        )
    }

    @ViewBuilder
    private var editButton: some View {
        if model.viewEditMode.isEditing {
            Button {
                model.onTapDone()
            } label: {
                AnytypeText("Done", style: .uxBodyRegular)
                    .foregroundColor(.Control.secondary)
            }
        } else {
            Menu {
                Button("Select objects") {
                    model.onTapSelecObjects()
                }
                
                Button("Empty Bin", role: .destructive) {
                    model.onTapEmptyBin()
                }
                
            } label: {
                AnytypeText("...", style: .uxBodyRegular)
                    .foregroundColor(.Control.secondary)
            }
        }
    }
    
    @ViewBuilder
    private var content: some View {
        EmptyView()
        PlainList {
            ForEach(model.rows) { row in
                BinListRowView(
                    model: row,
                    onTap: {
                        model.onTapRow(row: row)
                    },
                    onCheckboxTap: {
                        model.onCheckboxTap(row: row)
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
        EmptyView()
        // TODO: implement
    }
}
