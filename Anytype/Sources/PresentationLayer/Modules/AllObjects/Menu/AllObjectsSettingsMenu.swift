import SwiftUI
import Services

struct AllObjectsSettingsMenu: View {
    @Binding var state: AllObjectsState
    let binTapped: () -> Void
    
    init(state: Binding<AllObjectsState>, binTapped: @escaping () -> Void) {
        self._state = state
        self.binTapped = binTapped
    }
    
    var body: some View {
        Menu {
            mode
            Divider()
            AllObjectsSortMenu(sort: $state.sort)
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
            ForEach(AllObjectsMode.allCases, id: \.self) { mode in
                AnytypeText(mode.title, style: .uxTitle2Medium)
                    .foregroundColor(.Control.primary)
            }
        }
    }
    
    private var bin: some View {
        Button {
            binTapped()
        } label: {
            AnytypeText(
                Loc.AllObjects.Settings.viewBin,
                style: .uxTitle2Medium
            )
        }
    }
}
