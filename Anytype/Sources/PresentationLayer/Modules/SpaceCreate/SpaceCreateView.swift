import Foundation
import SwiftUI

struct SpaceCreateView: View {
    
    @StateObject var model: SpaceCreateViewModel
    @Environment(\.presentationMode) @Binding var presentationMode
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            TitleView(title: "Create a space")
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    SettingsObjectHeader(name: $model.spaceName, nameTitle: Loc.Settings.spaceName, iconImage: model.spaceIcon, onTap: {})
                    
                    SectionHeaderView(title: Loc.type)
                    SpaceTypeView(name: model.spaceType.fullName)
                }
            }
            .safeAreaInset(edge: .bottom) {
                StandardButton(model: StandardButtonModel(text: "Create", inProgress: model.createLoadingState, style: .primaryLarge, action: {
                    model.onTapCreate()
                }))
            }
            .padding(.horizontal, 20)
        }
        .onChange(of: model.dismiss) { _ in
            presentationMode.dismiss()
        }
    }
}
