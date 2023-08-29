import SwiftUI

struct SetLayoutSettingsView: View {
    @StateObject var viewModel: SetLayoutSettingsViewModel

    var body: some View {
        VStack(spacing: 0) {
            TitleView(title: Loc.layout)
        }
        .padding(.horizontal, 20)
    }
}
