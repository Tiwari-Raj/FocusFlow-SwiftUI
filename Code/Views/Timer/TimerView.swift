import SwiftUI

struct TimerView: View {
    @Environment(TimerViewModel.self) private var viewModel
    @Environment(SettingsStore.self) private var settings
    @State private var showingResetConfirmation = false

    var body: some View {
        NavigationStack {
            ZStack {
                viewModel.phase.backgroundGradient
                    .opacity(0.08)
                    .ignoresSafeArea()

                VStack(spacing: 32) {
                    Spacer()

                    PhaseBadge(phase: viewModel.phase)

                    ZStack {
                        CircularTimerRing(progress: viewModel.progress, accentColor: viewModel.phase.accentColor)
                            .frame(width: 260, height: 260)

                        VStack(spacing: 8) {
                            Text(viewModel.timeRemaining.mmss)
                                .font(.system(size: 54, weight: .semibold, design: .rounded))
                                .monospacedDigit()
                                .contentTransition(.numericText())
                                .animation(.snappy, value: viewModel.timeRemaining)

                            Text("Session \(viewModel.completedFocusSessions + 1)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }

                    SessionDotsView(
                        completed: viewModel.completedFocusSessions,
                        total: settings.sessionsBeforeLongBreak,
                        accentColor: viewModel.phase.accentColor
                    )

                    Spacer()

                    controls
                        .padding(.bottom, 24)
                }
                .padding()
            }
            .navigationTitle("FocusFlow")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.skip()
                    } label: {
                        Label("Skip", systemImage: "forward.end.fill")
                    }
                }
            }
            .confirmationDialog("Reset this session?", isPresented: $showingResetConfirmation, titleVisibility: .visible) {
                Button("Reset", role: .destructive) { viewModel.reset() }
                Button("Cancel", role: .cancel) {}
            }
        }
    }

    @ViewBuilder
    private var controls: some View {
        HStack(spacing: 20) {
            Button {
                showingResetConfirmation = true
            } label: {
                Image(systemName: "arrow.counterclockwise")
                    .font(.title2)
                    .frame(width: 56, height: 56)
                    .background(.ultraThinMaterial, in: Circle())
            }

            Button {
                if viewModel.isRunning {
                    viewModel.pause()
                } else {
                    viewModel.start()
                }
                if settings.hapticsEnabled {
                    HapticManager.impact()
                }
            } label: {
                Image(systemName: viewModel.isRunning ? "pause.fill" : "play.fill")
                    .font(.title)
                    .frame(width: 84, height: 84)
                    .background(viewModel.phase.accentColor, in: Circle())
                    .foregroundStyle(.white)
            }

            Button {
                viewModel.skip()
            } label: {
                Image(systemName: "forward.fill")
                    .font(.title2)
                    .frame(width: 56, height: 56)
                    .background(.ultraThinMaterial, in: Circle())
            }
        }
        .foregroundStyle(.primary)
    }
}
