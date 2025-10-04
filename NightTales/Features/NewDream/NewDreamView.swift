//
//  NewDreamView.swift
//  NightTales
//
//  New dream entry screen with Liquid Glass design
//

import SwiftUI
import SwiftData

struct NewDreamView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: NewDreamViewModel
    @State private var showInterpretation = false
    @State private var currentError: (any AppError)?
    @State private var showError = false
    @State private var showPaywall = false
    let dreamToEdit: Dream?

    init(viewModel: NewDreamViewModel? = nil, dreamToEdit: Dream? = nil) {
        self.dreamToEdit = dreamToEdit
        if let vm = viewModel {
            self.viewModel = vm
        } else {
            // Temporary placeholder - will be replaced in HomeView
            self.viewModel = NewDreamViewModel(modelContext: ModelContext(try! ModelContainer(for: Dream.self)))
        }
    }

    var body: some View {
        ZStack {
            // Background
            DreamBackground(mood: viewModel.selectedMood)
                .ignoresSafeArea()
                .onTapGesture {
                    hideKeyboard()
                }

            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    header

                    // Title Field
                    titleField

                    // Mood Selector
                    moodSelector

                    // Lucid Dream Toggle
                    lucidDreamToggle

                    // Content Editor
                    contentEditor

                    // Voice Recording Button
                    voiceRecordingButton

                    // AI Interpret Button
                    aiInterpretButton

                    // Interpretation Result
                    if viewModel.interpretation != nil {
                        interpretationCard
                    }

                    // Detected Symbols
                    if !viewModel.detectedSymbols.isEmpty {
                        detectedSymbolsView
                    }

                    // Error Message
                    if let error = viewModel.errorMessage {
                        errorView(error)
                    }

                    // Save Button
                    saveButton
                }
                .padding()
                .padding(.bottom, 50)
            }

            // Loading Overlay
            if viewModel.isInterpreting {
                LoadingView(message: "Interpreting your dream...")
            }
        }
        .errorAlert(
            error: $currentError,
            isPresented: $showError,
            onRetry: {
                if currentError is AIError {
                    await viewModel.interpretWithAI()
                }
            }
        )
        .onChange(of: viewModel.errorMessage) { _, newError in
            if let errorMsg = newError {
                currentError = AIError.interpretationFailed(NSError(domain: "NightTales", code: 1, userInfo: [NSLocalizedDescriptionKey: errorMsg]))
                showError = true
            }
        }
                .scrollDismissesKeyboard(.interactively)

    }

    // MARK: - Header
    private var header: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.title3)
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
            }
            .glassEffect(.clear, in: .circle)

            Spacer()

            Text(viewModel.isEditing ? "Edit Dream" : "New Dream")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.white)

            Spacer()

            // Placeholder for symmetry
            Color.clear
                .frame(width: 44, height: 44)
        }
    }

    // MARK: - Title Field
    private var titleField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Title (Optional)")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.7))
                .padding(.leading, 4)

            TextField("Give your dream a title...", text: $viewModel.title)
                .foregroundStyle(.white)
                .tint(.dreamPurple)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .dreamGlass(.calm, shape: AnyShape(RoundedRectangle(cornerRadius: 12)))
        }
    }

    // MARK: - Mood Selector
    private var moodSelector: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("How did you feel?")
                .font(.headline)
                .foregroundStyle(.white)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(DreamMood.allCases, id: \.self) { mood in
                        moodButton(mood)
                    }
                }
            }
        }
    }

    private func moodButton(_ mood: DreamMood) -> some View {
        let isSelected = viewModel.selectedMood == mood

        return Button {
            withAnimation(AnimationManager.bouncySpring) {
                viewModel.selectedMood = mood
            }
        } label: {
            VStack(spacing: 8) {
                Image(systemName: mood.icon)
                    .font(.title2)
                Text(mood.rawValue.capitalized)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .foregroundStyle(isSelected ? .white : .white.opacity(0.7))
            .frame(width: 80, height: 80)
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .shadow(
                color: isSelected ? mood.color.opacity(0.5) : .clear,
                radius: isSelected ? 15 : 0
            )
        }
        .glassEffect(
            isSelected ? .regular.tint(mood.color.opacity(0.6)).interactive() : .clear,
            in: .rect(cornerRadius: 16)
        )
    }

    // MARK: - Lucid Dream Toggle
    private var lucidDreamToggle: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Image(systemName: "eye.fill")
                        .foregroundStyle(.cyan)
                    Text("Lucid Dream")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                }

                Text("Were you aware you were dreaming?")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))
            }

            Spacer()

            Toggle("", isOn: $viewModel.isLucidDream)
                .tint(.cyan)
        }
        .padding(16)
        .dreamGlass(.lucid, shape: AnyShape(RoundedRectangle(cornerRadius: 16)))
    }

    // MARK: - Content Editor
    private var contentEditor: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Dream Content")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.7))
                .padding(.leading, 4)

            ZStack(alignment: .topLeading) {
                if viewModel.content.isEmpty {
                    Text("Describe your dream in detail...")
                        .foregroundStyle(.white.opacity(0.5))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                }

                TextEditor(text: $viewModel.content)
                    .foregroundStyle(.white)
                    .tint(.dreamPurple)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 200)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 12)
            }
            .dreamGlass(.mystic, shape: AnyShape(RoundedRectangle(cornerRadius: 16)))
        }
    }

    // MARK: - Voice Recording Button
    private var voiceRecordingButton: some View {
        Button {
            if viewModel.isRecording {
                viewModel.stopVoiceRecording()
            } else {
                Task {
                    await viewModel.startVoiceRecording()
                }
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: viewModel.isRecording ? "stop.circle.fill" : "mic.fill")
                    .font(.title3)

                Text(viewModel.isRecording ? "Stop Recording" : "Record with Voice")
                    .font(.headline)

                if viewModel.isRecording {
                    // Recording animation
                    HStack(spacing: 4) {
                        ForEach(0..<3, id: \.self) { index in
                            Circle()
                                .fill(.red)
                                .frame(width: 6, height: 6)
                                .opacity(viewModel.isRecording ? 0.3 : 1.0)
                                .animation(
                                    .easeInOut(duration: 0.6)
                                    .repeatForever()
                                    .delay(Double(index) * 0.2),
                                    value: viewModel.isRecording
                                )
                        }
                    }
                }
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
        }
        .dreamGlass(viewModel.isRecording ? .vivid : .calm, shape: AnyShape(RoundedRectangle(cornerRadius: 16)))
    }

    // MARK: - AI Interpret Button
    private var aiInterpretButton: some View {
        VStack(spacing: 12) {
            Button {
                // Check if user can use AI
                if AIUsageManager.shared.canUseAI() {
                    Task {
                        await viewModel.interpretWithAI()
                        if viewModel.interpretation != nil {
                            withAnimation {
                                showInterpretation = true
                            }
                            // Record usage after successful interpretation
                            AIUsageManager.shared.recordUsage()
                        }
                    }
                } else {
                    // Show paywall
                    showPaywall = true
                }
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "sparkles")
                        .font(.title3)

                    Text("Interpret with AI")
                        .font(.headline)

                    if viewModel.isInterpreting {
                        ProgressView()
                            .tint(.white)
                    }
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
            }
            .disabled(!viewModel.canInterpret)
            .opacity(viewModel.canInterpret ? 1.0 : 0.5)
            .dreamGlass(.mystic, shape: AnyShape(RoundedRectangle(cornerRadius: 16)))

            // Show remaining interpretations for free users
            if !PurchaseManager.shared.hasPremium {
                let remaining = AIUsageManager.shared.remainingFreeInterpretations
                Text("\(remaining) free interpretation\(remaining == 1 ? "" : "s") remaining this month")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
    }

    // MARK: - Interpretation Card
    private var interpretationCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundStyle(Color.dreamPurple)
                Text("AI Interpretation")
                    .font(.headline)
                    .foregroundStyle(.white)

                Spacer()

                Button {
                    withAnimation {
                        showInterpretation.toggle()
                    }
                } label: {
                    Image(systemName: showInterpretation ? "chevron.up" : "chevron.down")
                        .foregroundStyle(.white.opacity(0.7))
                }
            }

            if showInterpretation, let interpretation = viewModel.interpretation {
                Divider()
                    .background(.white.opacity(0.2))

                interpretationSection(title: "Psychological Analysis", content: interpretation.psychologicalAnalysis)
                interpretationSection(title: "Symbolic Meaning", content: interpretation.symbolicMeaning)
                interpretationSection(title: "Cultural Context", content: interpretation.culturalContext)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Possible Meanings:")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    ForEach(Array(interpretation.possibleMeanings.enumerated()), id: \.offset) { index, meaning in
                        HStack(alignment: .top, spacing: 8) {
                            Text("\(index + 1).")
                                .foregroundStyle(.white.opacity(0.7))
                            Text(meaning)
                                .foregroundStyle(.white.opacity(0.9))
                        }
                        .font(.subheadline)
                    }
                }
            }
        }
        .padding(16)
        .dreamGlass(.vivid, shape: AnyShape(RoundedRectangle(cornerRadius: 20)))
    }

    private func interpretationSection(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text(content)
                .font(.body)
                .foregroundColor(.white)
                .opacity(0.95)
                .lineSpacing(4)
        }
    }

    // MARK: - Detected Symbols
    private var detectedSymbolsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Detected Symbols")
                .font(.headline)
                .foregroundStyle(.white)

            FlowLayout(spacing: 8) {
                ForEach(viewModel.detectedSymbols) { symbol in
                    SymbolBadge(symbol.name, style: .calm)
                }
            }
        }
        .padding(16)
        .dreamGlass(.calm, shape: AnyShape(RoundedRectangle(cornerRadius: 16)))
    }

    // MARK: - Error View
    private func errorView(_ message: String) -> some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.orange)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.white)
        }
        .padding(16)
        .dreamGlass(.nightmare, shape: AnyShape(RoundedRectangle(cornerRadius: 12)))
    }

    // MARK: - Save Button
    private var saveButton: some View {
        LiquidGlassButton(
            viewModel.isEditing ? "Update Dream" : "Save Dream",
            icon: "checkmark.circle.fill",
            style: .mystic
        ) {
            Task {
                do {
                    try await viewModel.saveDream()
                    dismiss()
                } catch {
                    viewModel.errorMessage = error.localizedDescription
                }
            }
        }
        .disabled(!viewModel.canSave)
        .opacity(viewModel.canSave ? 1.0 : 0.5)
    }
}

// MARK: - Flow Layout Helper
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.replacingUnspecifiedDimensions().width, subviews: subviews, spacing: spacing)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.frames[index].minX, y: bounds.minY + result.frames[index].minY), proposal: .unspecified)
        }
    }

    struct FlowResult {
        var size: CGSize = .zero
        var frames: [CGRect] = []

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if currentX + size.width > maxWidth && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }

                frames.append(CGRect(origin: CGPoint(x: currentX, y: currentY), size: size))
                currentX += size.width + spacing
                lineHeight = max(lineHeight, size.height)
            }

            self.size = CGSize(width: maxWidth, height: currentY + lineHeight)
        }
    }
}

#Preview {
    NewDreamView(viewModel: NewDreamViewModel(modelContext: ModelContext(
        try! ModelContainer(for: Dream.self, configurations: .init(isStoredInMemoryOnly: true))
    )))
}
