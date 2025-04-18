import WidgetKit
import SwiftUI
import Intents
import DeepLinks
import AppTarget
import Loc

struct StaticProvider: TimelineProvider {
    typealias Entry = SimpleEntry

    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        let entry = SimpleEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
}

struct AnytypeWidgetEntryView : View {
    var entry: StaticProvider.Entry

    #if DEBUG || RELEASE_NIGHTLY
        private let deepLinkParser = DeepLinkDI.shared.parser(targetType: .debug)
    #elseif RELEASE_ANYTYPE
        private let deepLinkParser = DeepLinkDI.shared.parser(targetType: .releaseAnytype)
    #elseif RELEASE_ANYAPP
        private let deepLinkParser = DeepLinkDI.shared.parser(targetType: .releaseAnyApp)
    #endif
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white)
                .opacity(0.12)
            Image(systemName: "plus")
                .resizable()
                .foregroundColor(Color.white)
                .frame(width: 24, height: 24)
        }
        .widgetAccentable()
        .widgetURL(deepLinkParser.createUrl(deepLink: .createObjectFromWidget, scheme: .buildSpecific))
    }
}

@main
struct AnytypeWidget: Widget {
    let kind: String = "AnytypeWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StaticProvider()) { entry in
            AnytypeWidgetEntryView(entry: entry)
        }
        .configurationDisplayName(Loc.WidgetExtension.LockScreen.title)
        .description(Loc.WidgetExtension.LockScreen.description)

        .supportedFamilies([.accessoryCircular])
    }
}

struct AnytypeWidget_Previews: PreviewProvider {
    static var previews: some View {
        AnytypeWidgetEntryView(entry: SimpleEntry(date: Date()))
            .previewContext(WidgetPreviewContext(family: .accessoryCircular))
    }
}
