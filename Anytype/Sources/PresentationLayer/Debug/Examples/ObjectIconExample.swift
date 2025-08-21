import SwiftUI
import AnytypeCore

struct ObjectIconExample: View {
    
    private let emojiExamples: [CGFloat] = [16, 18, 20, 40, 48, 64, 80, 96]
    @Injected(\.searchService)
    private var searchService: any SearchServiceProtocol
    @Injected(\.workspaceStorage)
    private var workspaceStorage: any WorkspacesStorageProtocol
    @State private var iconId: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            TitleView(title: "Icons")
            ScrollView {
                VStack(spacing: 20) {
                    Group {
                        AnytypeText("Object Icon", style: .subheading)
                            .foregroundColor(.Text.primary)
                        demoBlock { IconView(icon: .object(.basic(iconId))) }
                        AnytypeText("Object Icon Empty (page)", style: .subheading)
                            .foregroundColor(.Text.primary)
                        demoBlock { IconView(icon: .object(.defaultObjectIcon)) }
                        AnytypeText("Profile Icon", style: .subheading)
                            .foregroundColor(.Text.primary)
                        demoBlock { IconView(icon: .object(.profile(.imageId(iconId)))) }
                        AnytypeText("Profile Char", style: .subheading)
                            .foregroundColor(.Text.primary)
                        demoBlock { IconView(icon: .object(.profile(.name("A")))) }
                    }
                    Group {
                        AnytypeText("Emoji", style: .subheading)
                            .foregroundColor(.Text.primary)
                        demoBlock { IconView(icon: .object(.emoji(Emoji("😀")!))) }
                        AnytypeText("Todo done", style: .subheading)
                            .foregroundColor(.Text.primary)
                        demoBlock { IconView(icon: .object(.todo(true, nil))) }
                        AnytypeText("Todo empty", style: .subheading)
                            .foregroundColor(.Text.primary)
                        demoBlock { IconView(icon: .object(.todo(false, nil))) }
                        AnytypeText("Space gradient", style: .subheading)
                            .foregroundColor(.Text.primary)
                        AnytypeText("Space char", style: .subheading)
                            .foregroundColor(.Text.primary)
                        demoBlock { IconView(icon: .object(.space(.name(name: "A", iconOption: 1, circular: true)))) }
                    }
                    
                    Group {
                        AnytypeText("Assets - active (copy example)", style: .subheading)
                            .foregroundColor(.Text.primary)
                        demoBlock { IconView(icon: .asset(.X32.copy)) }
                        AnytypeText("Assets - inactive (copy example)", style: .subheading)
                            .foregroundColor(.Text.primary)
                        demoBlock { IconView(icon: .asset(.X32.copy)).disabled(true) }
                    }
                }
            }
        }
        .task {
            guard let spaceId = workspaceStorage.activeWorkspaces.first?.targetSpaceId else { return }
            let files = try? await searchService.searchImages(spaceId: spaceId)
            iconId = files?.first?.iconImage ?? ""
        }
    }
    
    @ViewBuilder
    private func demoBlock(@ViewBuilder content: @escaping () -> some View) -> some View {
        ForEach(0..<emojiExamples.count, id: \.self) { index in
            let size = emojiExamples[index]
            AnytypeText("Size \(size)", style: .bodyRegular)
                .foregroundColor(.Text.primary)
            HStack(spacing: 0) {
                HStack {
                    Spacer()
                    content()
                        .frame(width: size, height: size)
                    Spacer()
                }
                .padding(10)
                .background(.white)
                .colorScheme(.light)
                HStack {
                    Spacer()
                    content()
                        .frame(width: size, height: size)
                    Spacer()
                }
                .padding(10)
                .background(.gray)
                .colorScheme(.dark)
            }
            .padding(.bottom, 10)
            .newDivider()
        }
    }
}

struct ObjectIconExample_Previews: PreviewProvider {
    static var previews: some View {
        ColorsExample()
    }
}
