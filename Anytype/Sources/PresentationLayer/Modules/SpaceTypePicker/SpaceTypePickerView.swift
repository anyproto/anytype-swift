import SwiftUI
import Services

struct SpaceCreateTypePickerView: View {
    
    let onSelectSpaceType: (_ data : SpaceUxType) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            AnytypeDivider()
            SpaceTypePickerRow(icon: , title: <#T##String#>, subtitle: <#T##String#>, onTap: <#T##() -> Void#>)
        }
    }
}
