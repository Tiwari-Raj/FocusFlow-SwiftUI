import SwiftUI

struct SettingsView: View {
    @Environment(SettingsStore.self) private var settingsEnv
    @State private var showingResetConfirmation = false

    var body: some View {
        @Bindable var settings = settingsEnv

        NavigationStack {
            Form {
                Section("Durations") {
                    Stepper(value: $settings.focusDuration, in: 300...3600, step: 60) {
                        LabeledContent("Focus", value: settings.focusDuration.mmss)
                    }
                    Stepper(value: $settings.shortBreakDuration, in: 60...1800, step: 60) {
                        LabeledContent("Short Break", value: settings.shortBreakDuration.mmss)
                    }
                    Stepper(value: $settings.longBreakDuration, in: 300...3600, step: 60) {
                        LabeledContent("Long Break", value: settings.longBreakDuration.mmss)
                    }
                    Stepper(value: $settings.sessionsBeforeLongBreak, in: 2...8) {
                        LabeledContent("Sessions before long break", value: "\(settings.sessionsBeforeLongBreak)")
                    }
                }

                Section("Behavior") {
                    Toggle("Auto-start next session", isOn: $settings.autoStartNextPhase)
                    Toggle("Sound", isOn: $settings.soundEnabled)
                    Toggle("Haptics", isOn: $settings.hapticsEnabled)
                }

                Section {
                    Button("Reset to Defaults", role: .destructive) {
                        showingResetConfirmation = true
                    }
                }

                Section {
                    LabeledContent("Version", value: "1.0.0")
                } header: {
                    Text("About")
                } footer: {
                    Text("FocusFlow uses Live Activities to keep your timer visible on the Lock Screen and Dynamic Island.")
                }
            }
            .navigationTitle("Settings")
            .confirmationDialog("Reset all settings?", isPresented: $showingResetConfirmation, titleVisibility: .visible) {
                Button("Reset", role: .destructive) { settings.resetToDefaults() }
                Button("Cancel", role: .cancel) {}
            }
        }
    }
}
