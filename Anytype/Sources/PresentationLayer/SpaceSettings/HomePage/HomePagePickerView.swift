import SwiftUI
import Services

struct HomePagePickerView: View {

    @State private var model: HomePagePickerViewModel
    @Environment(\.dismiss) private var dismiss

    init(spaceId: String, onFinish: @escaping () -> Void = {}) {
        _model = State(initialValue: HomePagePickerViewModel(spaceId: spaceId, onFinish: onFinish))
    }

    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            TitleView(title: Loc.SpaceSettings.HomePage.title)

            widgetsOption

            SearchBar(text: $model.searchText, focused: false, placeholder: Loc.search)
                .padding(.horizontal, 16)

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

    private var widgetsOption: some View {
        Button {
            model.onWidgetsSelected()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: model.isChatSpace ? "bubble.left.and.bubble.right" : "house")
                    .foregroundStyle(Color.Control.primary)

                AnytypeText(model.defaultOptionTitle, style: .uxBodyRegular)
                    .foregroundStyle(Color.Text.primary)

                Spacer()

                if model.currentObjectId == nil {
                    Image(asset: .X24.tick)
                        .foregroundStyle(Color.Control.secondary)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
        }
    }

    @ViewBuilder
    private var content: some View {
        if model.objects.isEmpty {
            Spacer()
        } else {
            objectsList
        }
    }

    private var objectsList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(model.objects) { object in
                    objectRow(object)
                }
            }
            .padding(.horizontal, 20)
        }
        .scrollIndicators(.never)
    }

    private func objectRow(_ details: ObjectDetails) -> some View {
        Button {
            model.onObjectSelected(details)
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
