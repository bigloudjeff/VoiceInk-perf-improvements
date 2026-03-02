//
//  VoiceInkUITests.swift
//  VoiceInkUITests
//
//  Created by Prakash Joshi on 15/10/2024.
//

import XCTest

final class VoiceInkUITests: XCTestCase {

 override func setUpWithError() throws {
  continueAfterFailure = false
 }

 @MainActor
 func testSidebarNavigationExists() throws {
  let app = XCUIApplication()
  app.launch()

  let sidebar = app.outlines["sidebar.list"]
  XCTAssertTrue(sidebar.waitForExistence(timeout: 5), "Sidebar list should exist")

  // Verify core navigation links are present
  let expectedLinks = [
   "sidebar.navLink.Dashboard",
   "sidebar.navLink.Transcribe Audio",
   "sidebar.navLink.AI Models",
   "sidebar.navLink.Enhancement",
   "sidebar.navLink.Post Processing",
   "sidebar.navLink.Permissions",
   "sidebar.navLink.Audio Input",
   "sidebar.navLink.Dictionary",
   "sidebar.navLink.Settings",
   "sidebar.navLink.VoiceInk Pro",
  ]

  for linkID in expectedLinks {
   let link = sidebar.buttons[linkID]
   XCTAssertTrue(link.waitForExistence(timeout: 3), "Navigation link '\(linkID)' should exist")
  }

  // Verify history button exists (it's a plain button, not a NavigationLink)
  let historyButton = sidebar.buttons["sidebar.button.history"]
  XCTAssertTrue(historyButton.waitForExistence(timeout: 3), "History button should exist")
 }

 @MainActor
 func testSidebarNavigationTap() throws {
  let app = XCUIApplication()
  app.launch()

  let sidebar = app.outlines["sidebar.list"]
  XCTAssertTrue(sidebar.waitForExistence(timeout: 5))

  // Tap Settings and verify the detail view updates
  let settingsLink = sidebar.buttons["sidebar.navLink.Settings"]
  XCTAssertTrue(settingsLink.waitForExistence(timeout: 3))
  settingsLink.click()

  // Tap AI Models
  let modelsLink = sidebar.buttons["sidebar.navLink.AI Models"]
  XCTAssertTrue(modelsLink.waitForExistence(timeout: 3))
  modelsLink.click()

  // Tap Enhancement
  let enhancementLink = sidebar.buttons["sidebar.navLink.Enhancement"]
  XCTAssertTrue(enhancementLink.waitForExistence(timeout: 3))
  enhancementLink.click()
 }

 @MainActor
 func testLaunchPerformance() throws {
  if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
   measure(metrics: [XCTApplicationLaunchMetric()]) {
    XCUIApplication().launch()
   }
  }
 }
}
