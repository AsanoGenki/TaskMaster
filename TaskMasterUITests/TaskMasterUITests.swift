//
//  TaskMasterUITests.swift
//  TaskMasterUITests
//
//  Created by Genki on 9/23/24.
//

import XCTest

extension XCUIElement {
    func clear() {
        guard let stringValue = self.value as? String else {
            XCTFail("XCUIElement 内のテキストをクリアできませんでした。")
            return
        }
        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: stringValue.count)
        typeText(deleteString)
    }
}

final class TaskMasterUITests: XCTestCase {
    var app: XCUIApplication!
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["enable-testing"]
        app.launch()
    }
    func testAppStartsWithNavigationBar() throws {
        let app = XCUIApplication()
        app.launchArguments = ["enable-testing"]
        app.launch()
        XCTAssertTrue(app.navigationBars.element.exists, "アプリを起動するとナビゲーションバーが表示されます。")
    }
    func testNoIssuesAtStart() {
        XCTAssertEqual(app.cells.count, 0, "最初はリストにアイテムは存在しません。")
    }
    func testAppHasBasicButtonsOnLaunch() throws {
        XCTAssertTrue(app.navigationBars.buttons["フィルター"].exists, "「フィルター」というボタンが起動時に存在している必要があります。")
        XCTAssertTrue(app.navigationBars.buttons["並び替え"].exists, "「並び替え」というボタンが起動時に存在している必要があります。")
        XCTAssertTrue(app.navigationBars.buttons["新しいタスク"].exists, "「新しいタスク」というボタンが起動時に存在している必要があります。")
    }
    func testCreatingAndDeletingIssues() {
        for tapCount in 1...5 {
            app.buttons["新しいタスク"].tap()
            app.buttons["タスク"].tap()
            XCTAssertEqual(app.cells.count, tapCount, "\(tapCount)個のタスクがリストに存在しています。")
        }
        for tapCount in (0...4).reversed() {
            app.cells.firstMatch.swipeLeft()
            app.buttons["Delete"].tap()
            XCTAssertEqual(app.cells.count, tapCount, "\(tapCount)個のタスクがリストに存在しています。")
        }
    }
    func testEditingIssueTitleUpdatesCorrectly() {
        XCTAssertEqual(app.cells.count, 0, "There should be no list rows initially.")
        app.buttons["新しいタスク"].tap()
        app.textFields["タイトル"].tap()
        app.textFields["タイトル"].clear()
        app.typeText("新しいタイトル")
        app.buttons["タスク"].tap()
        XCTAssertTrue(app.buttons["新しいタイトル"].exists, "「新しいタイトル」というタスクがリストに存在している必要があります。")
    }
    func testEditingIssuePriorityShowsIcon() {
        app.buttons["新しいタスク"].tap()
        app.buttons["優先度, 中"].tap()
        app.buttons["高"].tap()
        app.buttons["タスク"].tap()
        let identifier = "新しいタスク 高い優先度"
        XCTAssert(app.images[identifier].exists, "優先度の高いタスクの横にはアイコンが必要です。")
    }
    func testAllAwardsShowLockedAlert() {
        app.buttons["フィルター"].tap()
        app.buttons["称号の表示"].tap()
        let window = app.windows.element(boundBy: 0)
        for award in app.scrollViews.buttons.allElementsBoundByIndex {
            while !window.frame.contains(award.frame) {
                app.scrollViews.element.swipeUp()
            }
            award.tap()
            XCTAssertTrue(app.alerts["未獲得"].exists, "称号には未獲得という警告が表示される必要があります。")
            app.buttons["OK"].tap()
        }
    }
}
