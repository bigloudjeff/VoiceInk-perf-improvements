import Foundation
import SwiftUI
import os

// MARK: - UI Management Extension (thin forwarders to RecorderUICoordinator)
extension WhisperState {

 // MARK: - Recorder Panel Forwarding

 func showRecorderPanel() {
  recorderUICoordinator.showRecorderPanel()
 }

 func hideRecorderPanel() {
  recorderUICoordinator.hideRecorderPanel()
 }

 func toggleMiniRecorder(powerModeId: UUID? = nil) async {
  await recorderUICoordinator.toggleMiniRecorder(powerModeId: powerModeId)
 }

 func dismissMiniRecorder() async {
  await recorderUICoordinator.dismissMiniRecorder()
 }

 func resetOnLaunch() async {
  await recorderUICoordinator.resetOnLaunch()
 }

 func cancelRecording() async {
  await recorderUICoordinator.cancelRecording()
 }

 @objc public func handleToggleMiniRecorder() {
  recorderUICoordinator.handleToggleMiniRecorder()
 }

 @objc public func handleDismissMiniRecorder() {
  recorderUICoordinator.handleDismissMiniRecorder()
 }

 // MARK: - Notification Setup

 func setupNotifications() {
  recorderUICoordinator.setupRecorderNotifications()
  NotificationCenter.default.addObserver(self, selector: #selector(handleLicenseStatusChanged), name: .licenseStatusChanged, object: nil)
  NotificationCenter.default.addObserver(self, selector: #selector(handlePromptChange), name: .promptDidChange, object: nil)
 }

 @objc func handleLicenseStatusChanged() {
  licenseViewModel.refresh()
 }

 @objc func handlePromptChange() {
  Task {
   await updateContextPrompt()
  }
 }

 private func updateContextPrompt() async {
  let basePrompt = UserDefaults.standard.string(forKey: UserDefaults.Keys.transcriptionPrompt) ?? whisperPrompt.transcriptionPrompt
  let vocabularyString = CustomVocabularyService.shared.getTranscriptionVocabulary(from: modelContext)
  let fullPrompt = vocabularyString.isEmpty ? basePrompt : basePrompt + " " + vocabularyString
  if let context = whisperContext {
   await context.setPrompt(fullPrompt)
  }
 }
}

// MARK: - RecorderUICoordinatorDelegate

extension WhisperState: RecorderUICoordinatorDelegate {}
