//
//  DataController.swift
//  TaskMaster
//
//  Created by Genki on 9/22/24.
//

import CoreData

enum SortType: String {
    case dateCreated = "creationDate"
    case dateModified = "modificationDate"
}

enum Status {
    case all, open, closed
}
/// 保存の処理、フェッチリクエスト、称号の追跡、サンプルデータの処理など、
/// Core Dataスタックの管理を担当するシングルトン。
class DataController: ObservableObject {
    /// すべてのデータを保存するために使用される唯一のCloudKitコンテナ。
    let container: NSPersistentCloudKitContainer
    @Published var selectedFilter: Filter? = Filter.all
    @Published var selectedIssue: Issue?
    @Published var filterText = ""
    @Published var filterTokens = [Tag]()
    @Published var filterEnabled = false
    @Published var filterPriority = -1
    @Published var filterStatus = Status.all
    @Published var sortType = SortType.dateCreated
    @Published var sortNewestFirst = true
    private var saveTask: Task<Void, Error>?
    static var preview: DataController = {
        let dataController = DataController(inMemory: true)
        dataController.createSampleData()
        return dataController
    }()
    var suggestedFilterTokens: [Tag] {
        guard filterText.starts(with: "#") else {
            return []
        }

        let trimmedFilterText = String(filterText.dropFirst()).trimmingCharacters(in: .whitespaces)
        let request = Tag.fetchRequest()

        if trimmedFilterText.isEmpty == false {
            request.predicate = NSPredicate(format: "name CONTAINS[c] %@", trimmedFilterText)
        }

        return (try? container.viewContext.fetch(request).sorted()) ?? []
    }
    static let model: NSManagedObjectModel = {
        guard let url = Bundle.main.url(forResource: "Main", withExtension: "momd") else {
            fatalError("モデルファイルが見つかりませんでした。")
        }
        guard let managedObjectModel = NSManagedObjectModel(contentsOf: url) else {
            fatalError("モデルファイルが見つかりませんでした。")
        }
        return managedObjectModel
    }()
    /// DataControllerをメモリ内 (テストやプレビューなどの一時的な使用)、または永続的なストレージ (通常のアプリ実行での使用) で初期化する。
    /// - Parameter inMemory: このデータを一時メモリに保存するかどうか。
    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "Main", managedObjectModel: Self.model)
        // テストとプレビューの目的で、/dev/nullに書き込むことで一時的なメモリ内データベースを作成する。
        // アプリの実行が終了するとデータが破棄される。
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(filePath: "/dev/null")
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        
        // すべての変更について iCloudを監視し、リモートの変更が発生したときにローカルUIが確実に同期されるようにする。
        container.persistentStoreDescriptions.first?.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        NotificationCenter.default.addObserver(forName: .NSPersistentStoreRemoteChange, object: container.persistentStoreCoordinator, queue: .main, using: remoteStoreChanged)
        container.loadPersistentStores { _, error in
            if let error {
                fatalError("エラーが発生しました: \(error.localizedDescription)")
            }
        }
    }
    func remoteStoreChanged(_ notification: Notification) {
        objectWillChange.send()
    }
    func createSampleData() {
        let viewContext = container.viewContext

        for i in 1...5 {
            let tag = Tag(context: viewContext)
            tag.id = UUID()
            tag.name = "タグ \(i)"

            for j in 1...10 {
                let issue = Issue(context: viewContext)
                issue.title = "タスク \(i)-\(j)"
                issue.content = ""
                issue.creationDate = .now
                issue.completed = Bool.random()
                issue.priority = Int16.random(in: 0...2)
                tag.addToIssues(issue)
            }
        }

        try? viewContext.save()
    }
    func save() {
        saveTask?.cancel()

        if container.viewContext.hasChanges {
            try? container.viewContext.save()
        }
    }
    func queueSave() {
        saveTask?.cancel()

        saveTask = Task { @MainActor in
            try await Task.sleep(for: .seconds(3))
            save()
        }
    }
    func delete(_ object: NSManagedObject) {
        objectWillChange.send()
        container.viewContext.delete(object)
        save()
    }
    private func delete(_ fetchRequest: NSFetchRequest<NSFetchRequestResult>) {
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        batchDeleteRequest.resultType = .resultTypeObjectIDs

        // ⚠️バッチ削除を実行するときは、必ず結果を読み戻して、
        // その結果からのすべての変更をライブビューコンテキストにマージして、
        // 2つが同期された状態を保つ必要がある。
        if let delete = try? container.viewContext.execute(batchDeleteRequest) as? NSBatchDeleteResult {
            let changes = [NSDeletedObjectsKey: delete.result as? [NSManagedObjectID] ?? []]
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [container.viewContext])
        }
    }
    func deleteAll() {
        let request1: NSFetchRequest<NSFetchRequestResult> = Tag.fetchRequest()
        delete(request1)

        let request2: NSFetchRequest<NSFetchRequestResult> = Issue.fetchRequest()
        delete(request2)

        save()
    }
    func missingTags(from issue: Issue) -> [Tag] {
        let request = Tag.fetchRequest()
        let allTags = (try? container.viewContext.fetch(request)) ?? []

        let allTagsSet = Set(allTags)
        let difference = allTagsSet.symmetricDifference(issue.issueTags)

        return difference.sorted()
    }
    /// タグ、タイトルと説明文、検索値、優先度、ステータスに基づいて、
    /// ユーザーのタスクをフィルターするさまざまな要素を使用してフェッチ リクエストを実行。
    /// - Returns: 一致するすべてのタスクの配列。
    func issuesForSelectedFilter() -> [Issue] {
        let filter = selectedFilter ?? .all
        var predicates = [NSPredicate]()

        if let tag = filter.tag {
            let tagPredicate = NSPredicate(format: "tags CONTAINS %@", tag)
            predicates.append(tagPredicate)
        } else {
            let datePredicate = NSPredicate(format: "modificationDate > %@", filter.minModificationDate as NSDate)
            predicates.append(datePredicate)
        }
        let trimmedFilterText = filterText.trimmingCharacters(in: .whitespaces)
        if trimmedFilterText.isEmpty == false {
            let titlePredicate = NSPredicate(format: "title CONTAINS[c] %@", trimmedFilterText)
            let contentPredicate = NSPredicate(format: "content CONTAINS[c] %@", trimmedFilterText)
            let combinedPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [titlePredicate, contentPredicate])
            predicates.append(combinedPredicate)
        }
        if filterTokens.isEmpty == false {
            for filterToken in filterTokens {
                let tokenPredicate = NSPredicate(format: "tags CONTAINS %@", filterToken)
                predicates.append(tokenPredicate)
            }
        }
        if filterEnabled {
            if filterPriority >= 0 {
                let priorityFilter = NSPredicate(format: "priority = %d", filterPriority)
                predicates.append(priorityFilter)
            }

            if filterStatus != .all {
                let lookForClosed = filterStatus == .closed
                let statusFilter = NSPredicate(format: "completed = %@", NSNumber(value: lookForClosed))
                predicates.append(statusFilter)
            }
        }

        let request = Issue.fetchRequest()
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        request.sortDescriptors = [NSSortDescriptor(key: sortType.rawValue, ascending: sortNewestFirst)]

        let allIssues = (try? container.viewContext.fetch(request)) ?? []
        return allIssues
    }
    func newTag() {
        let tag = Tag(context: container.viewContext)
        tag.id = UUID()
        tag.name = "新しいタグ"
        save()
    }
    func newIssue() {
        let issue = Issue(context: container.viewContext)
        issue.title = "新しいタスク"
        issue.creationDate = .now
        issue.priority = 1
        
        // 現在、ユーザーが作成したタグを参照している場合は、
        // この新しいタスクをタグに追加する。そうしないと、タスクのリストに表示されないため。
        if let tag = selectedFilter?.tag {
            issue.addToTags(tag)
        }
        save()
        selectedIssue = issue
    }
    func count<T>(for fetchRequest: NSFetchRequest<T>) -> Int {
        (try? container.viewContext.count(for: fetchRequest)) ?? 0
    }
    func hasEarned(award: Award) -> Bool {
        switch award.criterion {
        case "issues":
            let fetchRequest = Issue.fetchRequest()
            let awardCount = count(for: fetchRequest)
            return awardCount >= award.value

        case "closed":
            let fetchRequest = Issue.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "completed = true")
            let awardCount = count(for: fetchRequest)
            return awardCount >= award.value

        case "tags":
            let fetchRequest = Tag.fetchRequest()
            let awardCount = count(for: fetchRequest)
            return awardCount >= award.value

        default:
            // fatalError("Unknown award criterion: \(award.criterion)")
            return false
        }
    }
}
