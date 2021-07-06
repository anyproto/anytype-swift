import SwiftUI

struct DocumentSettingsList: View {

    @EnvironmentObject private var iconViewModel: DocumentIconPickerViewModel
    @EnvironmentObject var viewModel: DocumentSettingsListViewModel
    
    var body: some View {
        VStack(spacing: 12) {
            DocumentSettingsListRow(
                setting: DocumentSetting(
                    icon: Image.ObjectSettings.icon,
                    title: "Icon",
                    subtitle: "Emoji or image for object",
                    isAvailable: true
                ),
                pressed: $viewModel.isIconSelected
            )
            .sheet(isPresented: $viewModel.isIconSelected) {
                Group {
                    switch iconViewModel.pickerType {
                    case .basic:
                        DocumentBasicIconPicker()
                    case .profile:
                        DocumentProfileIconPicker()
                    }
                }
            }
            .modifier(DividerModifier())
            
            DocumentSettingsListRow(
                setting: DocumentSetting(
                    icon: Image.ObjectSettings.cover,
                    title: "Cover",
                    subtitle: "Background picture",
                    isAvailable: true
                ),
                pressed: $viewModel.isCoverSelected
            )
            .sheet(isPresented: $viewModel.isCoverSelected) {
                DocumentCoverPicker()
            }
            .modifier(DividerModifier())
            
            DocumentSettingsListRow(
                setting: DocumentSetting(
                    icon: Image.ObjectSettings.layout,
                    title: "Layout",
                    subtitle: "Arrangement of objects on a canvas",
                    isAvailable: false
                ),
                pressed: $viewModel.isLayoutSelected
            )
            .modifier(DividerModifier())
            
        }
        .padding([.leading, .trailing, .bottom], 16)
        .background(Color.background)
    }
}


struct DocumentSettingsListView_Previews: PreviewProvider {
    static var previews: some View {
        DocumentSettingsList()
            .previewLayout(.sizeThatFits)
    }
}

