import Foundation
import SwiftUI

struct SpaceCreateView: View {
    
    @StateObject var model: SpaceCreateViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            TitleView(title: Loc.SpaceCreate.title)
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    SettingsObjectHeader(name: $model.spaceName, nameTitle: Loc.Settings.spaceName, iconImage: model.spaceIcon, onTap: {})
                        .focused(.constant(true))
                    
                    SectionHeaderView(title: Loc.type)
                    SpaceTypeView(name: model.spaceType.fullName)
                }
            }
            .safeAreaInset(edge: .bottom) {
                StandardButton(model: StandardButtonModel(text: Loc.create, inProgress: model.createLoadingState, style: .primaryLarge, action: {
                    model.onTapCreate()
                }))
                .padding(.bottom, 10)
            }
            .padding(.horizontal, 20)
        }
        .onChange(of: model.dismiss) { _ in
            dismiss()
        }
    }
}
