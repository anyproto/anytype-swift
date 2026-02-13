import SwiftUI

struct SettingsSection<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 0) {
            content
        }
        .background(Color.Background.widget)
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}

struct SettingsRow<Content: View>: View {
    let showDivider: Bool
    let leadingPadding: CGFloat
    let content: Content

    init(
        showDivider: Bool = true,
        leadingPadding: CGFloat = 16,
        @ViewBuilder content: () -> Content
    ) {
        self.showDivider = showDivider
        self.leadingPadding = leadingPadding
        self.content = content()
    }

    var body: some View {
        content
            .frame(height: 48)
            .padding(.horizontal, 16)
            .if(showDivider) { $0.newDivider(leadingPadding: leadingPadding) }
    }
}

extension View {
    func settingsRow(showDivider: Bool = true, leadingPadding: CGFloat = 16) -> some View {
        SettingsRow(showDivider: showDivider, leadingPadding: leadingPadding) {
            self
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        SettingsSection {
            Button { } label: {
                HStack {
                    Text("Option 1")
                    Spacer()
                }
            }
            .settingsRow(showDivider: true)

            Button { } label: {
                HStack {
                    Text("Option 2")
                    Spacer()
                }
            }
            .settingsRow(showDivider: false)
        }
    }
    .padding()
}
