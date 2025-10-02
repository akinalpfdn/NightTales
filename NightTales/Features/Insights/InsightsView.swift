//
//  InsightsView.swift
//  NightTales
//
//  Insights screen with Liquid Glass design
//

import SwiftUI
import SwiftData

struct InsightsView: View {
    @Bindable var viewModel: InsightsViewModel

    var body: some View {
        ZStack {
            // Background
            DreamBackground(mood: viewModel.mostCommonMood ?? .neutral)
                .ignoresSafeArea()

            if !viewModel.hasEnoughData {
                // Not Enough Data State
                emptyState
            } else {
                // Insights Content
                ScrollView {
                    VStack(spacing: 20) {
                        // Header
                        header

                        // Month Selector
                        monthSelector

                        // Mood Distribution Chart
                        moodChartSection

                        // Recurring Symbols
                        symbolsSection

                        // Pattern Analysis Card
                        if let patterns = viewModel.patterns {
                            PatternCardView(pattern: patterns)
                        }

                        // Generate Button
                        if viewModel.patterns == nil {
                            generateButton
                        }
                    }
                    .padding()
                    .padding(.bottom, 50)
                }
            }

            // Loading Overlay
            if viewModel.isGenerating {
                LoadingView(message: "Analyzing patterns...")
            }
        }
        .onAppear {
            Task {
                await viewModel.refreshAllData()
            }
        }
    }

    // MARK: - Header
    private var header: some View {
        VStack(spacing: 8) {
            Text("Insights")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(.white)

            Text("\(viewModel.totalDreams) dreams recorded")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 20)
    }

    // MARK: - Month Selector
    private var monthSelector: some View {
        HStack {
            Button {
                viewModel.changeMonth(offset: -1)
            } label: {
                Image(systemName: "chevron.left")
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
            }
            .glassEffect(.clear, in: .circle)

            Spacer()

            Text(viewModel.selectedMonth.formatted(.dateTime.month(.wide).year()))
                .font(.headline)
                .foregroundStyle(.white)

            Spacer()

            Button {
                viewModel.changeMonth(offset: 1)
            } label: {
                Image(systemName: "chevron.right")
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
            }
            .glassEffect(.clear, in: .circle)
            .disabled(viewModel.selectedMonth >= Date())
            .opacity(viewModel.selectedMonth >= Date() ? 0.5 : 1.0)
        }
        .padding(.horizontal)
    }

    // MARK: - Mood Chart Section
    private var moodChartSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "chart.pie.fill")
                    .foregroundStyle(Color.dreamPurple)
                Text("Mood Distribution")
                    .font(.headline)
                    .foregroundStyle(.white)
            }

            if !viewModel.monthlyData.isEmpty {
                MoodChartView(moodData: viewModel.monthlyData)
            } else {
                Text("No dreams recorded this month")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.6))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
            }
        }
        .padding(16)
        .dreamGlass(.mystic, shape: AnyShape(RoundedRectangle(cornerRadius: 20)))
    }

    // MARK: - Symbols Section
    private var symbolsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundStyle(Color.dreamPink)
                Text("Most Common Symbols")
                    .font(.headline)
                    .foregroundStyle(.white)
            }

            if !viewModel.recurringSymbols.isEmpty {
                SymbolCloudView(symbols: viewModel.recurringSymbols)
            } else {
                Text("No recurring symbols yet")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.6))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
            }
        }
        .padding(16)
        .dreamGlass(.vivid, shape: AnyShape(RoundedRectangle(cornerRadius: 20)))
    }

    // MARK: - Emotional Trends Section
    private var emotionalTrendsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "heart.fill")
                    .foregroundStyle(Color.dreamBlue)
                Text("Emotional Trends")
                    .font(.headline)
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 12) {
                ForEach(Array(viewModel.emotionalTrends.enumerated()), id: \.offset) { index, trend in
                    HStack(alignment: .top, spacing: 12) {
                        Circle()
                            .fill(Color.dreamBlue)
                            .frame(width: 6, height: 6)
                            .padding(.top, 6)

                        Text(trend)
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.9))
                    }
                }
            }
        }
        .padding(16)
        .dreamGlass(.calm, shape: AnyShape(RoundedRectangle(cornerRadius: 20)))
    }

    // MARK: - Recommendations Section
    private var recommendationsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundStyle(.yellow)
                Text("AI Recommendations")
                    .font(.headline)
                    .foregroundStyle(.white)
            }

            if let recommendations = viewModel.patterns?.recommendations {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(Array(recommendations.enumerated()), id: \.offset) { index, recommendation in
                        HStack(alignment: .top, spacing: 12) {
                            Text("\(index + 1).")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color.dreamPurple)

                            Text(recommendation)
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.9))
                        }
                    }
                }
            }
        }
        .padding(16)
        .dreamGlass(.lucid, shape: AnyShape(RoundedRectangle(cornerRadius: 20)))
    }

    // MARK: - Generate Button
    private var generateButton: some View {
        LiquidGlassButton(
            "Analyze Patterns with AI",
            icon: "sparkles",
            style: .mystic
        ) {
            Task {
                await viewModel.analyzePatterns()
                await viewModel.generateRecommendations()
            }
        }
    }

    // MARK: - Empty State
    private var emptyState: some View {
        EmptyStateView(
            title: "Not Enough Data",
            message: "Record at least 3 dreams to unlock insights and pattern analysis",
            actionTitle: nil,
            action: nil
        )
    }
}

#Preview {
    InsightsView(
        viewModel: InsightsViewModel(
            modelContext: ModelContext(
                try! ModelContainer(for: Dream.self, configurations: .init(isStoredInMemoryOnly: true))
            )
        )
    )
}
