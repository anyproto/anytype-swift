import Foundation
import SwiftUI

struct HomeWidgetsBottomPanelView: View {
    
    let model: HomeWidgetsBottomPanelViewModel
    
    var body: some View {
        HStack(alignment: .center, spacing: 40) {
            ForEach(model.buttons) { button in
                Button(action: button.onTap, label: {
                    Image(asset: button.image)
                })
            }
        }
        .frame(height: 52)
        .background(Color.red)
    }
}
