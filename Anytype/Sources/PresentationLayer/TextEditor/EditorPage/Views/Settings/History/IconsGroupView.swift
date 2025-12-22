import Foundation
import SwiftUI
import Services

struct IconsGroupView: View {
    let icons: [ObjectIcon]
    
    init(icons: [ObjectIcon]) {
        self.icons = icons.reversed()
    }
    
    var body: some View {
        HStack(spacing: 4) {
            iconsView
            countView
        }
    }
    
    private var iconsView: some View {
        HStack(spacing: -Constants.imageShift) {
            ForEach(icons.suffix(Constants.maxVisibleIcons), id: \.hashValue) { icon in
                objectIconViewWithBorder(for: icon)
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
    }
    
    private func objectIconViewWithBorder(for icon: ObjectIcon) ->some View {
        ObjectIconView(icon: icon)
            .frame(width: Constants.iconDiameter, height: Constants.iconDiameter)
            .background {
                Circle()
                    .foregroundStyle(Color.Background.secondary)
                    .frame(width: Constants.backgroundDiameter, height: Constants.backgroundDiameter)
            }
    }
    
    @ViewBuilder
    private var countView: some View {
        if icons.count > Constants.maxVisibleIcons {
            AnytypeText("+\(icons.count - Constants.maxVisibleIcons)", style: .caption1Regular)
                .foregroundStyle(Color.Text.secondary)
        }
    }
}

extension IconsGroupView {
    enum Constants {
        static let iconDiameter: CGFloat = 24
        static let backgroundDiameter = iconDiameter + lineWidth * 2
        static let lineWidth: CGFloat = 2
        static let imageShift = lineWidth * 2
        static let maxVisibleIcons = 3
    }
}
