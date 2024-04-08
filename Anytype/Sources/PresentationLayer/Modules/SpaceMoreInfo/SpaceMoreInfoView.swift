import Foundation
import SwiftUI

struct SpaceMoreInfoView: View {
    
    private let steps = [
        Loc.SpaceShare.HowToShare.step1,
        Loc.SpaceShare.HowToShare.step2,
        Loc.SpaceShare.HowToShare.step3
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            TitleView(title: Loc.SpaceShare.HowToShare.title)
            VStack(spacing: 8) {
                ForEach(steps.indices, id: \.self) { index in
                    HStack(alignment: .top, spacing: 8) {
                        AnytypeText("\(index + 1).", style: .bodyRegular)
                            .foregroundColor(.Text.primary)
                        AnytypeText(steps[index], style: .bodyRegular)
                            .foregroundColor(.Text.primary)
                        Spacer()
                    }
                }
            }
            .padding(.vertical, 8)
            Spacer()
        }
        .padding(.horizontal, 20)
    }
}
