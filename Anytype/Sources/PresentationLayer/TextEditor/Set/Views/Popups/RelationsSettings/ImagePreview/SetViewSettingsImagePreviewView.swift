import SwiftUI

struct SetViewSettingsImagePreviewView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel: SetViewSettingsImagePreviewViewModel
    
    init(setDocument: some SetDocumentProtocol, onSelect: @escaping (String) -> Void) {
        _viewModel = StateObject(wrappedValue: SetViewSettingsImagePreviewViewModel(setDocument: setDocument, onSelect: onSelect))
    }

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
            propertiesSection
            Spacer()
        }
        .padding(.horizontal, 20)
    }

    private var coverSection: some View {
        VStack(spacing: 0) {
            ForEach(viewModel.coverRows) { item in
                Button {
                    dismiss()
                    item.onTap()
                } label: {
                    row(item)
                }
                .divider()
            }
        }
    }
    
    private var propertiesSection: some View {
        Group {
            if viewModel.relationsRows.isNotEmpty {
                VStack(spacing: 0) {
                    relationsHeader
                    ForEach(viewModel.relationsRows) { item in
                        Button {
                            dismiss()
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
            AnytypeText(Loc.fields, style: .caption1Regular)
                .foregroundColor(.Text.secondary)
            Spacer.fixedHeight(8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .divider()
    }

    private func row(_ configuration: SetViewSettingsImagePreviewRowConfiguration) -> some View {
        HStack(spacing: 0) {
            if let iconAsset = configuration.iconAsset {
                Image(asset: iconAsset)
                    .foregroundColor(.Control.secondary)
                Spacer.fixedWidth(12)
            }
            AnytypeText(configuration.title, style: .uxBodyRegular)
                .foregroundColor(.Text.primary)
            Spacer()

            if configuration.isSelected {
                Image(asset: .X24.tick).foregroundColor(.Control.primary)
            }
        }
        .frame(height: 52)
    }
}
