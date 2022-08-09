import SwiftUI

struct SetViewSettingsImagePreviewView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: SetViewSettingsImagePreviewViewModel

    var body: some View {
        ScrollView(showsIndicators: false) {
            content
        }
    }
    
    private var content: some View {
        VStack(spacing: 0) {
            DragIndicator()
            TitleView(title: viewModel.title)
            coverSection
            relationsSection
            Spacer()
        }
        .padding(.horizontal, 20)
    }

    private var coverSection: some View {
        VStack(spacing: 0) {
            ForEach(viewModel.coverRows) { item in
                Button {
                    presentationMode.wrappedValue.dismiss()
                    item.onTap()
                } label: {
                    row(item)
                }
                .divider()
            }
        }
    }
    
    private var relationsSection: some View {
        Group {
            if viewModel.relationsRows.isNotEmpty {
                VStack(spacing: 0) {
                    relationsHeader
                    ForEach(viewModel.relationsRows) { item in
                        Button {
                            presentationMode.wrappedValue.dismiss()
                            item.onTap()
                        } label: {
                            row(item)
                        }
                        .divider()
                    }
                }
            } else {
                EmptyView()
            }
        }
    }
    
    private var relationsHeader: some View {
        VStack(spacing: 0) {
            Spacer.fixedHeight(26)
            AnytypeText(Loc.relations, style: .caption1Regular, color: .textSecondary)
            Spacer.fixedHeight(8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .divider()
    }

    private func row(_ configuration: SetViewSettingsImagePreviewRowConfiguration) -> some View {
        HStack(spacing: 0) {
            if let iconAsset = configuration.iconAsset {
                Image(asset: iconAsset)
                Spacer.fixedWidth(12)
            }
            AnytypeText(configuration.title, style: .uxBodyRegular, color: .textPrimary)
            Spacer()

            if configuration.isSelected {
                Image(asset: .optionChecked).frame(width: 24, height: 24).foregroundColor(.buttonSelected)
            }
        }
        .frame(height: 52)
    }
}
