import SwiftUI
import AnytypeCore
import Logger
import Loc

struct DebugMenuView: View {
    
    @StateObject private var model = DebugMenuViewModel()
    
    @State private var showLogs = false
    @State private var showTypography = false
    @State private var showFeedbackGenerators = false
    @State private var showGradientIcons = false
    @State private var showControls = false
    @State private var showColors = false
    @State private var showObjectIcons = false
    @State private var showMembershipDebug = false
    @State private var showHomepagePicker = false
    
    var body: some View {
        VStack {
            DragIndicator()
            VStack {
                AnytypeText("Internal debug menu 👻", style: .title)
                    .foregroundStyle(Color.Text.primary)
                AnytypeText("Environment: \(BuildTypeProvider.buidType.rawValue)", style: .caption1Medium)
                    .foregroundStyle(Color.Text.tertiary)
            }.padding()
            
            ScrollView {
                VStack(spacing: 0) {
                    buttonsMenu
                    Spacer.fixedHeight(20)
                    toggles
                    setPageCounter
                    currentVersionInput
                    removeKey
                }
            }
        }
        .background(Color.Background.primary)
        .navigationBarHidden(true)
        .embedInNavigation()
        
        .onAppear {
            rowsPerPageInSet = "\(model.userDefaults.rowsPerPageInSet)"
            currentVersion = model.userDefaults.currentVersionOverride
        }
    }
    
    private var buttonsMenu: some View {
        VStack {
            mainActions
            
            HStack {
                Menu {
                    moreActions
                } label: {
                    StandardButton("More actions ℹ️", style: .borderlessLarge) {}
                }
                
                Menu {
                    designSystem
                } label: {
                    StandardButton("Design system 💅", style: .borderlessLarge) {}
                }
            }
        }
        .padding(.horizontal)
        
        .sheet(isPresented: $showLogs) { LoggerUI.makeView() }
        .sheet(isPresented: $showTypography) { TypographyExample() }
        .sheet(isPresented: $showFeedbackGenerators) { FeedbackGeneratorExamplesView() }
        .sheet(isPresented: $showGradientIcons) { GradientIconsExamples() }
        .sheet(isPresented: $showControls) { ControlsExample() }
        .sheet(isPresented: $showColors) { ColorsExample() }
        .sheet(isPresented: $showObjectIcons) { ObjectIconExample() }
        .sheet(isPresented: $showMembershipDebug) { MembershipDebugView() }
        .sheet(isPresented: $showHomepagePicker) {
            HomepagePickerView(spaceId: "") { result in
                print("HomepagePicker result: \(result)")
            }
            .interactiveDismissDisabled(true)
        }
        .sheet(item: $model.shareUrlFile) { url in
            ActivityViewController(activityItems: [url], applicationActivities: nil)
        }
        .sheet(isPresented: $model.showZipPicker) {
            DocumentPicker(contentTypes: [.zip]) { url in
                model.onSelectUnzipFile(url: url)
            }
        }
        .anytypeSheet(item: $model.pushToken) {
            DebugMenuPushTokenAlert(token: $0.value)
        }
        .anytypeSheet(item: $model.secureAlertData) {
            SecureAlertView(data: $0)
        }
    }
    
    private var mainActions: some View {
        VStack {
            StandardButton("Logs 🧻", style: .secondaryLarge) {
                showLogs.toggle()
            }
            
            AsyncStandardButton("Export localstore 📁", style: .secondaryLarge) {
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                try await model.getLocalStoreData()
            }
            
            if case .done(url: let url) = model.debugRunProfilerData {
                StandardButton("Download Debug Run Profiler Data 💿", style: .secondaryLarge) {
                    UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                    model.shareUrlContent(url: url)
                }
            }
            
            StandardButton("Homepage Picker Preview 🏠", style: .secondaryLarge) {
                showHomepagePicker = true
            }

            Toggle(isOn: Binding(
                get: { model.shouldRunDebugProfilerOnNextStartup } ,
                set: { model.shouldRunDebugProfilerOnNextStartup = $0 }
            )) {
                AnytypeText("Run Debug Profiler On Next Startup", style: .bodyRegular)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }.padding()
        }
    }
    
    private var moreActions: some View {
        VStack {
            StandardButton("Crash 🔥", style: .primaryLarge) {
                let crash: [Int] = []
                _ = crash[1]
            }
            
            StandardButton("Unhandled exit 🚪", style: .primaryLarge) {
                exit(1)
            }
            
            StandardButton("Assert 🥲", style: .secondaryLarge) {
                anytypeAssertionFailure("Test assert")
            }
            
            StandardButton("Membership debug 💸", style: .secondaryLarge) {
                UISelectionFeedbackGenerator().selectionChanged()
                showMembershipDebug.toggle()
            }
            
            AsyncStandardButton("Debug stack Goroutines 💤", style: .secondaryLarge) {
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                try await model.getGoroutinesData()
            }

            StandardButton(
                model.debugServerURL.map { "Debug Server: \($0)" } ?? "Run Debug Server 🖥️",
                style: .secondaryLarge
            ) {
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                if let url = model.debugServerURL {
                    UIPasteboard.general.string = url
                } else {
                    model.startDebugServer()
                }
            }
            StandardButton(model.debugRunProfilerData.text, style: .secondaryLarge) {
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                model.onDebugRunProfiler()
            }
    
            AsyncStandardButton("Debug stat 🫵🐭", style: .secondaryLarge) {
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                try await model.debugStat()
            }
            
            AsyncStandardButton("Export full directory 🤐", style: .secondaryLarge) {
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                try await model.zipWorkingDirectory()
            }
            StandardButton("Import full directory 📲", style: .secondaryLarge) {
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                model.unzipWorkingDirectory()
            }
            Button {
                model.getFirebaseNotificationToken()
            } label: {
                Text("Firebase notification Token 🔔")
            }
            
            Button {
                model.getAppleNotificationToken()
            } label: {
                Text("Apple notification Token 🔔")
            }
            
            AsyncButton {
                try await model.readAllMessages()
            } label: {
                Text("Read all messages 💬")
            }
        }
    }
    
    private var designSystem: some View {
        VStack {
            StandardButton("Typography 🦭", style: .secondaryLarge) {
                showTypography.toggle()
            }
            
            StandardButton("Controls 🎛️", style: .secondaryLarge) {
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                showControls.toggle()
            }
            StandardButton("Space icons 🟣", style: .secondaryLarge) {
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                showGradientIcons.toggle()
            }
            
            StandardButton("Colors 🌈", style: .secondaryLarge) {
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                showColors.toggle()
            }
            
            StandardButton("Object icons 📸", style: .secondaryLarge) {
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                showObjectIcons.toggle()
            }
            
            StandardButton("Feedback Generator 🃏", style: .secondaryLarge) {
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                showFeedbackGenerators.toggle()
            }
        }
    }
    
    
    var toggles: some View {
        VStack(alignment: .leading, spacing: 0) {
            searchBar
            
            ForEach(model.filteredSections, id: \.title) { section in
                DisclosureGroup(
                    isExpanded: Binding(
                        get: { model.sectionExpanded[section.title] ?? true },
                        set: { model.sectionExpanded[section.title] = $0 }
                    )
                ) {
                    VStack(spacing: 0) {
                        ForEach(section.rows, id: \.description.title) { row in
                            FeatureFlagView(model: row)
                        }
                    }
                } label: {
                    AnytypeText(section.title, style: .heading)
                        .foregroundStyle(Color.Text.primary)
                        .padding()
                }
            }
        }
        .padding(.horizontal, 20)
        .background(UIColor.systemGroupedBackground.suColor)
        .clipShape(UnevenRoundedRectangle(topLeadingRadius: 20, topTrailingRadius: 20))
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Color.Text.secondary)
            
            TextField(Loc.search, text: $model.searchText)
                .textFieldStyle(PlainTextFieldStyle())
                .font(AnytypeFontBuilder.font(anytypeFont: .bodyRegular))
                .foregroundStyle(Color.Text.primary)
            
            if !model.searchText.isEmpty {
                Button {
                    model.searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Color.Text.secondary)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.Background.secondary)
        .clipShape(.rect(cornerRadius: 10))
        .padding(.vertical, 12)
    }
    
    @State var rowsPerPageInSet = ""
    private var setPageCounter: some View {
        DebugMenuInputSettings(
            title: "Number of rows per page in set",
            placeholder: "Pages",
            inputText: $rowsPerPageInSet
        )
        .onChange(of: rowsPerPageInSet) { _, count in
            guard let count = Int(count) else { return }
            model.userDefaults.rowsPerPageInSet = count
        }
    }
    
    @State var currentVersion = ""
    private var currentVersionInput: some View {
        DebugMenuInputSettings(
            title: "Custom current version for update banner (ex: 0.0.1)",
            placeholder: "Version",
            inputText: $currentVersion
        )
        .onChange(of: currentVersion) {
            model.userDefaults.currentVersionOverride = $1
        }
    }
    
    private var removeKey: some View {
        StandardButton(
            "Remove Key from device",
            inProgress: model.isRemovingRecoveryPhraseInProgress,
            style: .warningLarge
        ) {
            model.removeRecoveryPhraseFromDevice()
        }
        .padding()
        .background(UIColor.systemGroupedBackground.suColor)
        .clipShape(UnevenRoundedRectangle(bottomLeadingRadius: 20, bottomTrailingRadius: 20))
    }
}

extension URL: @retroactive Identifiable {
    public var id: String { absoluteString }
}

#Preview {
    DebugMenuView()
}
