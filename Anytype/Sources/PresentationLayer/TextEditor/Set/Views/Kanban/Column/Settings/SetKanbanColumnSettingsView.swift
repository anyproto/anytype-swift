import SwiftUI

struct SetKanbanColumnSettingsView: View {
    @ObservedObject var viewModel: SetKanbanColumnSettingsViewModel

    var body: some View {
        VStack(spacing: 0) {
            hiddenSetting
            Spacer.fixedHeight(26)
            colorSetting
            Spacer.fixedHeight(26)
            button
            Spacer.fixedHeight(10)
        }
    }
    
    private var hiddenSetting: some View {
        AnytypeToggle(
            title: Loc.Set.View.Kanban.Column.Settings.Hide.Column.title,
            isOn: viewModel.hideColumn
        ) { _ in
            viewModel.hideColumnTapped()
        }
        .frame(height: 52)
        .padding(.horizontal, 20)
    }
    
    private var colorSetting: some View {
        VStack(alignment: .leading, spacing: 0) {
            AnytypeText(
                Loc.Set.View.Kanban.Column.Settings.Color.title,
                style: .caption1Regular,
                color: .Text.secondary
            )
            .padding(.horizontal, 20)
            Spacer.fixedHeight(14)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(viewModel.colors, id: \.rawValue) { backgroundColor in
                        Button(action: {
                            viewModel.columnColorTapped(backgroundColor)
                        }) {
                            colorItem(backgroundColor)
                        }
                        .buttonStyle(LightDimmingButtonStyle())
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    private func colorItem(_ backgroundColor: BlockBackgroundColor) ->some View {
        ZStack {
            backgroundColor.swiftColor
                .frame(width: 48, height: 48)
                .clipShape(Circle())
            if viewModel.selectedColor == backgroundColor {
                Image(asset: .X24.tick)
                    .foregroundColor(.Text.primary)
            }
        }
    }
    
    private var button: some View {
        StandardButton(Loc.Set.Button.Title.apply, style: .primaryLarge) {
            viewModel.applyTapped()
        }
        .padding(.horizontal, 20)
    }
}
