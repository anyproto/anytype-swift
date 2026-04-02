import SwiftUI
import Services
import DesignKit

struct MemberSelectionRow: View {

    let icon: ObjectIcon?
    let name: String
    let globalName: String
    @Binding var isSelected: Bool

    var body: some View {
        Button {
            isSelected.toggle()
        } label: {
            MemberRow(icon: icon, name: name, globalName: globalName) {
                AnytypeCircleCheckbox(checked: $isSelected)
                    .allowsHitTesting(false)
            }
        }
        .buttonStyle(.plain)
    }
}
