//
//  QuickVoiceEntryView.swift
//  NightTales
//
//  Quick voice entry for fast dream recording
//

import SwiftUI
import SwiftData

struct QuickVoiceEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: QuickVoiceEntryViewModel

    var body: some View {
        ZStack {
            // Background
            DreamBackground(mood: .lucid)
                .ignoresSafeArea()

            VStack(spacing: 32) {
                // Header
                header

                Spacer()

                // Recording Visualizer
                if viewModel.isRecording {
                    recordingVisualizer
                } else {
                    microphoneIcon
                }

                Spacer()

                // Debug Info & Transcription
                VStack(spacing: 8) {
                    Text("Transcription: '\(viewModel.transcription)'")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.5))

                    if !viewModel.transcription.isEmpty {
                        transcriptionPreview
                    }
                }

                // Action Buttons
                actionButtons
            }
            .padding(24)
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 8) {
            Text("Quick Voice Entry")
                .font(.title2.bold())
                .foregroundStyle(.white)

            Text(viewModel.isRecording ? "Recording..." : "Tap to record your dream")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.7))
        }
    }

    // MARK: - Microphone Icon

    private var microphoneIcon: some View {
        ZStack {
            // Glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.dreamPurple.opacity(0.3),
                            Color.dreamPurple.opacity(0)
                        ],
                        center: .center,
                        startRadius: 60,
                        endRadius: 120
                    )
                )
                .frame(width: 240, height: 240)

            // Main button
            Button {
                viewModel.toggleRecording()
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.dreamPurple.opacity(0.2))
                        .frame(width: 120, height: 120)

                    Image(systemName: "mic.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(.white)
                }
            }
            .glassEffect(.regular.tint(Color.dreamPurple.opacity(0.4)).interactive(), in: .circle)
        }
    }

    // MARK: - Recording Visualizer

    private var recordingVisualizer: some View {
        VStack(spacing: 24) {
            // Animated waves
            ZStack {
                ForEach(0..<3) { index in
                    Circle()
                        .stroke(Color.red.opacity(0.3), lineWidth: 2)
                        .frame(width: 120 + CGFloat(index * 40), height: 120 + CGFloat(index * 40))
                        .scaleEffect(viewModel.isRecording ? 1.2 : 1.0)
                        .opacity(viewModel.isRecording ? 0.0 : 0.6)
                        .animation(
                            .easeInOut(duration: 1.5)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.2),
                            value: viewModel.isRecording
                        )
                }

                // Stop button
                Button {
                    viewModel.toggleRecording()
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color.red.opacity(0.3))
                            .frame(width: 120, height: 120)

                        RoundedRectangle(cornerRadius: 8)
                            .fill(.white)
                            .frame(width: 40, height: 40)
                    }
                }
                .glassEffect(.regular.tint(Color.red.opacity(0.4)).interactive(), in: .circle)
            }
            .frame(height: 240)

            // Timer
            Text(viewModel.recordingDuration)
                .font(.title3.monospacedDigit())
                .foregroundStyle(.white)
        }
    }

    // MARK: - Transcription Preview

    private var transcriptionPreview: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "quote.opening")
                    .foregroundStyle(Color.dreamPurple)
                    .font(.caption)

                Text("Transcription")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.7))

                Spacer()
            }

            ScrollView {
                Text(viewModel.transcription)
                    .font(.body)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxHeight: 150)
        }
        .padding(16)
        .dreamGlass(.calm, shape: AnyShape(RoundedRectangle(cornerRadius: 16)))
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: 12) {
            // Save Button
            if !viewModel.transcription.isEmpty && !viewModel.isRecording {
                Button {
                    viewModel.saveDream()
                    dismiss()
                } label: {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Save Dream")
                            .font(.headline)
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                }
                .dreamGlass(.mystic, shape: AnyShape(RoundedRectangle(cornerRadius: 16)))
            }

            // Cancel Button
            Button {
                dismiss()
            } label: {
                Text("Cancel")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.7))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .glassEffect(.clear, in: .rect(cornerRadius: 12))
        }
    }
}

// MARK: - Quick Voice Entry ViewModel

@MainActor
@Observable
final class QuickVoiceEntryViewModel {
    var isRecording = false
    var transcription = ""
    var recordingDuration = "00:00"

    private let voiceService = VoiceService.shared
    private let dreamService: DreamService
    private var recordingStartTime: Date?
    private var timer: Timer?

    init(modelContext: ModelContext) {
        self.dreamService = DreamService(modelContext: modelContext)
    }

    // MARK: - Toggle Recording

    func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }

    private func startRecording() {
        isRecording = true
        recordingStartTime = Date()
        transcription = ""

        // Start timer
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateDuration()
        }

        // Start voice recording
        Task {
            do {
                try voiceService.startRecording()

                // Poll for transcription updates
                while voiceService.isRecording {
                    try await Task.sleep(nanoseconds: 100_000_000) // 0.1 second
                    transcription = voiceService.transcribedText
                }
            } catch {
                isRecording = false
                print("Recording failed: \(error)")
            }
        }
    }

    private func stopRecording() {
        isRecording = false
        timer?.invalidate()
        timer = nil
        voiceService.stopRecording()
        transcription = voiceService.transcribedText
    }

    private func updateDuration() {
        guard let startTime = recordingStartTime else { return }
        let elapsed = Date().timeIntervalSince(startTime)
        let minutes = Int(elapsed) / 60
        let seconds = Int(elapsed) % 60
        recordingDuration = String(format: "%02d:%02d", minutes, seconds)
    }

    // MARK: - Save Dream

    func saveDream() {
        guard !transcription.isEmpty else { return }

        let dream = Dream(
            title: "Quick Voice Entry",
            content: transcription,
            mood: .neutral,
            symbols: []
        )

        do {
            try dreamService.saveDream(dream)
        } catch {
            print("Failed to save dream: \(error)")
        }
    }
}

#Preview {
    QuickVoiceEntryView(
        viewModel: QuickVoiceEntryViewModel(
            modelContext: ModelContext(
                try! ModelContainer(for: Dream.self, configurations: .init(isStoredInMemoryOnly: true))
            )
        )
    )
}
