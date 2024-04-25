import SwiftUI
import AnytypeCore
import Logger

struct DebugMenuView: View {
    
    @StateObject private var model: DebugMenuViewModel
    
    @State private var showLogs = false
    @State private var showTypography = false
    @State private var showFeedbackGenerators = false
    @State private var showGradientIcons = false
    @State private var showControls = false
    @State private var showColors = false
    @State private var showObjectIcons = false
    
    init() {
        _model = StateObject(wrappedValue: DebugMenuViewModel())
    }
    
    var body: some View {
        VStack {
            DragIndicator()
            AnytypeText("Debug menu 👻", style: .title)
                .foregroundColor(.Text.primary)
            ScrollView {
                VStack(spacing: 0) {
                    buttons
                    setPageCounter
                    toggles
                }
            }
        }
        .background(Color.Background.primary)
        .navigationBarHidden(true)
        .embedInNavigation()
    }
    
    @State var rowsPerPageInSet = "\(UserDefaultsConfig.rowsPerPageInSet)"
    private var setPageCounter: some View {
        HStack {
            AnytypeText("Number of rows per page in set", style: .bodyRegular)
                .foregroundColor(.Text.primary)
                .frame(maxWidth: .infinity)
            TextField("Pages", text: $rowsPerPageInSet)
                .textFieldStyle(.roundedBorder)
                .frame(width: 100)
        }
        .padding(20)
        .onChange(of: rowsPerPageInSet) { count in
            guard let count = Int(count) else { return }
            UserDefaultsConfig.rowsPerPageInSet = count
        }
    }
    
    private var buttons: some View {
        VStack {
            HStack {
                StandardButton("Logs 🧻", style: .secondaryLarge) {
                    showLogs.toggle()
                }
                StandardButton("Typography 🦭", style: .secondaryLarge) {
                    showTypography.toggle()
                }
            }
            HStack {
                StandardButton("Crash 🔥", style: .primaryLarge) {
                    let crash: [Int] = []
                    _ = crash[1]
                }
                StandardButton("Assert 🥲", style: .secondaryLarge) {
                    anytypeAssertionFailure("Test assert")
                }
            }
            
            HStack {
                StandardButton("Controls 🎛️", style: .secondaryLarge) {
                    UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                    showControls.toggle()
                }
                StandardButton("Space icons 🟣", style: .secondaryLarge) {
                    UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                    showGradientIcons.toggle()
                }
            }
            
            HStack {
                StandardButton("Colors 🌈", style: .secondaryLarge) {
                    UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                    showColors.toggle()
                }
                
                StandardButton("Object icons 📸", style: .secondaryLarge) {
                    UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                    showObjectIcons.toggle()
                }
            }
            StandardButton("Feedback Generator 🃏", style: .secondaryLarge) {
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                showFeedbackGenerators.toggle()
            }
            StandardButton("Export localstore data as json 📁", style: .secondaryLarge) {
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                model.getLocalStoreData()
            }
            StandardButton("Debug stack Goroutines 💤", style: .secondaryLarge) {
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                model.getGoroutinesData()
            }
            AsyncStandardButton(text: "Space debug 🪐", style: .secondaryLarge) {
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                try await model.onSpaceDebug()
            }
            StandardButton("Export full directory 🤐", style: .secondaryLarge) {
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                model.zipWorkingDirectory()
            }
            StandardButton("Import full directory 📲", style: .secondaryLarge) {
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                model.unzipWorkingDirectory()
            }
            StandardButton(
                "Remove Key from device",
                inProgress: model.isRemovingRecoveryPhraseInProgress,
                style: .warningLarge
            ) {
                model.removeRecoveryPhraseFromDevice()
            }
        }
        .padding(.horizontal)
        .padding()
        .sheet(isPresented: $showLogs) { LoggerUI.makeView() }
        .sheet(isPresented: $showTypography) { TypographyExample() }
        .sheet(isPresented: $showFeedbackGenerators) { FeedbackGeneratorExamplesView() }
        .sheet(isPresented: $showGradientIcons) { GradientIconsExamples() }
        .sheet(isPresented: $showControls) { ControlsExample() }
        .sheet(isPresented: $showColors) { ColorsExample() }
        .sheet(isPresented: $showObjectIcons) { ObjectIconExample() }
        .sheet(item: $model.shareUrlFile) { url in
            ActivityViewController(activityItems: [url], applicationActivities: nil)
        }
        .sheet(isPresented: $model.showZipPicker) {
            DocumentPicker(contentTypes: [.zip]) { url in
                model.onSelectUnzipFile(url: url)
            }
        }
    }
    
    var toggles: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(model.flags, id: \.title) { section in
                AnytypeText(section.title, style: .heading)
                    .foregroundColor(.Text.primary)
                    .padding()
                VStack(spacing: 0) {
                    ForEach(section.rows, id: \.description.title) { row in
                        FeatureFlagView(model: row)
                    }
                }
                .padding(.horizontal)
                .background(UIColor.secondarySystemGroupedBackground.suColor)
                .cornerRadius(20, style: .continuous)
            }
        }
        .padding(.horizontal, 20)
        .background(UIColor.systemGroupedBackground.suColor)
    }
}

extension URL: Identifiable {
    public var id: String { absoluteString }
}
