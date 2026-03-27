import SwiftUI
import DesignKit

struct HomepageCreatePickerView: View {

    @State private var model: HomepageCreatePickerViewModel
    @State private var contentHeight: CGFloat = 516
    @Environment(\.dismiss) private var dismiss

    init(spaceId: String, onFinish: @escaping (HomepagePickerResult) async throws -> Void) {
        _model = State(initialValue: HomepageCreatePickerViewModel(spaceId: spaceId, onFinish: onFinish))
    }

    var body: some View {
        content
        .readSize { size in
            contentHeight = size.height
        }
        .presentationDetents([.height(contentHeight)])
        .presentationDragIndicator(.hidden)
        .presentationBackground(Color.Background.secondary)
        .presentationBackgroundInteraction(.enabled)
        .onChange(of: model.dismiss) {
            dismiss()
        }
    }

    // MARK: - Sections
    
    private var content: some View {
          VStack(spacing: 31) {
              titleSection
              optionsScroll
              buttons
          }
          .padding(.top, 31)
          .padding(.bottom, 16)
      }

    private var titleSection: some View {
        VStack(spacing: 8) {
            AnytypeText(Loc.HomepagePicker.title, style: .heading)
                .foregroundStyle(Color.Text.primary)
                .multilineTextAlignment(.center)

            AnytypeText(Loc.HomepagePicker.description, style: .uxTitle2Regular)
                .foregroundStyle(Color.Text.primary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 32)
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

#Preview {
    HomepageCreatePickerView(spaceId: "") { result in
        print("Result: \(result)")
    }
}
