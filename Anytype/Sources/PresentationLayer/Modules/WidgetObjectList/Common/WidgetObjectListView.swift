import SwiftUI

// TODO: Make common module without model
struct WidgetObjectListView: View {
    
    @StateObject var model: WidgetObjectListViewModel
    @State private var searchText: String = ""
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                if model.isSheet {
                    DragIndicator()
                }
                PageNavigationHeader(title: model.title) {
                    editButton
                }
                SearchBar(text: $searchText, focused: false, placeholder: Loc.search)
                content
            }
            optionsView
        }
        .ignoresSafeArea(.keyboard)
        .onAppear {
            model.onAppear()
        }
        .onDisappear() {
            model.onDisappear()
        }
        .task {
            await model.startParticipantTask()
        }
        .onChange(of: searchText) { model.didAskToSearch(text: $0) }
        .onChange(of: model.viewEditMode) { _ in model.onSwitchEditMode() }
        .navigationBarTitle("")
        .navigationBarHidden(true)
        .environment(\.editMode, $model.viewEditMode)
        .homeBottomPanelHidden(model.homeBottomPanelHiddel, animated: false)
        .anytypeSheet(item: $model.binAlertData) { data in
            BinConfirmationAlert(data: data)
        }
        .anytypeSheet(item: $model.forceDeleteAlertData) {
            ForceDeleteAlert(data: $0)
        }
    }
    
    @ViewBuilder
    private var content: some View {
        switch model.data {
        case .list(let sections):
            dataList(sections: sections)
        case .error(let title, let subtitle):
            EmptyStateView(
                title: title,
                subtitle: subtitle,
                style: .plain
            )
        }
    }
    
    @ViewBuilder
    private func dataList(sections: [ListSectionData<String?, WidgetObjectListRowModel>]) -> some View {
        PlainList {
            ForEach(sections) { section in
                if let title = section.data, title.isNotEmpty {
                    ListSectionHeaderView(title: title)
                        .padding(.horizontal, 20)
                }
                ForEach(section.rows, id: \.id) { row in
                    WidgetObjectListRowView(model: row)
                }
                .if(allowDnd) {
                    $0.onMove { from, to in
                        model.onMove(from: from, to: to)
                    }
                }
            }
            AnytypeNavigationSpacer(minHeight: 130)
        }
        .scrollIndicators(.never)
        .scrollDismissesKeyboard(.immediately)
    }
    
    @ViewBuilder
    private var editButton: some View {
        if model.contentIsNotEmpty, model.canEdit {
            switch model.editMode {
            case .normal:
                EditButton()
                    .foregroundColor(Color.Control.active)
            case .editOnly:
                Button {
                    model.onSelectAll()
                } label: {
                    AnytypeText(model.selectButtonText, style: .uxBodyRegular)
                        .foregroundColor(.Control.active)
                }
            }
        }
    }
    
    @ViewBuilder
    private var optionsView: some View {
        if model.showActionPanel {
            SelectionOptionsView(viewModel: SelectionOptionsViewModel(itemProvider: model))
                .frame(height: 100)
                .cornerRadius(16, style: .continuous)
                .shadow(radius: 16)
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
        }
    }
    
    private var allowDnd: Bool {
        switch model.editMode {
        case let .normal(allowDnd):
            return allowDnd
        case .editOnly:
            return false
        }
    }
}
