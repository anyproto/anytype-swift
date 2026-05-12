import SwiftUI
import Services

struct HomepageSettingsPickerView: View {

    @State private var model: HomepageSettingsPickerViewModel
    @Environment(\.dismiss) private var dismiss

    init(spaceId: String, onHomepageSet: ((String, AnyHashable) -> Void)?) {
        _model = State(initialValue: HomepageSettingsPickerViewModel(spaceId: spaceId, onHomepageSet: onHomepageSet))
    }

    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            TitleView(title: Loc.SpaceSettings.HomePage.channelHome)

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

    @ViewBuilder
    private var content: some View {
        if model.isSearchCompleted {
            ScrollView {
                LazyVStack(spacing: 0) {
                    if model.showNoHomeRow {
                        noHomeRow
                        AnytypeDivider()
                    }

                    if !model.objects.isEmpty {
                        ListSectionHeaderView(title: Loc.SpaceSettings.HomePage.objects)
                    }

                    ForEach(model.objects) { object in
                        objectRow(object)
                            .newDivider()
                    }
                }
                .padding(.horizontal, 16)
            }
            .scrollIndicators(.never)
        } else {
            Spacer()
        }
    }

    private var noHomeRow: some View {
        AsyncButton {
            try await model.onNoHomeSelected()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "minus.circle")
                    .resizable()
                    .foregroundStyle(Color.Control.secondary)
                    .frame(width: 22, height: 22)
                    .frame(width: 48, height: 48)

                VStack(alignment: .leading, spacing: 2) {
                    AnytypeText(Loc.SpaceSettings.HomePage.noHome, style: .uxBodyRegular)
                        .foregroundStyle(Color.Text.primary)
                        .lineLimit(1)

                    AnytypeText(Loc.SpaceSettings.HomePage.noHomeSubtitle, style: .relation2Regular)
                        .foregroundStyle(Color.Text.secondary)
                        .lineLimit(1)
                }

                Spacer()

                if model.isNoHomeSelected {
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
                    .frame(width: 48, height: 48)

                VStack(alignment: .leading, spacing: 2) {
                    AnytypeText(details.homePickerTitle, style: .uxBodyRegular)
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

private extension ObjectDetails {
    var homePickerTitle: String {
        if resolvedLayoutValue == .objectType, !pluralName.isEmpty {
            return pluralName
        }
        return name.withPlaceholder
    }
}
