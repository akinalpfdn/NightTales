//
//  HomeView.swift
//  NightTales
//
//  Home screen with Liquid Glass design
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Bindable var viewModel: HomeViewModel
    @State private var showNewDream = false
    @State private var gridLayout = true

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                DreamBackground(mood: .neutral)
                    .ignoresSafeArea()

                if viewModel.isEmpty {
                // Empty State
                EmptyStateView(
                    title: "No Dreams Yet",
                    message: "Start recording your dreams to unlock insights and patterns",
                    actionTitle: "Record Your First Dream"
                ) {
                    showNewDream = true
                }
            } else {
                // Dream List
                VStack(spacing: 0) {
                    // Search Bar
                    searchBar
                        .padding(.horizontal)
                        .padding(.top, 8)

                    // Mood Filter Pills
                    moodFilterPills
                        .padding(.vertical, 12)

                    // Grid/List Toggle + Sort
                    toolBar
                        .padding(.horizontal)
                        .padding(.bottom, 8)

                    // Dreams Grid/List
                    ScrollView {
                        VStack(spacing: 16) {
                            // Streak Widget
                            let stats = viewModel.streakStats
                            DreamStreakView(
                                currentStreak: stats.current,
                                longestStreak: stats.longest,
                                totalDreams: stats.total
                            )
                            .padding(.horizontal)
                            .padding(.top, 8)

                            // Dreams
                            if gridLayout {
                                dreamGrid
                            } else {
                                dreamList
                            }
                        }
                    }
                }
            }

            // Floating Action Button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    FloatingActionButton {
                        showNewDream = true
                    }
                    .padding(24)
                }
            }
        }
        .sheet(isPresented: $showNewDream) {
            NewDreamView(viewModel: NewDreamViewModel(modelContext: viewModel.modelContext))
        }
        .onChange(of: showNewDream) { _, isShowing in
            if !isShowing {
                viewModel.loadDreams()
            }
        }
        .onAppear {
            viewModel.loadDreams()
        }
            }
        }

    // MARK: - Search Bar
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.white.opacity(0.6))

            TextField("Search dreams...", text: $viewModel.searchText)
                .foregroundStyle(.white)
                .tint(.dreamPurple)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .dreamGlass(.calm, shape: AnyShape(RoundedRectangle(cornerRadius: 16)))
    }

    // MARK: - Mood Filter Pills
    private var moodFilterPills: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // All button
                moodPill(mood: nil, label: "All")

                // Mood buttons
                ForEach(DreamMood.allCases, id: \.self) { mood in
                    moodPill(mood: mood, label: mood.rawValue.capitalized)
                }
            }
            .padding(.horizontal)
        }
    }

    private func moodPill(mood: DreamMood?, label: String) -> some View {
        Button {
            withAnimation(.spring(response: 0.3)) {
                viewModel.filterByMood(mood)
            }
        } label: {
            HStack(spacing: 6) {
                if let mood = mood {
                    Image(systemName: mood.icon)
                        .font(.caption)
                }
                Text(label)
                    .font(.subheadline.weight(.medium))
            }
            .foregroundStyle(viewModel.selectedMood == mood ? .white : .white.opacity(0.7))
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .glassEffect(
            viewModel.selectedMood == mood ? .regular.tint(mood?.color.opacity(0.6) ?? Color.dreamPurple.opacity(0.6)).interactive() : .clear,
            in: .capsule
        )
    }

    // MARK: - Toolbar
    private var toolBar: some View {
        HStack {
            // Grid/List Toggle
            Button {
                withAnimation {
                    gridLayout.toggle()
                }
            } label: {
                Image(systemName: gridLayout ? "square.grid.2x2.fill" : "list.bullet")
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
            }
            .glassEffect(.clear, in: .circle)

            Spacer()

            // Sort Menu
            Menu {
                Button("Date (Newest)") { viewModel.sortDreams(by: .dateDescending) }
                Button("Date (Oldest)") { viewModel.sortDreams(by: .dateAscending) }
                Button("Title (A-Z)") { viewModel.sortDreams(by: .titleAscending) }
                Button("Title (Z-A)") { viewModel.sortDreams(by: .titleDescending) }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.up.arrow.down")
                    Text("Sort")
                }
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
            .glassEffect(.regular.tint(Color.dreamPurple.opacity(0.5)), in: .capsule)
        }
    }

    // MARK: - Dream Grid
    private var dreamGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16)
        ], spacing: 16) {
            ForEach(viewModel.filteredDreams) { dream in
                DreamCardView(dream: dream, isGridLayout: true)
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 100)
    }

    // MARK: - Dream List
    private var dreamList: some View {
        LazyVStack(spacing: 12) {
            ForEach(viewModel.filteredDreams) { dream in
                DreamCardView(dream: dream, isGridLayout: false)
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 100)
    }
}

#Preview {
    HomeView(viewModel: HomeViewModel(modelContext: ModelContext(
        try! ModelContainer(for: Dream.self, configurations: .init(isStoredInMemoryOnly: true))
    )))
    .modelContainer(for: Dream.self, inMemory: true)
}
