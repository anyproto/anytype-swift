import SwiftUI
import Services

struct AllContentSettingsMenu: View {
    @Binding var state: AllContentState
    let binTapped: () -> Void
    
    init(state: Binding<AllContentState>, binTapped: @escaping () -> Void) {
        self._state = state
        self.binTapped = binTapped
    }
    
    var body: some View {
        Menu {
            mode
            Divider()
            AllContentSortMenu(sort: $state.sort)
            Divider()
            bin
        } label: {
            IconView(icon: .asset(.X24.more))
                .frame(width: 24, height: 24)
        }
        .menuOrder(.fixed)
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
