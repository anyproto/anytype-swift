import SwiftUI

struct MigrationGuideView: View {
    
    private enum Constants {
        static let desktopDownloadLink = "https://download.anytype.io/?ref=migration&platform=desktop"
        static let forumLink = "https://community.anytype.io/migration"
    }
    
    @Environment(\.presentationMode) @Binding private var presentationMode
    @Environment(\.openURL) private var openURL
    @State private var firstBlockExpanded = true
    @State private var secondBlockExpanded = false
    
    var body: some View {
        ZStack(alignment: .top) {
            content
            HStack(spacing: 0) {
                Spacer()
                Button {
                    AnytypeAnalytics.instance().logMigrationGoneWrong(type: .exit)
                    presentationMode.dismiss()
                } label: {
                    Image(asset: .Migration.close)
                }
            }
            .padding(.trailing, 12)
            .padding(.top, 12)
        }
        .background(Color.Background.primary)
        .onAppear {
            AnytypeAnalytics.instance().logMigrationGoneWrong(type: nil)
        }
    }
    
    @ViewBuilder
    private var content: some View {
        VStack(spacing: 0) {
            Spacer.fixedHeight(56)
            VStack(alignment: .leading, spacing: 0) {
                AnytypeText(Loc.MigrationGuide.title, style: .heading, color: .Text.primary)
                Spacer.fixedHeight(12)
                AnytypeText(Loc.MigrationGuide.subtitle, style: .uxBodyRegular, color: .Text.primary)
                Spacer.fixedHeight(32)
                InstructionBlockView(
                    title: Loc.MigrationGuide.DidntComplete.title,
                    expanded: $firstBlockExpanded
                ) {
                    InstructionNumericContentView(messages: [
                        .init(text: Loc.MigrationGuide.DidntComplete.step1, onTap: {
                            AnytypeAnalytics.instance().logMigrationGoneWrong(type: .download)
                            guard let url = URL(string: Constants.desktopDownloadLink) else { return }
                            openURL(url)
                        }),
                        .init(text: Loc.MigrationGuide.DidntComplete.step2),
                        .init(text: Loc.MigrationGuide.DidntComplete.step3)
                    ])
                }
                Spacer.fixedHeight(20)
                InstructionBlockView(
                    title: Loc.MigrationGuide.Completed.title,
                    expanded: $secondBlockExpanded
                ) {
                    AnytypeText(Loc.MigrationGuide.Completed.description, style: .uxCalloutRegular, color: .Text.primary)
                    Spacer.fixedHeight(16)
                    StandardButton(.text(Loc.MigrationGuide.Completed.forumButton), style: .primaryLarge) {
                        AnytypeAnalytics.instance().logMigrationGoneWrong(type: .instruсtions)
                        guard let url = URL(string: Constants.forumLink) else { return }
                        openURL(url)
                    }
                }
                Spacer()
            }
            .padding(.horizontal, 20)
        }
        .animation(.default, value: firstBlockExpanded)
        .animation(.default, value: secondBlockExpanded)
        .onChange(of: firstBlockExpanded) { newValue in
            if newValue {
                secondBlockExpanded = false
            }
        }
        .onChange(of: secondBlockExpanded) { newValue in
            if newValue {
                firstBlockExpanded = false
                AnytypeAnalytics.instance().logMigrationGoneWrong(type: .complete)
            }
        }
    }
}


struct MigrationGuideView_Previews: PreviewProvider {
    static var previews: some View {
        MigrationGuideView()
    }
}
