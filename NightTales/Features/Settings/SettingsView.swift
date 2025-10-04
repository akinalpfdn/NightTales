//
//  SettingsView.swift
//  NightTales
//
//  Settings screen with Liquid Glass design
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct SettingsView: View {
    @Bindable var viewModel: SettingsViewModel
    @State private var showPaywall = false

    var body: some View {
        ZStack {
            // Background
            DreamBackground(mood: .neutral)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    header

                    // Reminders Section
                    remindersSection

                    // Premium Section
                    premiumSection

                    // Interpretation Style Section
                    interpretationStyleSection

                    // Lucid Dream Info Section
                    lucidDreamSection

                    // Data Management Section
                    dataManagementSection

                    // About Section
                    aboutSection
                }
                .padding(.horizontal)
                .padding(.bottom, 100)
            }
        }
        .alert("Delete All Data?", isPresented: $viewModel.showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                viewModel.deleteAllData()
            }
        } message: {
            Text("This will permanently delete all your dreams, symbols, and patterns. This action cannot be undone.")
        }
        .alert("Export Complete", isPresented: .constant(viewModel.exportMessage != nil)) {
            Button("OK") {
                viewModel.exportMessage = nil
            }
        } message: {
            if let message = viewModel.exportMessage {
                Text(message)
            }
        }
        .alert("Import Complete", isPresented: .constant(viewModel.importMessage != nil)) {
            Button("OK") {
                viewModel.importMessage = nil
            }
        } message: {
            if let message = viewModel.importMessage {
                Text(message)
            }
        }
        .fileImporter(
            isPresented: $viewModel.showFilePicker,
            allowedContentTypes: [.json],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                if let url = urls.first {
                    viewModel.importDreams(from: url)
                }
            case .failure(let error):
                viewModel.importMessage = "Failed to select file: \(error.localizedDescription)"
            }
        }
        .sheet(isPresented: $viewModel.showShareSheet) {
            if let url = viewModel.exportedFileURL {
                ShareSheet(items: [url])
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 8) {
            Image(systemName: "gearshape.fill")
                .font(.system(size: 50))
                .foregroundStyle(Color.dreamPurple)

            Text("Settings")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 20)
        .padding(.bottom, 10)
    }

    // MARK: - Reminders Section

    private var remindersSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionTitle("Daily Reminders", icon: "bell.fill")

            VStack(spacing: 12) {
                // Enable Toggle
                HStack {
                    Label("Daily Dream Reminder", systemImage: "moon.stars")
                        .foregroundStyle(.white)
                        .font(.subheadline)

                    Spacer()

                    Toggle("", isOn: $viewModel.dailyReminderEnabled)
                        .tint(Color.dreamPurple)
                }

                // Time Picker
                if viewModel.dailyReminderEnabled {
                    HStack {
                        Label("Reminder Time", systemImage: "clock")
                            .foregroundStyle(.white.opacity(0.8))
                            .font(.subheadline)

                        Spacer()

                        DatePicker("", selection: $viewModel.reminderTime, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                            .tint(Color.dreamPurple)
                    }
                }
            }
            .padding(16)
            .dreamGlass(.calm, shape: AnyShape(RoundedRectangle(cornerRadius: 16)))
        }
    }

    // MARK: - Interpretation Style Section

    private var interpretationStyleSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionTitle("AI Interpretation Style", icon: "sparkles")

            VStack(spacing: 12) {
                ForEach(InterpretationStyle.allCases, id: \.self) { style in
                    styleOption(style)
                }
            }
            .padding(16)
            .dreamGlass(.mystic, shape: AnyShape(RoundedRectangle(cornerRadius: 16)))
        }
    }

    private func styleOption(_ style: InterpretationStyle) -> some View {
        let isSelected = viewModel.interpretationStyle == style

        return Button {
            withAnimation(.spring(response: 0.3)) {
                viewModel.interpretationStyle = style
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: style.icon)
                    .font(.title3)
                    .foregroundStyle(isSelected ? Color.dreamPurple : .white.opacity(0.6))
                    .frame(width: 30)

                VStack(alignment: .leading, spacing: 4) {
                    Text(style.rawValue)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.white)

                    Text(style.description)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                        .multilineTextAlignment(.leading)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.dreamPurple)
                }
            }
            .padding(12)
            .glassEffect(
                isSelected ? .regular.tint(Color.dreamPurple.opacity(0.3)).interactive() : .clear,
                in: .rect(cornerRadius: 12)
            )
        }
    }

    // MARK: - Lucid Dream Section

    private var lucidDreamSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionTitle("About Lucid Dreams", icon: "moon.stars.fill")

            VStack(alignment: .leading, spacing: 12) {
                Text("What are Lucid Dreams?")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)

                Text("Lucid dreaming is when you become aware that you're dreaming while you're still in the dream. This awareness can allow you to control aspects of your dream experience.")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.8))

                Text("Mark your dreams as lucid when you were conscious during the dream. This helps track your lucid dreaming progress and patterns.")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))
            }
            .padding(16)
            .dreamGlass(.lucid, shape: AnyShape(RoundedRectangle(cornerRadius: 16)))
        }
    }

    // MARK: - Data Management Section

    private var dataManagementSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionTitle("Data Management", icon: "externaldrive.fill")

            VStack(spacing: 12) {
                // Export Button
                Button {
                    viewModel.exportDreams()
                } label: {
                    HStack {
                        Label("Export Dreams", systemImage: "square.and.arrow.up")
                            .foregroundStyle(.white)
                            .font(.subheadline.weight(.medium))

                        Spacer()

                        if viewModel.isExporting {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.white.opacity(0.6))
                                .font(.caption)
                        }
                    }
                    .padding(16)
                }
                .dreamGlass(.calm, shape: AnyShape(RoundedRectangle(cornerRadius: 12)))
                .disabled(viewModel.isExporting)

                // Import Button
                Button {
                    viewModel.showFilePicker = true
                } label: {
                    HStack {
                        Label("Import Dreams", systemImage: "square.and.arrow.down")
                            .foregroundStyle(.white)
                            .font(.subheadline.weight(.medium))

                        Spacer()

                        if viewModel.isImporting {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.white.opacity(0.6))
                                .font(.caption)
                        }
                    }
                    .padding(16)
                }
                .dreamGlass(.calm, shape: AnyShape(RoundedRectangle(cornerRadius: 12)))
                .disabled(viewModel.isImporting)

                // Delete Button
                Button {
                    viewModel.showDeleteConfirmation = true
                } label: {
                    HStack {
                        Label("Delete All Data", systemImage: "trash.fill")
                            .foregroundStyle(.red)
                            .font(.subheadline.weight(.medium))

                        Spacer()

                        Image(systemName: "chevron.right")
                            .foregroundStyle(.red.opacity(0.6))
                            .font(.caption)
                    }
                    .padding(16)
                }
                .dreamGlass(.nightmare, shape: AnyShape(RoundedRectangle(cornerRadius: 12)))
            }
        }
    }

    // MARK: - Premium Section

    private var premiumSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionTitle("Premium", icon: "star.fill")

            if PurchaseManager.shared.hasPremium {
                // Premium Active
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundStyle(Color.dreamPurple)
                            .font(.title2)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Premium Active")
                                .font(.headline)
                                .foregroundStyle(.white)

                            Text("You have lifetime access to all features")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.7))
                        }

                        Spacer()
                    }
                    .padding(16)
                }
                .dreamGlass(.mystic, shape: AnyShape(RoundedRectangle(cornerRadius: 16)))

                // Restore Button (in case user needs it)
                Button {
                    Task {
                        await PurchaseManager.shared.restorePurchases()
                    }
                } label: {
                    HStack {
                        Label("Restore Purchases", systemImage: "arrow.clockwise")
                            .foregroundStyle(.white)
                            .font(.subheadline.weight(.medium))

                        Spacer()

                        Image(systemName: "chevron.right")
                            .foregroundStyle(.white.opacity(0.6))
                            .font(.caption)
                    }
                    .padding(16)
                }
                .dreamGlass(.calm, shape: AnyShape(RoundedRectangle(cornerRadius: 12)))

            } else {
                // Free Tier
                VStack(spacing: 12) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Free Plan")
                                .font(.headline)
                                .foregroundStyle(.white)

                            let remaining = AIUsageManager.shared.remainingFreeInterpretations
                            Text("\(remaining) AI interpretation\(remaining == 1 ? "" : "s") remaining this month")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.7))
                        }

                        Spacer()
                    }
                    .padding(16)
                }
                .dreamGlass(.calm, shape: AnyShape(RoundedRectangle(cornerRadius: 16)))

                // Upgrade Button
                Button {
                    showPaywall = true
                } label: {
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundStyle(Color.dreamPurple)

                        Text("Upgrade to Premium")
                            .font(.headline)
                            .foregroundStyle(.white)

                        Spacer()

                        Image(systemName: "chevron.right")
                            .foregroundStyle(.white.opacity(0.6))
                            .font(.caption)
                    }
                    .padding(16)
                }
                .dreamGlass(.vivid, shape: AnyShape(RoundedRectangle(cornerRadius: 12)))
            }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
    }

    // MARK: - About Section

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionTitle("About", icon: "info.circle.fill")

            VStack(spacing: 12) {
                aboutRow(title: "Version", value: "1.0.0")
                aboutRow(title: "Privacy Policy", value: "View", showChevron: true)
                aboutRow(title: "Terms of Service", value: "View", showChevron: true)
            }
            .padding(16)
            .dreamGlass(.calm, shape: AnyShape(RoundedRectangle(cornerRadius: 16)))

            // Privacy Note
            Text("🔒 All your dreams are stored locally on your device. No data is sent to external servers.")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.top, 8)
        }
    }

    private func aboutRow(title: String, value: String, showChevron: Bool = false) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.8))

            Spacer()

            Text(value)
                .font(.subheadline)
                .foregroundStyle(.white)

            if showChevron {
                Image(systemName: "chevron.right")
                    .foregroundStyle(.white.opacity(0.6))
                    .font(.caption)
            }
        }
    }

    // MARK: - Helpers

    private func sectionTitle(_ title: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(Color.dreamPurple)
                .font(.title3)

            Text(title)
                .font(.title3.weight(.semibold))
                .foregroundStyle(.white)
        }
    }
}

#Preview {
    SettingsView(
        viewModel: SettingsViewModel(
            modelContext: ModelContext(
                try! ModelContainer(for: Dream.self, configurations: .init(isStoredInMemoryOnly: true))
            )
        )
    )
}
