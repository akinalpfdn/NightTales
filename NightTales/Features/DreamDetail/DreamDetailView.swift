//
//  DreamDetailView.swift
//  NightTales
//
//  Dream detail screen with Liquid Glass design
//

import SwiftUI
import SwiftData

struct DreamDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    let dream: Dream
    @State private var showInterpretation = true
    @State private var showDeleteConfirmation = false
    @State private var showShareSheet = false

    var body: some View {
        ZStack {
            // Background
            DreamBackground(mood: dream.mood)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    header

                    // Mood + Date + Lucid Badge
                    metadataSection

                    // Title
                    if !dream.title.isEmpty {
                        titleSection
                    }

                    // Content
                    contentSection

                    // Symbols
                    if !dream.symbols.isEmpty {
                        symbolsSection
                    }

                    // AI Interpretation
                    if dream.aiInterpretation != nil {
                        interpretationSection
                    }

                    // Actions
                    actionsSection
                }
                .padding()
                .padding(.bottom, 50)
            }
        }
        .alert("Delete Dream", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteDream()
            }
        } message: {
            Text("Are you sure you want to delete this dream? This action cannot be undone.")
        }
        .confirmationDialog("Share Dream", isPresented: $showShareSheet) {
            Button("Share as Text") {
                let text = ShareManager.shared.shareDreamAsText(dream: dream, includeInterpretation: true)
                ShareManager.shared.presentShareSheet(items: [text])
            }

            Button("Share as Image") {
                if let image = ShareManager.shared.shareDreamAsImage(dream: dream, includeInterpretation: false) {
                    ShareManager.shared.presentShareSheet(items: [image])
                }
            }

            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Choose how you want to share this dream")
        }
    }

    // MARK: - Header
    private var header: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title3)
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
            }
            .glassEffect(.clear, in: .circle)

            Spacer()

            // Share, Edit and Delete buttons
            HStack(spacing: 12) {
                Button {
                    showShareSheet = true
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .font(.body)
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                }
                .glassEffect(.clear, in: .circle)

                Button {
                    // Edit action - TODO: implement edit
                } label: {
                    Image(systemName: "pencil")
                        .font(.body)
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                }
                .glassEffect(.clear, in: .circle)

                Button {
                    showDeleteConfirmation = true
                } label: {
                    Image(systemName: "trash")
                        .font(.body)
                        .foregroundStyle(.red)
                        .frame(width: 44, height: 44)
                }
                .glassEffect(.clear, in: .circle)
            }
        }
    }

    // MARK: - Metadata Section
    private var metadataSection: some View {
        VStack(spacing: 12) {
            HStack {
                MoodIndicator(dream.mood, showLabel: true)

                Spacer()

                Text(dream.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.7))
            }

            if dream.isLucidDream {
                HStack {
                    Image(systemName: "eye.fill")
                        .font(.body)
                    Text("Lucid Dream")
                        .font(.headline)
                    Spacer()
                }
                .foregroundStyle(.cyan)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .glassEffect(.clear.tint(.cyan.opacity(0.4)), in: .rect(cornerRadius: 12))
            }
        }
    }

    // MARK: - Title Section
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(dream.title)
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .dreamGlass(.mystic, shape: AnyShape(RoundedRectangle(cornerRadius: 16)))
    }

    // MARK: - Content Section
    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "text.alignleft")
                    .foregroundStyle(Color.dreamPurple)
                Text("Dream Content")
                    .font(.headline)
                    .foregroundStyle(.white)
            }

            Text(dream.content)
                .font(.body)
                .foregroundStyle(.white.opacity(0.9))
                .lineSpacing(6)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .dreamGlass(.calm, shape: AnyShape(RoundedRectangle(cornerRadius: 16)))
    }

    // MARK: - Symbols Section
    private var symbolsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "tag.fill")
                    .foregroundStyle(Color.dreamPink)
                Text("Symbols")
                    .font(.headline)
                    .foregroundStyle(.white)
            }

            FlowLayout(spacing: 8) {
                ForEach(dream.symbols, id: \.self) { symbol in
                    SymbolBadge(symbol, style: .calm)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .dreamGlass(.vivid, shape: AnyShape(RoundedRectangle(cornerRadius: 16)))
    }

    // MARK: - Interpretation Section
    private var interpretationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Button {
                withAnimation {
                    showInterpretation.toggle()
                }
            } label: {
                HStack {
                    Image(systemName: "sparkles")
                        .foregroundStyle(Color.dreamPurple)
                    Text("AI Interpretation")
                        .font(.headline)
                        .foregroundStyle(.white)

                    Spacer()

                    Image(systemName: showInterpretation ? "chevron.up" : "chevron.down")
                        .foregroundStyle(.white.opacity(0.7))
                }
            }

            if showInterpretation, let interpretation = dream.aiInterpretation {
                Divider()
                    .background(.white.opacity(0.2))

                Text(interpretation)
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.9))
                    .lineSpacing(6)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .dreamGlass(.mystic, shape: AnyShape(RoundedRectangle(cornerRadius: 20)))
    }

    // MARK: - Actions Section
    private var actionsSection: some View {
        VStack(spacing: 12) {
            // Share Button
            LiquidGlassButton("Share Dream", icon: "square.and.arrow.up", style: .calm) {
                showShareSheet = true
            }

            // Similar Dreams Button
            LiquidGlassButton("Find Similar Dreams", icon: "sparkles", style: .mystic) {
                // TODO: Implement similar dreams
            }
        }
    }

    // MARK: - Delete Dream
    private func deleteDream() {
        modelContext.delete(dream)
        do {
            try modelContext.save()
            HapticManager.shared.success()
            dismiss()
        } catch {
            HapticManager.shared.error()
            print("Failed to delete dream: \(error)")
        }
    }
}

#Preview {
    DreamDetailView(
        dream: Dream(
            title: "Flying Over Mountains",
            content: "I was soaring through the sky, watching the mountains below me. The air was crisp and clear, and I could feel the wind rushing past my face. I felt completely free and at peace. There were birds flying alongside me, and the sunset painted the sky in beautiful shades of orange and pink. I knew I was dreaming, but I didn't want it to end.",
            mood: .pleasant,
            symbols: ["Flying", "Mountains", "Sky", "Freedom", "Birds", "Sunset"],
            aiInterpretation: """
            PSYCHOLOGICAL ANALYSIS:
            This dream represents a desire for freedom and escape from daily constraints. The ability to fly symbolizes overcoming obstacles and gaining perspective on life's challenges.

            SYMBOLIC MEANING:
            Mountains represent life's challenges that you're rising above. The sunset suggests a transition period, while birds symbolize spiritual freedom.

            CULTURAL CONTEXT:
            In many cultures, flying dreams are associated with transcendence and spiritual awakening. The mountain symbolism is universal for obstacles and achievement.

            POSSIBLE MEANINGS:
            1. You're experiencing or seeking greater freedom in your life
            2. You've recently overcome a significant challenge
            3. You're gaining a new perspective on a situation
            4. You're in touch with your spiritual side
            5. You're feeling confident and empowered
            """,
            isLucidDream: true
        )
    )
}
