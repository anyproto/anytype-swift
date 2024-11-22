import SwiftUI
import Services

struct AllContentSettingsMenu: View {
    @Binding var state: AllContentState
    let binTapped: () -> Void
    
    @State private var sort: AllContentSort
    
    init(state: Binding<AllContentState>, binTapped: @escaping () -> Void) {
        self._state = state
        self.binTapped = binTapped
        self.sort = state.wrappedValue.sort
    }
    
    var body: some View {
        Menu {
            mode
            Divider()
            AllContentSortMenu(sort: $sort)
            Divider()
            bin
        } label: {
            IconView(icon: .asset(.X24.more))
                .frame(width: 24, height: 24)
        }
        .menuOrder(.fixed)
        .onChange(of: sort) { state.sort = $0 }
    }
    
    private var mode: some View {
        Picker("", selection: $state.mode) {
            ForEach(AllContentMode.allCases, id: \.self) { mode in
                AnytypeText(mode.title, style: .uxTitle2Medium)
                    .foregroundColor(.Control.button)
            }
        }
    }
    
    private var bin: some View {
        Button {
            binTapped()
        } label: {
            AnytypeText(
                Loc.AllContent.Settings.viewBin,
                style: .uxTitle2Medium
            )
        }
    }
}
