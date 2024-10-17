import Foundation
import SwiftUI

struct AllContentWidgetView: View {
    
    @StateObject private var model: AllContentWidgetViewModel
    @Binding var homeState: HomeWidgetsState
    
    init(
        spaceId: String,
        homeState: Binding<HomeWidgetsState>,
        output: (any CommonWidgetModuleOutput)?
    ) {
        _homeState = homeState
        _model = StateObject(wrappedValue: AllContentWidgetViewModel(spaceId: spaceId, output: output))
    }
    
    var body: some View {
        HStack(spacing: 0) {
            Image(asset: .Widget.allContent)
                .foregroundColor(.Text.primary)
                .frame(width: 20, height: 20)
            
            Spacer.fixedWidth(8)
            
            AnytypeText(Loc.allObjects, style: .previewTitle2Medium)
                .foregroundColor(.Text.primary)
                .lineLimit(1)
            
            Spacer()
        }
        .padding(.all, 16)
        .background(Color.Widget.card)
        .cornerRadius(16, style: .continuous)
        .fixTappableArea()
        .onTapGesture {
            model.onTapWidget()
        }
        .allowsHitTesting(!homeState.isEditWidgets)
    }
}
