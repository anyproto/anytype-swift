import SwiftUI

struct SetLayoutSettingsView: View {
    @StateObject var model: SetLayoutSettingsViewModel

    var body: some View {
        VStack(spacing: 0) {
            Spacer.fixedHeight(8)
            TitleView(title: Loc.layout)
            viewTypes
        }
        .padding(.horizontal, 20)
    }
    
    private var viewTypes: some View {
        LazyVGrid(
            columns: columns()
        ) {
            ForEach(model.types) {
                viewTypeContent($0)
            }
        }
    }
    
    private func viewTypeContent(_ configuration: SetViewTypeConfiguration) -> some View {
        VStack(alignment: .center, spacing: 0) {
            Image(asset: configuration.icon)
            AnytypeText(
                configuration.name,
                style: configuration.isSelected ? .caption2Medium : .caption2Regular,
                color: configuration.isSelected ? .System.amber100 : .Text.secondary
            )
        }
        .frame(height: 106)
        .frame(maxWidth: .infinity)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    configuration.isSelected ? Color.System.amber50 : Color.Text.secondary,
                    lineWidth: configuration.isSelected ? 2 : 0.5
                )
        )
        .onTapGesture {
            configuration.onTap()
        }
    }
    
    private func columns() -> [GridItem] {
        Array(
            repeating: GridItem(.flexible(), spacing: 8, alignment: .topLeading),
            count: 3
        )
    }
}
