import SwiftUI
import Services

struct HomepageSettingsPickerView: View {

    @State private var model: HomepageSettingsPickerViewModel
    @Environment(\.dismiss) private var dismiss

    init(spaceId: String) {
        _model = State(initialValue: HomepageSettingsPickerViewModel(spaceId: spaceId))
    }

    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            TitleView(title: Loc.SpaceSettings.HomePage.chooseHome)

            SearchBar(text: $model.searchText, focused: false, placeholder: Loc.search)

            content
        }
        .background(Color.Background.secondary)
        .task(id: model.searchText) {
            await model.search()
        }
        .onChange(of: model.dismiss) {
            dismiss()
        }
    }

    private var content: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                emptyOption

                ForEach(model.objects) { object in
                    objectRow(object)
                }
            }
            .padding(.horizontal, 20)
        }
        .scrollIndicators(.never)
    }

    private var emptyOption: some View {
        AsyncButton {
            try await model.onEmptySelected()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "minus.circle")
                    .foregroundStyle(Color.Control.primary)
                    .frame(width: 24, height: 24)

                AnytypeText(Loc.empty, style: .uxBodyRegular)
                    .foregroundStyle(Color.Text.primary)

                Spacer()

                if model.currentObjectId == nil {
                    Image(asset: .X24.tick)
                        .foregroundStyle(Color.Control.secondary)
                }
            }
            .padding(.vertical, 14)
        }
    }

    private func objectRow(_ details: ObjectDetails) -> some View {
        AsyncButton {
            try await model.onObjectSelected(details)
        } label: {
            HStack(spacing: 12) {
                IconView(icon: details.objectIconImage)
                    .frame(width: 24, height: 24)

                VStack(alignment: .leading, spacing: 2) {
                    AnytypeText(details.name.withPlaceholder, style: .uxBodyRegular)
                        .foregroundStyle(Color.Text.primary)
                        .lineLimit(1)

                    AnytypeText(details.objectType.displayName, style: .relation2Regular)
                        .foregroundStyle(Color.Text.secondary)
                        .lineLimit(1)
                }

                Spacer()

                if model.currentObjectId == details.id {
                    Image(asset: .X24.tick)
                        .foregroundStyle(Color.Control.secondary)
                }
            }
            .padding(.vertical, 14)
        }
    }
}
