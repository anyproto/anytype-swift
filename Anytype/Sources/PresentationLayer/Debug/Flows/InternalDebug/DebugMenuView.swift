import SwiftUI
import AnytypeCore
import Logger

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
    
    var body: some View {
        VStack {
            DragIndicator()
            VStack {
                AnytypeText("Internal debug menu 👻", style: .title)
                    .foregroundColor(.Text.primary)
                AnytypeText("Environment: \(BuildTypeProvider.buidType.rawValue)", style: .caption1Medium)
                    .foregroundColor(.Text.tertiary)
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
                Text("Firebase Notification Token 🔔")
            }
            
            Button {
                model.getAppleNotificationToken()
            } label: {
                Text("Apple Notification Token 🔔")
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
    
    
    @State private var expanded = true
    var toggles: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(model.flags, id: \.title) { section in
                DisclosureGroup(isExpanded: $expanded) {
                    VStack(spacing: 0) {
                        ForEach(section.rows, id: \.description.title) { row in
                            FeatureFlagView(model: row)
                        }
                    }
                } label: {
                    AnytypeText(section.title, style: .heading)
                        .foregroundColor(.Text.primary)
                        .padding()
                }
            }
        }
        .padding(.horizontal, 20)
        .background(UIColor.systemGroupedBackground.suColor)
        .cornerRadius(20, corners: .top)
    }
    
    @State var rowsPerPageInSet = ""
    private var setPageCounter: some View {
        DebugMenuInputSettings(
            title: "Number of rows per page in set",
            placeholder: "Pages",
            inputText: $rowsPerPageInSet
        )
        .onChange(of: rowsPerPageInSet) { count in
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
            model.userDefaults.currentVersionOverride = $0
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
        .cornerRadius(20, corners: .bottom)
    }
}

extension URL: @retroactive Identifiable {
    public var id: String { absoluteString }
}

#Preview {
    DebugMenuView()
}
