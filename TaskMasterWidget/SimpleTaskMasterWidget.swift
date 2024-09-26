//
//  SimpleTaskMasterWidget.swift
//  SimpleTaskMasterWidget
//
//  Created by Genki on 9/25/24.
//

import WidgetKit
import SwiftUI

struct SimpleProvider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date.now, issues: [.example])
    }
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        let entry = SimpleEntry(date: Date.now, issues: loadIssues())
        completion(entry)
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        let entry = SimpleEntry(date: Date.now, issues: loadIssues())
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }
    func loadIssues() -> [Issue] {
        let dataController = DataController()
        let request = dataController.fetchRequestForTopIssues(count: 1)
        return dataController.results(for: request)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let issues: [Issue]
}

struct SimpleTaskMasterWidgetEntryView: View {
    var entry: SimpleProvider.Entry

    var body: some View {
        VStack {
            Text("次のタスクは...")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            if let issue = entry.issues.first {
                Text(issue.issueTitle)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                Text("タスクはありません！")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

struct SimpleTaskMasterWidget: Widget {
    let kind: String = "SimpleTaskMasterWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SimpleProvider()) { entry in
            if #available(iOS 17.0, *) {
                SimpleTaskMasterWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                SimpleTaskMasterWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("次のタスクは...")
        .description("あなたにとって最も優先度の高いタスクです。")
        .supportedFamilies([.systemSmall])
    }
}

#Preview(as: .systemSmall) {
    SimpleTaskMasterWidget()
} timeline: {
    SimpleEntry(date: .now, issues: [.example])
    SimpleEntry(date: .now, issues: [.example])
}
