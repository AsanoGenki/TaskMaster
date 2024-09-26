//
//  IssueView.swift
//  TaskMaster
//
//  Created by Genki on 9/22/24.
//

import SwiftUI

struct IssueView: View {
    @ObservedObject var issue: Issue
    @EnvironmentObject var dataController: DataController
    @State private var showingNotificationsError = false
    @Environment(\.openURL) var openURL
    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading) {
                    TextField("タイトル", text: $issue.issueTitle, prompt: Text("タイトル"))
                        .font(.title)
                        .labelsHidden()
                    Text("**更新日:** \(issue.issueModificationDate.formatted(date: .long, time: .shortened))")
                        .foregroundStyle(.secondary)
                    Text("**ステータス:** \(issue.issueStatus)")
                        .foregroundStyle(.secondary)
                }
                Picker("優先度", selection: $issue.issuePriority) {
                    Text("低").tag(0)
                    Text("中").tag(1)
                    Text("高").tag(2)
                }
               TagsMenuView(issue: issue)
            }
            Section {
                VStack(alignment: .leading) {
                    Text("説明文")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                    TextField(
                        "説明",
                        text: $issue.issueContent,
                        prompt: Text("タスクの説明をここに記入..."),
                        axis: .vertical
                    )
                    .labelsHidden()
                }
            }
            Section("通知") {
                Toggle("通知", isOn: $issue.reminderEnabled.animation())
                if issue.reminderEnabled {
                   DatePicker(
                       "通知時刻",
                       selection: $issue.issueReminderTime,
                       displayedComponents: .hourAndMinute
                   )
                }
            }
        }
        .formStyle(.grouped)
        .disabled(issue.isDeleted)
        .onReceive(issue.objectWillChange) { _ in
            dataController.queueSave()
        }
        .onSubmit(dataController.save)
        .toolbar {
            IssueViewToolbar(issue: issue)
        }
        .alert("おっと！", isPresented: $showingNotificationsError) {
            #if os(macOS)
            SettingsLink {
                Text("Check Settings")
            }
            #else
            Button("設定で確認する", action: showAppSettings)
            #endif
            Button("キャンセル", role: .cancel) { }
        } message: {
            Text("通知の設定中に問題が発生しました。通知が有効になっていることを確認してください。")
        }
        .onChange(of: issue.reminderEnabled) {
            updateReminder()
        }
        .onChange(of: issue.reminderTime) {
            updateReminder()
        }
    }
    #if os(iOS)
    func showAppSettings() {
        guard let settingsURL = URL(string: UIApplication.openNotificationSettingsURLString) else {
            return
        }
        openURL(settingsURL)
    }
    #endif
    func updateReminder() {
        dataController.removeReminders(for: issue)
        Task { @MainActor in
            if issue.reminderEnabled {
                let success = await dataController.addReminder(for: issue)
                if success == false {
                    issue.reminderEnabled = false
                    showingNotificationsError = true
                }
            }
        }
    }
}

#Preview {
    IssueView(issue: .example)
}
