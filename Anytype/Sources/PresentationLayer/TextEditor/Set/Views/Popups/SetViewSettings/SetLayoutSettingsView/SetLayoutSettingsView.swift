import SwiftUI

struct SetLayoutSettingsView: View {
    @StateObject var model: SetLayoutSettingsViewModel

    var body: some View {
        VStack(spacing: 0) {
            TitleView(title: Loc.layout)
            viewTypes
        }
        .padding(.horizontal, 20)
    }
    
    private var viewTypes: some View {
        HStack(spacing: 8) {
            ForEach(model.types) {
                viewTypeContent($0)
            }
        }
    }
    
    private func viewTypeContent(_ configuration: SetViewTypeConfiguration) -> some View {
        VStack(alignment: .center, spacing: 0) {
            Image(asset: configuration.icon)
                .foregroundColor(configuration.isSelected ? .System.amber100 : .Button.active)
            AnytypeText(
                configuration.name,
                style: .caption2Regular,
                color: configuration.isSelected ? .Button.accent : .Text.secondary
            )
        }
        .frame(height: 106)
        .frame(maxWidth: .infinity)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    configuration.isSelected ? Color.System.amber25 : .Text.secondary,
                    lineWidth:configuration.isSelected ? 2 : 0.5
                )
        )
        .onTapGesture {
            configuration.onTap()
        }
    }
}
