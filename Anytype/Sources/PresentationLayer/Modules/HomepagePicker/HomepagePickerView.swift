import SwiftUI
import DesignKit

struct HomepagePickerView: View {

    @State private var model: HomepagePickerViewModel
    @Environment(\.dismiss) private var dismiss

    init(spaceId: String, onFinish: @escaping (HomepagePickerResult) async throws -> Void) {
        _model = State(initialValue: HomepagePickerViewModel(spaceId: spaceId, onFinish: onFinish))
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer.fixedHeight(31)

            titleSection

            Spacer.fixedHeight(24)

            optionsScroll

            Spacer.fixedHeight(24)

            buttons

            Spacer.fixedHeight(16)
        }
        .background(Color.Background.secondary)
        .fitPresentationDetents()
        .presentationDragIndicator(.hidden)
        .onChange(of: model.dismiss) {
            dismiss()
        }
    }

    // MARK: - Sections

    private var titleSection: some View {
        VStack(spacing: 8) {
            AnytypeText(Loc.HomepagePicker.title, style: .heading)
                .foregroundStyle(Color.Text.primary)
                .multilineTextAlignment(.center)

            AnytypeText(Loc.HomepagePicker.description, style: .uxTitle2Regular)
                .foregroundStyle(Color.Text.primary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 37)
        }
    }

    private var optionsScroll: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 24) {
                ForEach(model.options) { option in
                    HomepagePickerThumbnailCard(
                        option: option,
                        isSelected: model.selectedOption == option
                    )
                    .onTapGesture {
                        model.selectedOption = option
                    }
                }
            }
            .padding(.horizontal, 24)
        }
    }

    private var buttons: some View {
        AsyncStandardButtonGroup {
            VStack(spacing: 8) {
                AsyncStandardButton(Loc.create, style: .primaryLarge) {
                    try await model.onCreate()
                }

                AsyncStandardButton(Loc.later, style: .secondaryLarge) {
                    try await model.onLater()
                }
            }
            .padding(.horizontal, 16)
        }
    }
}
