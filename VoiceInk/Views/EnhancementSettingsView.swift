import SwiftUI
import UniformTypeIdentifiers

struct EnhancementSettingsView: View {
    @EnvironmentObject private var enhancementService: AIEnhancementService
    @State private var isEditingPrompt = false
    @State private var isShortcutsExpanded = false
    @AppStorage(UserDefaults.Keys.prewarmEnhancementModel) private var prewarmEnhancementModel = false
    @AppStorage(UserDefaults.Keys.prewarmInactivityThreshold) private var prewarmInactivityThreshold = 5
    @State private var selectedPromptForEdit: CustomPrompt?
    @State private var isSystemInstructionsExpanded = false
    
    private var isPanelOpen: Bool {
        isEditingPrompt || selectedPromptForEdit != nil
    }
    
    private func closePanel() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
            isEditingPrompt = false
            selectedPromptForEdit = nil
        }
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Form {
                Section {
                    Toggle(isOn: $enhancementService.isEnhancementEnabled) {
                        HStack(spacing: 4) {
                            Text("AI Enhancement")
                            InfoTip(
                                "When enabled, your transcriptions are enhanced by AI before pasting.",
                                learnMoreURL: "https://tryvoiceink.com/docs/enhancements-configuring-models"
                            )
                        }
                    }
                    .toggleStyle(.switch)
                    .accessibilityIdentifier(AccessibilityID.Enhancement.toggleAIEnhancement)

                    HStack(spacing: 24) {
                        Toggle(isOn: $enhancementService.useClipboardContext) {
                            HStack(spacing: 4) {
                                Text("Clipboard Context")
                                InfoTip("Use clipboard text to understand context for better enhancement.")
                            }
                        }
                        .toggleStyle(.switch)
                        .accessibilityIdentifier(AccessibilityID.Enhancement.toggleClipboardContext)

                        Toggle(isOn: $enhancementService.useScreenCaptureContext) {
                            HStack(spacing: 4) {
                                Text("Screen Context")
                                InfoTip("Capture on-screen text to understand context for better enhancement.")
                            }
                        }
                        .toggleStyle(.switch)
                        .accessibilityIdentifier(AccessibilityID.Enhancement.toggleScreenContext)
                    }
                    .opacity(enhancementService.isEnhancementEnabled ? 1.0 : 0.8)

                    Toggle(isOn: $prewarmEnhancementModel) {
                        HStack(spacing: 4) {
                            Text("Prewarm Enhancement Model")
                            InfoTip("Pre-loads your AI model when recording starts. Useful for local model hosts (LM Studio, Ollama) that unload models after inactivity.")
                        }
                    }
                    .toggleStyle(.switch)

                    if prewarmEnhancementModel {
                        HStack {
                            Text("Inactivity Threshold")
                            InfoTip("Only prewarm if no enhancement has run within this time. Avoids unnecessary requests when the model is already loaded.")
                            Spacer()
                            Picker("", selection: $prewarmInactivityThreshold) {
                                Text("1 min").tag(1)
                                Text("2 min").tag(2)
                                Text("5 min").tag(5)
                                Text("10 min").tag(10)
                                Text("15 min").tag(15)
                                Text("30 min").tag(30)
                            }
                            .frame(width: 100)
                        }
                    }
                } header: {
                    Text("General")
                }
                
                APIKeyManagementView()
                    .opacity(enhancementService.isEnhancementEnabled ? 1.0 : 0.8)
                
                Section {
                    ReorderablePromptGrid(
                        selectedPromptId: enhancementService.selectedPromptId,
                        onPromptSelected: { prompt in
                            enhancementService.setActivePrompt(prompt)
                        },
                        onEditPrompt: { prompt in
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                                selectedPromptForEdit = prompt
                            }
                        },
                        onDeletePrompt: { prompt in
                            enhancementService.deletePrompt(prompt)
                        }
                    )
                    .padding(.vertical, 8)
                } header: {
                    HStack {
                        Text("Enhancement Prompts")
                        Spacer()
                        Button {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                                isEditingPrompt = true
                            }
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 18))
                                .symbolRenderingMode(.hierarchical)
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier(AccessibilityID.Enhancement.buttonAddPrompt)
                        .help("Add new prompt")
                    }
                }
                .opacity(enhancementService.isEnhancementEnabled ? 1.0 : 0.8)
                
                Section {
                    DisclosureGroup(isExpanded: $isSystemInstructionsExpanded) {
                        SystemInstructionsEditor()
                            .padding(.vertical, 8)
                    } label: {
                        HStack {
                            Text("System Instructions")
                                .font(.headline)
                                .foregroundColor(.primary)
                            Spacer()
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation {
                                isSystemInstructionsExpanded.toggle()
                            }
                        }
                    }
                }
                .opacity(enhancementService.isEnhancementEnabled ? 1.0 : 0.8)

                Section {
                    DisclosureGroup(isExpanded: $isShortcutsExpanded) {
                        EnhancementShortcutsView()
                            .padding(.vertical, 8)
                    } label: {
                        HStack {
                            Text("Shortcuts")
                            .font(.headline)
                            .foregroundColor(.primary)
                            Spacer()
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation {
                                isShortcutsExpanded.toggle()
                            }
                        }
                    }
                    .accessibilityIdentifier(AccessibilityID.Enhancement.toggleShortcutsDisclosure)
                }
                .opacity(enhancementService.isEnhancementEnabled ? 1.0 : 0.8)
            }
            .formStyle(.grouped)
            .scrollContentBackground(.hidden)
            .background(Color(NSColor.controlBackgroundColor))
            .disabled(isPanelOpen)
            .blur(radius: isPanelOpen ? 2 : 0)
            .animation(.spring(response: 0.4, dampingFraction: 0.9), value: isPanelOpen)
            
            if isPanelOpen {
                Color.black.opacity(0.2)
                    .ignoresSafeArea()
                    .onTapGesture {
                        closePanel()
                    }
                    .transition(.opacity)
                    .zIndex(1)
            }
            
            if isPanelOpen {
                HStack(spacing: 0) {
                    Spacer()
                    
                    Group {
                        if let prompt = selectedPromptForEdit {
                            PromptEditorView(mode: .edit(prompt)) {
                                closePanel()
                            }
                        } else if isEditingPrompt {
                            PromptEditorView(mode: .add) {
                                closePanel()
                            }
                        }
                    }
                    .frame(width: 450)
                    .frame(maxHeight: .infinity)
                    .background(
                        Color(NSColor.windowBackgroundColor)
                    )
                    .overlay(
                        Divider(), alignment: .leading
                    )
                    .shadow(color: .black.opacity(0.15), radius: 12, x: -4, y: 0)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                }
                .ignoresSafeArea()
                .zIndex(2)
            }
        }
        .frame(minHeight: 400)
    }
}

// MARK: - Reorderable Grid
private struct ReorderablePromptGrid: View {
    @EnvironmentObject private var enhancementService: AIEnhancementService
    
    let selectedPromptId: UUID?
    let onPromptSelected: (CustomPrompt) -> Void
    let onEditPrompt: ((CustomPrompt) -> Void)?
    let onDeletePrompt: ((CustomPrompt) -> Void)?
    
    @State private var draggingItem: CustomPrompt?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if enhancementService.customPrompts.isEmpty {
                Text("No prompts available")
                    .foregroundColor(.secondary)
                    .font(.caption)
            } else {
                let columns = [
                    GridItem(.adaptive(minimum: 80, maximum: 100), spacing: 36)
                ]
                
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(enhancementService.customPrompts) { prompt in
                        prompt.promptIcon(
                            isSelected: selectedPromptId == prompt.id,
                            onTap: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    onPromptSelected(prompt)
                                }
                            },
                            onEdit: onEditPrompt,
                            onDelete: onDeletePrompt
                        )
                        .opacity(draggingItem?.id == prompt.id ? 0.3 : 1.0)
                        .scaleEffect(draggingItem?.id == prompt.id ? 1.05 : 1.0)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(
                                    draggingItem != nil && draggingItem?.id != prompt.id
                                    ? Color.accentColor.opacity(0.25)
                                    : Color.clear,
                                    lineWidth: 1
                                )
                        )
                        .animation(.easeInOut(duration: 0.15), value: draggingItem?.id == prompt.id)
                        .onDrag {
                            draggingItem = prompt
                            return NSItemProvider(object: prompt.id.uuidString as NSString)
                        }
                        .onDrop(
                            of: [UTType.text],
                            delegate: PromptDropDelegate(
                                item: prompt,
                                prompts: $enhancementService.customPrompts,
                                draggingItem: $draggingItem
                            )
                        )
                    }
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                
                HStack {
                    Image(systemName: "info.circle")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    
                    Text("Double-click to edit • Right-click for more options")
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                .padding(.top, 8)
                .padding(.horizontal, 16)
            }
        }
    }
}

// MARK: - System Instructions Editor
private struct SystemInstructionsEditor: View {
 @State private var instructionsText: String = AIPrompts.customPromptTemplate
 @State private var hasChanges = false
 @State private var showResetConfirmation = false

 var body: some View {
  VStack(alignment: .leading, spacing: 12) {
   Text("These system instructions wrap every enhancement prompt. They tell the AI how to behave as a transcription enhancer. The `%@` placeholder is where your selected prompt's rules get inserted.")
    .font(.caption)
    .foregroundColor(.secondary)

   TextEditor(text: $instructionsText)
    .font(.system(.body, design: .monospaced))
    .frame(minHeight: 300)
    .padding(4)
    .background(Color(NSColor.textBackgroundColor))
    .cornerRadius(8)
    .overlay(
     RoundedRectangle(cornerRadius: 8)
      .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
    )
    .onChange(of: instructionsText) { _, _ in
     hasChanges = instructionsText != AIPrompts.customPromptTemplate
    }

   HStack {
    Button("Reset to Default") {
     showResetConfirmation = true
    }
    .foregroundColor(.red)
    .alert("Reset System Instructions?", isPresented: $showResetConfirmation) {
     Button("Reset", role: .destructive) {
      AIPrompts.resetSystemInstructions()
      instructionsText = AIPrompts.customPromptTemplate
      hasChanges = false
     }
     Button("Cancel", role: .cancel) {}
    } message: {
     Text("This will restore the default system instructions. Your current changes will be lost.")
    }

    Spacer()

    if hasChanges {
     Text("Unsaved changes")
      .font(.caption)
      .foregroundColor(.orange)
    }

    Button("Save") {
     AIPrompts.saveSystemInstructions(instructionsText)
     hasChanges = false
    }
    .disabled(!hasChanges)
    .buttonStyle(.borderedProminent)
   }
  }
 }
}

// MARK: - Drop Delegate
private struct PromptDropDelegate: DropDelegate {
    let item: CustomPrompt
    @Binding var prompts: [CustomPrompt]
    @Binding var draggingItem: CustomPrompt?
    
    func dropEntered(info: DropInfo) {
        guard let draggingItem = draggingItem, draggingItem != item else { return }
        guard let fromIndex = prompts.firstIndex(of: draggingItem),
              let toIndex = prompts.firstIndex(of: item) else { return }
        
        if prompts[toIndex].id != draggingItem.id {
            withAnimation(.easeInOut(duration: 0.12)) {
                let from = fromIndex
                let to = toIndex
                prompts.move(fromOffsets: IndexSet(integer: from), toOffset: to > from ? to + 1 : to)
            }
        }
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        DropProposal(operation: .move)
    }
    
    func performDrop(info: DropInfo) -> Bool {
        draggingItem = nil
        return true
    }
}
