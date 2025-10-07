import SwiftUI
import Services
import AnytypeCore

struct SpaceCreateTypePickerView: View {
    
    let onSelectSpaceType: (_ data : SpaceUxType) -> Void
    let onSelectQrCodeScan: () -> Void
    @Environment(\.dismiss) private var dismiss    

    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            if FeatureFlags.spaceUxTypes {
                SpaceTypePickerRow(
                    icon: .Channel.chat,
                    title: Loc.Spaces.UxType.Chat.title,
                    subtitle: Loc.Spaces.UxType.Chat.description,
                    onTap: {
                        dismiss()
                        onSelectSpaceType(.chat)
                        AnytypeAnalytics.instance().logClickVaultCreateMenuChat()
                    }
                )
            }
            SpaceTypePickerRow(
                icon: .Channel.space,
                title: Loc.Spaces.UxType.Space.title,
                subtitle: Loc.Spaces.UxType.Space.description,
                onTap: {
                    dismiss()
                    onSelectSpaceType(.data)
                    AnytypeAnalytics.instance().logClickVaultCreateMenuSpace()
                }
            )
            SpaceTypePickerRow(
                icon: .X32.qrCodeJoin,
                title: Loc.Qr.Join.title,
                subtitle: "",
                onTap: {
                    dismiss()
                    onSelectQrCodeScan()
                }
            )
        }
        .onAppear {
            AnytypeAnalytics.instance().logScreenVaultCreateMenu()
        }
    }
}
