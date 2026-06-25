import SwiftUI

#if canImport(PhotosUI)
import PhotosUI
#endif

#if canImport(UIKit)
import UIKit
#endif

#if canImport(AppKit)
import AppKit
#endif

private enum AetherTheme {
    static let background = Color.black
    static let panel = Color(red: 0.07, green: 0.07, blue: 0.08)
    static let elevated = Color(red: 0.11, green: 0.11, blue: 0.12)
    static let border = Color.white.opacity(0.12)
    static let red = Color(red: 0.95, green: 0.08, blue: 0.10)
    static let redMuted = Color(red: 0.42, green: 0.04, blue: 0.05)
    static let text = Color.white
    static let mutedText = Color.white.opacity(0.64)
}

private enum MainTab: Hashable {
    case home
    case tracking
    case workouts
    case progress
}

struct ContentView: View {
    @Bindable var store: WorkoutStore

    var body: some View {
        Group {
            if store.needsWelcome {
                WelcomeView(store: store)
            } else if store.needsGoalSelection {
                GoalSelectionView(store: store)
            } else if store.needsAuthentication {
                LoginView(store: store)
            } else if store.needsHealthPrompt {
                HealthConnectView(store: store)
            } else {
                MainAppView(store: store)
            }
        }
        .tint(AetherTheme.red)
        .preferredColorScheme(.dark)
    }
}

private struct WelcomeView: View {
    @Bindable var store: WorkoutStore
    @State private var isAnimated = false

    var body: some View {
        ZStack {
            AetherTheme.background.ignoresSafeArea()

            Circle()
                .fill(AetherTheme.red.opacity(0.18))
                .frame(width: isAnimated ? 260 : 160, height: isAnimated ? 260 : 160)
                .blur(radius: 42)
                .offset(y: isAnimated ? -90 : -40)
                .animation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true), value: isAnimated)

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 22) {
                    ZStack {
                        Circle()
                            .stroke(AetherTheme.red.opacity(0.42), lineWidth: 1)
                            .frame(width: 132, height: 132)
                            .scaleEffect(isAnimated ? 1.08 : 0.94)

                        Image(systemName: "waveform.path.ecg")
                            .font(.system(size: 54, weight: .semibold))
                            .foregroundStyle(AetherTheme.red)
                            .frame(width: 108, height: 108)
                            .glassSurface(cornerRadius: 54, interactive: true)
                    }

                    VStack(spacing: 10) {
                        Text("Welcome to Aether")
                            .font(.system(size: 38, weight: .bold, design: .rounded))
                            .foregroundStyle(AetherTheme.text)
                            .multilineTextAlignment(.center)
                            .minimumScaleFactor(0.74)

                        Text("Your training history, goals, and weekly progress in one place.")
                            .font(.body)
                            .foregroundStyle(AetherTheme.mutedText)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: 330)
                    }
                    .opacity(isAnimated ? 1 : 0)
                    .offset(y: isAnimated ? 0 : 12)
                }

                Spacer()

                Button {
                    withAnimation(.easeInOut(duration: 0.32)) {
                        store.markWelcomeSeen()
                    }
                } label: {
                    Text("Let's Get Started")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                }
                .buttonStyle(.borderedProminent)
                .tint(AetherTheme.red)
                .padding(.bottom, 18)
            }
            .padding(24)
        }
        .onAppear {
            isAnimated = true
        }
    }
}

private struct GoalSelectionView: View {
    @Bindable var store: WorkoutStore
    @State private var draftGoals: Set<FitnessGoal> = []

    var body: some View {
        ZStack {
            AetherTheme.background.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("What are your goals?")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(AetherTheme.text)
                            .lineLimit(2)
                            .minimumScaleFactor(0.78)
                            .fixedSize(horizontal: false, vertical: true)

                        Text("Pick what you want Aether to help you track.")
                            .font(.body)
                            .foregroundStyle(AetherTheme.mutedText)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.top, 32)

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 12)], spacing: 12) {
                        ForEach(FitnessGoal.allCases) { goal in
                            GoalOptionButton(
                                goal: goal,
                                isSelected: draftGoals.contains(goal)
                            ) {
                                if draftGoals.contains(goal) {
                                    draftGoals.remove(goal)
                                } else {
                                    draftGoals.insert(goal)
                                }
                            }
                        }
                    }

                    Button {
                        store.selectedGoals = FitnessGoal.allCases.filter { draftGoals.contains($0) }
                    } label: {
                        Text("Continue")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AetherTheme.red)
                    .disabled(draftGoals.isEmpty)
                    .padding(.top, 8)
                }
                .padding(24)
            }
        }
    }
}

private struct GoalOptionButton: View {
    let goal: FitnessGoal
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 14) {
                Image(systemName: goal.symbolName)
                    .font(.title3)
                    .foregroundStyle(isSelected ? AetherTheme.text : AetherTheme.red)

                Text(goal.rawValue)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(AetherTheme.text)
                    .lineLimit(2)
                    .minimumScaleFactor(0.88)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(16)
            .frame(minHeight: 112, alignment: .topLeading)
            .background(isSelected ? AetherTheme.red : AetherTheme.panel, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(isSelected ? AetherTheme.red : AetherTheme.border, lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }
}

private struct LoginView: View {
    @Bindable var store: WorkoutStore
    @State private var showingEmailSignIn = false
    @State private var displayName = ""

    private var canContinue: Bool {
        !displayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        ZStack {
            AetherTheme.background.ignoresSafeArea()

            VStack(spacing: 26) {
                Spacer(minLength: 34)

                VStack(spacing: 18) {
                    ZStack {
                        Circle()
                            .fill(AetherTheme.redMuted)
                            .frame(width: 96, height: 96)
                        Image(systemName: "waveform.path.ecg")
                            .font(.system(size: 40, weight: .semibold))
                            .foregroundStyle(AetherTheme.red)
                    }

                    VStack(spacing: 10) {
                        Text("Aether")
                            .font(.system(size: 46, weight: .bold, design: .rounded))
                            .foregroundStyle(AetherTheme.text)

                        Text("Sign in so your dashboard can feel personal.")
                            .font(.title3)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(AetherTheme.mutedText)
                            .frame(maxWidth: 330)
                    }
                }

                TextField("Your name", text: $displayName)
                    .textFieldStyle(.plain)
                    .foregroundStyle(AetherTheme.text)
                    .padding(16)
                    .background(AetherTheme.panel, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(AetherTheme.border, lineWidth: 1)
                    }
                    .frame(maxWidth: 360)
                    #if os(iOS)
                    .textInputAutocapitalization(.words)
                    #endif

                Group {
                    if canContinue {
                        VStack(spacing: 12) {
                            appleSignInButton

                            AuthButton(
                                title: "Continue with Google",
                                leadingText: "G",
                                foreground: .black,
                                background: .white
                            ) {
                                store.completeOnboarding(provider: .google, displayName: displayName)
                            }

                            AuthButton(
                                title: "Continue with Email",
                                systemImage: "envelope.fill",
                                foreground: AetherTheme.text,
                                background: AetherTheme.elevated
                            ) {
                                showingEmailSignIn = true
                            }
                        }
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }
                }
                .frame(maxWidth: 360)
                .animation(.easeInOut(duration: 0.55), value: canContinue)

                Spacer(minLength: 30)
            }
            .padding(24)
        }
        .sheet(isPresented: $showingEmailSignIn) {
            EmailSignInSheet(store: store, displayName: displayName)
        }
    }

    @ViewBuilder
    private var appleSignInButton: some View {
        AuthButton(
            title: "Continue with Apple",
            systemImage: "apple.logo",
            foreground: .black,
            background: .white
        ) {
            store.completeOnboarding(provider: .apple, displayName: displayName)
        }
    }
}

private enum EmailAuthStep {
    case request
    case verify(EmailVerificationSession)
}

private struct EmailSignInSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var store: WorkoutStore
    @State private var name: String
    @State private var email = ""
    @State private var code = ""
    @State private var step: EmailAuthStep = .request
    @State private var isLoading = false
    @State private var errorMessage: String?

    private let verificationClient = EmailVerificationClient()

    init(store: WorkoutStore, displayName: String) {
        self.store = store
        self._name = State(initialValue: displayName)
    }

    private var canRequestCode: Bool {
        !isLoading
            && !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && email.trimmingCharacters(in: .whitespacesAndNewlines).contains("@")
    }

    private var canVerifyCode: Bool {
        !isLoading && code.trimmingCharacters(in: .whitespacesAndNewlines).count >= 4
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name", text: $name)
                        .disabled(isLoading || isVerificationStep)
                    TextField("Email", text: $email)
                        .disabled(isLoading || isVerificationStep)
                        #if os(iOS)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        #endif
                }

                if case .verify(let session) = step {
                    Section {
                        TextField("Verification code", text: $code)
                            #if os(iOS)
                            .keyboardType(.numberPad)
                            .textContentType(.oneTimeCode)
                            #endif

                        Text(verificationDetail(for: session))
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }

                if let errorMessage {
                    Section {
                        Text(errorMessage)
                            .font(.footnote)
                            .foregroundStyle(AetherTheme.red)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(AetherTheme.background)
            .navigationTitle(isVerificationStep ? "Verify Email" : "Email Account")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(isVerificationStep ? "Verify" : "Send Code") {
                        Task {
                            await handlePrimaryAction()
                        }
                    }
                    .disabled(isVerificationStep ? !canVerifyCode : !canRequestCode)
                }
            }
        }
    }

    private var isVerificationStep: Bool {
        if case .verify = step { return true }
        return false
    }

    private func verificationDetail(for session: EmailVerificationSession) -> String {
        if let expiresAt = session.expiresAt {
            return "Code sent to \(session.email). Expires \(expiresAt.formatted(date: .omitted, time: .shortened))."
        }
        return "Code sent to \(session.email)."
    }

    @MainActor
    private func handlePrimaryAction() async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        do {
            switch step {
            case .request:
                let session = try await verificationClient.requestCode(email: email, displayName: name)
                step = .verify(session)
            case .verify(let session):
                try await verificationClient.verifyCode(email: session.email, code: code)
                store.completeEmailOnboarding(displayName: name, email: session.email)
                dismiss()
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

private struct HealthConnectView: View {
    @Bindable var store: WorkoutStore

    var body: some View {
        ZStack {
            AetherTheme.background.ignoresSafeArea()

            VStack(spacing: 26) {
                Spacer(minLength: 40)

                VStack(spacing: 16) {
                    Image(systemName: "heart.text.square.fill")
                        .font(.system(size: 58, weight: .semibold))
                        .foregroundStyle(AetherTheme.red)
                        .frame(width: 110, height: 110)
                        .background(AetherTheme.redMuted, in: Circle())

                    VStack(spacing: 10) {
                        Text("Connect Apple Health")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(AetherTheme.text)

                        Text("Aether uses Apple Health for calories, heart rate, steps, and activity metrics.")
                            .font(.title3)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(AetherTheme.mutedText)
                            .frame(maxWidth: 350)
                    }
                }

                VStack(spacing: 12) {
                    Button {
                        Task { await store.syncHealthWorkouts() }
                    } label: {
                        if store.isSyncing {
                            ProgressView()
                                .tint(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 54)
                        } else {
                            Label("Connect Apple Health", systemImage: "heart.fill")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .frame(height: 54)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AetherTheme.red)
                    .disabled(store.isSyncing || store.healthStatus == .unavailable)

                    Button {
                        store.markHealthPromptSeen()
                    } label: {
                        Text(store.healthStatus == .unavailable ? "Continue in Simulator" : "Not Now")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(AetherTheme.text)
                    .background(AetherTheme.elevated, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .frame(maxWidth: 360)

                Text(store.healthStatus.detail)
                    .font(.footnote)
                    .foregroundStyle(AetherTheme.mutedText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

                Spacer(minLength: 34)
            }
            .padding(24)
        }
    }
}

private struct MainAppView: View {
    @Bindable var store: WorkoutStore
    @State private var selectedTab: MainTab = .home
    @State private var isShowingSettings = false

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(store: store, isShowingSettings: $isShowingSettings)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(MainTab.home)

            WorkoutTrackingView(store: store)
                .tabItem {
                    Label("Workout Tracking", systemImage: "plus.circle.fill")
                }
                .tag(MainTab.tracking)

            WorkoutsView(store: store)
                .tabItem {
                    Label("Workouts", systemImage: "list.bullet.rectangle")
                }
                .tag(MainTab.workouts)

            ProgressTabView(store: store)
                .tabItem {
                    Label("Progress", systemImage: "chart.line.uptrend.xyaxis")
                }
                .tag(MainTab.progress)
        }
        .sheet(isPresented: $isShowingSettings) {
            SettingsView(store: store)
        }
    }
}

private struct HomeView: View {
    @Bindable var store: WorkoutStore
    @Binding var isShowingSettings: Bool

    var body: some View {
        NavigationStack {
            ScrollView {
                if #available(iOS 26.0, macOS 26.0, *) {
                    GlassEffectContainer(spacing: 18) {
                        contentStack
                    }
                } else {
                    contentStack
                }
            }
            .background(AetherTheme.background.ignoresSafeArea())
            .navigationTitle("Aether")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        isShowingSettings = true
                    } label: {
                        ProfileAvatar(
                            data: store.profilePhotoData,
                            size: 30,
                            scale: store.profilePhotoScale,
                            offsetX: store.profilePhotoOffsetX,
                            offsetY: store.profilePhotoOffsetY
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Open Settings")
                }
            }
            .task {
                if store.healthStatus == .authorized {
                    await store.refreshFromHealth(silent: true)
                }
            }
            .refreshable {
                await store.syncHealthWorkouts()
            }
        }
    }

    private var contentStack: some View {
        VStack(alignment: .leading, spacing: 18) {
            header
            weeklyOverview
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Welcome, \(store.greetingName)")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(AetherTheme.text)

            Text("Here is this week's logged training and Health metrics.")
                .font(.subheadline)
                .foregroundStyle(AetherTheme.mutedText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 8)
    }

    private var weeklyOverview: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("This Week")
                    .font(.title2.bold())
                    .foregroundStyle(AetherTheme.text)
                Text("Aether logs with Apple Health metrics")
                    .font(.subheadline)
                    .foregroundStyle(AetherTheme.mutedText)
            }

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 130), spacing: 10)], spacing: 10) {
                HomeMetric(title: "Workouts", value: "\(store.weeklyWorkouts.count)", unit: "sessions", systemImage: "figure.run")
                HomeMetric(title: "Calories", value: store.energyValueText(forKilocalories: store.healthMetrics.activeEnergyKilocalories), unit: store.energyUnit.shortTitle, systemImage: "flame.fill")
                HomeMetric(title: "Steps", value: store.healthMetrics.steps.formatted(.number.grouping(.automatic)), unit: "steps", systemImage: "shoeprints.fill")
                HomeMetric(title: "Heart Rate", value: store.healthMetrics.heartRateText, unit: "avg bpm", systemImage: "heart.fill")
            }
        }
        .padding(16)
        .glassSurface(cornerRadius: 22)
    }

}

private struct WorkoutsView: View {
    @Bindable var store: WorkoutStore

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    previousWorkouts
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 14)
            }
            .background(AetherTheme.background.ignoresSafeArea())
            .navigationTitle("Workouts")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
        }
    }

    private var previousWorkouts: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Previous Workouts")
                    .font(.title2.bold())
                    .foregroundStyle(AetherTheme.text)

                Picker("History", selection: $store.workoutHistoryFilter) {
                    ForEach(WorkoutHistoryFilter.allCases) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
                .pickerStyle(.segmented)
            }

            if store.filteredWorkouts.isEmpty {
                EmptyWorkoutLogState()
            } else {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(store.workoutsByWeek, id: \.weekStart) { week in
                        WorkoutWeekSection(
                            weekStart: week.weekStart,
                            workouts: week.workouts,
                            energyUnit: store.energyUnit,
                            distanceUnit: store.distanceUnit
                        )
                    }
                }
            }
        }
    }
}

private struct WorkoutWeekSection: View {
    let weekStart: Date
    let workouts: [WorkoutEntry]
    let energyUnit: EnergyUnit
    let distanceUnit: DistanceUnit

    private var title: String {
        let calendar = Calendar.current
        let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart) ?? weekStart
        return "\(weekStart.formatted(date: .abbreviated, time: .omitted)) - \(weekEnd.formatted(date: .abbreviated, time: .omitted))"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundStyle(AetherTheme.text)

            VStack(spacing: 10) {
                ForEach(workouts) { workout in
                    WorkoutSummaryRow(
                        workout: workout,
                        energyUnit: energyUnit,
                        distanceUnit: distanceUnit
                    )
                }
            }
        }
    }
}

private struct WorkoutTrackingView: View {
    @Bindable var store: WorkoutStore
    @State private var draft = WorkoutTrackingDraft()
    @State private var hasSubmittedCurrentDraft = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    header
                    templateSection
                    workoutDetails
                    saveCard
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 14)
            }
            .background(AetherTheme.background.ignoresSafeArea())
            .navigationTitle("Workout Tracking")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
        }
        .onChange(of: draft) { _, _ in
            hasSubmittedCurrentDraft = false
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Workout Tracking")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(AetherTheme.text)
            Text("Log the workout you performed with muscle groups, weight, and reps.")
                .font(.subheadline)
                .foregroundStyle(AetherTheme.mutedText)
        }
        .padding(.top, 8)
    }

    private var workoutDetails: some View {
        VStack(alignment: .leading, spacing: 16) {
            Picker("Workout Type", selection: $draft.kind) {
                ForEach(WorkoutKind.allCases) { kind in
                    Label(kind.rawValue, systemImage: kind.symbolName).tag(kind)
                }
            }
            .pickerStyle(.menu)
            .padding(14)
            .background(AetherTheme.elevated, in: RoundedRectangle(cornerRadius: 14, style: .continuous))

            VStack(alignment: .leading, spacing: 10) {
                Text("Day")
                    .font(.headline)
                    .foregroundStyle(AetherTheme.text)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(WorkoutDay.allCases) { day in
                            DayBubble(title: day.shortTitle, accessibilityTitle: day.rawValue, isSelected: draft.day == day) {
                                draft.day = day
                            }
                        }
                    }
                }
            }

            VStack(alignment: .leading, spacing: 10) {
                Text("Muscle Groups")
                    .font(.headline)
                    .foregroundStyle(AetherTheme.text)

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 118), spacing: 8)], spacing: 8) {
                    ForEach(MuscleGroup.allCases) { group in
                        SelectableChip(
                            title: group.rawValue,
                            isSelected: draft.muscleGroups.contains(group)
                        ) {
                            draft.toggleMuscleGroup(group)
                        }
                    }
                }
            }

            TextField("Workout performed", text: $draft.workoutName)
                .textFieldStyle(.plain)
                .padding(14)
                .background(AetherTheme.elevated, in: RoundedRectangle(cornerRadius: 14, style: .continuous))

            TextField("Workout split", text: $draft.splitName)
                .textFieldStyle(.plain)
                .padding(14)
                .background(AetherTheme.elevated, in: RoundedRectangle(cornerRadius: 14, style: .continuous))

            if draft.kind.tracksDistance {
                TextField("Distance", value: $draft.distanceKilometers, format: .number.precision(.fractionLength(1)))
                    .textFieldStyle(.plain)
                    .padding(14)
                    .background(AetherTheme.elevated, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    #if os(iOS)
                    .keyboardType(.decimalPad)
                    #endif
            } else {
                HStack(spacing: 12) {
                    DialPickerPanel(title: "Weight", value: "\(draft.weightPounds) lb") {
                        Picker("Weight", selection: $draft.weightPounds) {
                            ForEach(0...600, id: \.self) { pounds in
                                Text("\(pounds) lb").tag(pounds)
                            }
                        }
                        #if os(iOS)
                        .pickerStyle(.wheel)
                        #endif
                    }

                    DialPickerPanel(title: "Reps", value: "\(draft.reps)") {
                        Picker("Reps", selection: $draft.reps) {
                            ForEach(1...50, id: \.self) { reps in
                                Text("\(reps)").tag(reps)
                            }
                        }
                        #if os(iOS)
                        .pickerStyle(.wheel)
                        #endif
                    }
                }
            }

            TextField("Notes", text: $draft.notes, axis: .vertical)
                .lineLimit(3...5)
                .textFieldStyle(.plain)
                .padding(14)
                .background(AetherTheme.elevated, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .profilePanel()
    }

    private var templateSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Templates")
                        .font(.headline)
                        .foregroundStyle(AetherTheme.text)
                    Text("Tap a saved session to fill the form.")
                        .font(.caption)
                        .foregroundStyle(AetherTheme.mutedText)
                }

                Spacer()

                Button {
                    store.saveTemplate(from: draft)
                } label: {
                    Image(systemName: "plus")
                        .font(.headline)
                }
                .disabled(!draft.isSubmittable)
                .accessibilityLabel("Save current workout as template")
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(store.workoutTemplates) { template in
                        TemplatePill(template: template) {
                            draft = template.draft(for: draft.day)
                        }
                    }
                }
            }
        }
        .profilePanel()
    }

    private var saveCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button {
                Task {
                    await store.saveTrackedWorkout(draft)
                    hasSubmittedCurrentDraft = true
                }
            } label: {
                Label(hasSubmittedCurrentDraft ? "Workout Logged" : "Log Workout", systemImage: hasSubmittedCurrentDraft ? "checkmark.circle.fill" : "square.and.pencil")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
            }
            .buttonStyle(.borderedProminent)
            .tint(AetherTheme.red)
            .opacity(hasSubmittedCurrentDraft ? 0.45 : 1)
            .blur(radius: hasSubmittedCurrentDraft ? 0.8 : 0)
            .disabled(hasSubmittedCurrentDraft || !draft.isSubmittable)

            Text(hasSubmittedCurrentDraft ? "Change any workout detail to enable the button again." : "Workouts logged here are saved in Aether only.")
                .font(.footnote)
                .foregroundStyle(AetherTheme.mutedText)
        }
        .profilePanel()
    }
}

private struct DayBubble: View {
    let title: String
    let accessibilityTitle: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline.weight(.bold))
                .foregroundStyle(isSelected ? AetherTheme.text : AetherTheme.mutedText)
                .frame(width: 42, height: 42)
                .background(isSelected ? AetherTheme.redMuted : AetherTheme.elevated, in: Circle())
                .overlay {
                    Circle().stroke(isSelected ? AetherTheme.red : AetherTheme.border, lineWidth: 1)
                }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityTitle)
    }
}

private struct TemplatePill: View {
    let template: WorkoutTemplate
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: template.kind.symbolName)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AetherTheme.red)

                VStack(alignment: .leading, spacing: 2) {
                    Text(template.name)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(AetherTheme.text)
                        .lineLimit(1)
                    Text(template.kind.tracksDistance ? "\(template.distanceKilometers.formatted(.number.precision(.fractionLength(1)))) km" : "\(template.weightPounds) lb x \(template.reps)")
                        .font(.caption)
                        .foregroundStyle(AetherTheme.mutedText)
                }
            }
            .padding(.horizontal, 13)
            .padding(.vertical, 10)
            .background(AetherTheme.elevated, in: Capsule())
        }
        .buttonStyle(.plain)
    }
}

private struct SelectableChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(isSelected ? AetherTheme.text : AetherTheme.mutedText)
                .lineLimit(1)
                .minimumScaleFactor(0.82)
                .padding(.horizontal, 12)
                .padding(.vertical, 9)
                .frame(maxWidth: .infinity)
                .background(isSelected ? AetherTheme.redMuted : AetherTheme.elevated, in: Capsule())
        }
        .buttonStyle(.plain)
    }
}

private struct ExerciseSelectorRow: View {
    let exercise: ExerciseOption

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: exercise.symbolName)
                .font(.headline)
                .foregroundStyle(AetherTheme.red)
                .frame(width: 38, height: 38)
                .background(AetherTheme.redMuted, in: RoundedRectangle(cornerRadius: 12, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 8) {
                    Text(exercise.name)
                        .font(.headline)
                        .foregroundStyle(AetherTheme.text)
                    Text(exercise.muscleGroup.rawValue)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(AetherTheme.text)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(AetherTheme.redMuted, in: Capsule())
                }
                if !exercise.aliases.isEmpty {
                    Text("Also known as: \(exercise.aliases.joined(separator: ", "))")
                        .font(.caption)
                        .foregroundStyle(AetherTheme.mutedText)
                        .lineLimit(1)
                }
            }

            Spacer()

            Image(systemName: "chevron.up.chevron.down")
                .font(.caption.weight(.bold))
                .foregroundStyle(AetherTheme.mutedText)
        }
        .padding(14)
        .background(AetherTheme.elevated, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

private struct ExerciseSelectorSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedExercise: ExerciseOption
    @Binding var selectedMuscleGroup: MuscleGroup
    @State private var searchText = ""

    private var filteredExercises: [ExerciseOption] {
        ExerciseOption.all.filter { exercise in
            let matchesGroup = exercise.muscleGroup == selectedMuscleGroup || selectedMuscleGroup == .wholeBody
            let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
            let matchesSearch = query.isEmpty
                || exercise.name.localizedCaseInsensitiveContains(query)
                || exercise.muscleGroup.rawValue.localizedCaseInsensitiveContains(query)
                || exercise.aliases.contains { $0.localizedCaseInsensitiveContains(query) }
            return matchesGroup && matchesSearch
        }
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Picker("Muscle Group", selection: $selectedMuscleGroup) {
                        ForEach(MuscleGroup.allCases) { group in
                            Text(group.rawValue).tag(group)
                        }
                    }
                    .pickerStyle(.menu)
                }

                Section {
                    ForEach(filteredExercises) { exercise in
                        Button {
                            selectedExercise = exercise
                            selectedMuscleGroup = exercise.muscleGroup
                            dismiss()
                        } label: {
                            ExerciseSelectorRow(exercise: exercise)
                        }
                        .buttonStyle(.plain)
                        .listRowBackground(AetherTheme.background)
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search exercises")
            .scrollContentBackground(.hidden)
            .background(AetherTheme.background)
            .navigationTitle("Choose Exercise")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}

private struct DialPickerPanel<Content: View>: View {
    let title: String
    let value: String
    let content: Content

    init(title: String, value: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.value = value
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 8) {
            VStack(spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(AetherTheme.mutedText)
                Text(value)
                    .font(.headline)
                    .foregroundStyle(AetherTheme.text)
            }

            content
                .frame(height: 126)
                .clipped()
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(AetherTheme.elevated, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

private struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var store: WorkoutStore

    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink {
                        PreferencesView(store: store)
                    } label: {
                        SettingsButtonRow(title: "Preferences", subtitle: "Units and display", systemImage: "slider.horizontal.3")
                    }

                    NavigationLink {
                        InfoView(store: store)
                    } label: {
                        SettingsButtonRow(title: "Info", subtitle: "Profile photo, height, weight, date of birth", systemImage: "person.text.rectangle")
                    }
                }

                Section {
                    Button("Sign Out", role: .destructive) {
                        store.signOutForTesting()
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(AetherTheme.background)
            .navigationTitle("Settings")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

private struct SettingsButtonRow: View {
    let title: String
    let subtitle: String
    let systemImage: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.headline)
                .foregroundStyle(AetherTheme.red)
                .frame(width: 38, height: 38)
                .background(AetherTheme.redMuted, in: RoundedRectangle(cornerRadius: 12, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.headline)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

private struct PreferencesView: View {
    @Bindable var store: WorkoutStore

    var body: some View {
        List {
            Section("Energy") {
                Picker("Calories Display", selection: $store.energyUnit) {
                    ForEach(EnergyUnit.allCases) { unit in
                        Text(unit.title).tag(unit)
                    }
                }
                .pickerStyle(.segmented)
            }

            Section("Distance") {
                Picker("Distance Display", selection: $store.distanceUnit) {
                    ForEach(DistanceUnit.allCases) { unit in
                        Text(unit.title).tag(unit)
                    }
                }
                .pickerStyle(.segmented)
            }

        }
        .scrollContentBackground(.hidden)
        .background(AetherTheme.background)
        .navigationTitle("Preferences")
    }
}

private enum InfoSheet: String, Identifiable {
    case photo

    var id: String { rawValue }
}

private struct InfoView: View {
    @Bindable var store: WorkoutStore
    @State private var activeSheet: InfoSheet?
    @State private var isEditingBodyInfo = false
    @State private var isEditingBirthday = false

    var body: some View {
        ScrollView {
            if #available(iOS 26.0, macOS 26.0, *) {
                GlassEffectContainer(spacing: 18) {
                    contentStack
                }
            } else {
                contentStack
            }
        }
        .background(AetherTheme.background.ignoresSafeArea())
        .navigationTitle("Info")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .photo:
                PhotoAlignmentSheet(store: store)
            }
        }
    }

    private var contentStack: some View {
        VStack(alignment: .leading, spacing: 18) {
            profilePhotoSection
            goalsSection
            bodyInfoSection
            birthdaySection
        }
        .padding(18)
    }

    private var profilePhotoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 16) {
                Button {
                    activeSheet = .photo
                } label: {
                    ProfileAvatar(
                        data: store.profilePhotoData,
                        size: 76,
                        scale: store.profilePhotoScale,
                        offsetX: store.profilePhotoOffsetX,
                        offsetY: store.profilePhotoOffsetY
                    )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Edit profile photo")

                VStack(alignment: .leading, spacing: 8) {
                    Text(store.greetingName)
                        .font(.title3.bold())
                        .foregroundStyle(AetherTheme.text)
                    Text(store.onboardingProviderText)
                        .font(.subheadline)
                        .foregroundStyle(AetherTheme.mutedText)
                    Text("\(store.heightText) • \(store.weightText)")
                        .font(.subheadline)
                        .foregroundStyle(AetherTheme.mutedText)
                }

                Spacer(minLength: 0)
            }
        }
        .profilePanel()
    }

    private var goalsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Goals")
                .font(.headline)
                .foregroundStyle(AetherTheme.text)

            FlowTagLayout(items: store.selectedGoals.map(\.rawValue))
        }
        .profilePanel()
    }

    private var bodyInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Body Info")
                .font(.headline)
                .foregroundStyle(AetherTheme.text)

            Button {
                withAnimation(.easeInOut(duration: 0.24)) {
                    isEditingBodyInfo.toggle()
                }
            } label: {
                InfoSummaryRow(
                    systemImage: "figure.stand",
                    title: "Height and Weight",
                    value: "\(store.heightText) • \(store.weightText)",
                    isExpanded: isEditingBodyInfo
                )
            }
            .buttonStyle(.plain)

            if isEditingBodyInfo {
                HStack(spacing: 12) {
                    WheelPickerPanel(title: "Height", value: store.heightText) {
                        Picker("Height", selection: $store.heightInches) {
                            ForEach(48...84, id: \.self) { inches in
                                Text("\(inches / 12) ft \(inches % 12) in").tag(inches)
                            }
                        }
                        #if os(iOS)
                        .pickerStyle(.wheel)
                        #endif
                    }

                    WheelPickerPanel(title: "Weight", value: store.weightText) {
                        Picker("Weight", selection: $store.weightPounds) {
                            ForEach(80...350, id: \.self) { pounds in
                                Text("\(pounds) lb").tag(pounds)
                            }
                        }
                        #if os(iOS)
                        .pickerStyle(.wheel)
                        #endif
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .profilePanel()
    }

    private var birthdaySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Date of Birth")
                .font(.headline)
                .foregroundStyle(AetherTheme.text)

            Button {
                withAnimation(.easeInOut(duration: 0.24)) {
                    isEditingBirthday.toggle()
                }
            } label: {
                InfoSummaryRow(
                    systemImage: "calendar",
                    title: "Birthday",
                    value: store.dateOfBirth.formatted(date: .abbreviated, time: .omitted),
                    isExpanded: isEditingBirthday
                )
            }
            .buttonStyle(.plain)

            if isEditingBirthday {
                DatePicker(
                    "Date of Birth",
                    selection: $store.dateOfBirth,
                    in: ...Date(),
                    displayedComponents: .date
                )
                .labelsHidden()
                #if os(iOS)
                .datePickerStyle(.wheel)
                #endif
                .frame(maxWidth: .infinity)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .profilePanel()
    }
}

private struct InfoSummaryRow: View {
    let systemImage: String
    let title: String
    let value: String
    var isExpanded: Bool = false

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.headline)
                .foregroundStyle(AetherTheme.red)
                .frame(width: 38, height: 38)
                .background(AetherTheme.redMuted, in: RoundedRectangle(cornerRadius: 12, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(AetherTheme.text)
                Text(value)
                    .font(.subheadline)
                    .foregroundStyle(AetherTheme.mutedText)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundStyle(AetherTheme.mutedText)
                .rotationEffect(.degrees(isExpanded ? 90 : 0))
        }
        .padding(.vertical, 6)
    }
}

private struct FlowTagLayout: View {
    let items: [String]

    var body: some View {
        if items.isEmpty {
            Text("No goals selected")
                .font(.subheadline)
                .foregroundStyle(AetherTheme.mutedText)
        } else {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 132), spacing: 8)], spacing: 8) {
                ForEach(items, id: \.self) { item in
                    Text(item)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(AetherTheme.text)
                        .lineLimit(1)
                        .minimumScaleFactor(0.82)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 9)
                        .background(AetherTheme.redMuted, in: Capsule())
                }
            }
        }
    }
}

private struct PhotoAlignmentSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var store: WorkoutStore
    #if canImport(PhotosUI)
    @State private var selectedPhoto: PhotosPickerItem?
    #endif

    var body: some View {
        let hasProfilePhoto = store.profilePhotoData != nil

        NavigationStack {
            VStack(spacing: 22) {
                ProfileAvatar(
                    data: store.profilePhotoData,
                    size: 150,
                    scale: store.profilePhotoScale,
                    offsetX: store.profilePhotoOffsetX,
                    offsetY: store.profilePhotoOffsetY
                )

                #if canImport(PhotosUI)
                PhotosPicker(selection: $selectedPhoto, matching: .images) {
                    Label(hasProfilePhoto ? "Change Photo" : "Choose Photo", systemImage: "photo")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                }
                .buttonStyle(.borderedProminent)
                .tint(AetherTheme.red)
                .onChange(of: selectedPhoto) { _, newValue in
                    Task {
                        guard let data = try? await newValue?.loadTransferable(type: Data.self) else { return }
                        store.profilePhotoData = data
                        store.profilePhotoScale = 1
                        store.profilePhotoOffsetX = 0
                        store.profilePhotoOffsetY = 0
                    }
                }
                #endif

                if store.profilePhotoData != nil {
                    VStack(alignment: .leading, spacing: 16) {
                        Slider(value: $store.profilePhotoScale, in: 1...2) {
                            Text("Zoom")
                        }
                        Slider(value: $store.profilePhotoOffsetX, in: -48...48) {
                            Text("Horizontal")
                        }
                        Slider(value: $store.profilePhotoOffsetY, in: -48...48) {
                            Text("Vertical")
                        }
                    }

                    Button("Reset Alignment") {
                        store.profilePhotoScale = 1
                        store.profilePhotoOffsetX = 0
                        store.profilePhotoOffsetY = 0
                    }

                    Button("Remove Photo", role: .destructive) {
                        store.profilePhotoData = nil
                        store.profilePhotoScale = 1
                        store.profilePhotoOffsetX = 0
                        store.profilePhotoOffsetY = 0
                    }
                }

                Spacer()
            }
            .padding(24)
            .background(AetherTheme.background.ignoresSafeArea())
            .navigationTitle("Profile Photo")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

private struct WheelPickerPanel<Content: View>: View {
    let title: String
    let value: String
    let content: Content

    init(title: String, value: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.value = value
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 8) {
            VStack(spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(AetherTheme.mutedText)
                Text(value)
                    .font(.headline)
                    .foregroundStyle(AetherTheme.text)
            }

            content
                .frame(height: 126)
                .clipped()
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(AetherTheme.elevated, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

private struct ProfileAvatar: View {
    let data: Data?
    let size: CGFloat
    var scale: Double = 1
    var offsetX: Double = 0
    var offsetY: Double = 0

    var body: some View {
        Group {
            if let platformImage {
                platformImage
                    .resizable()
                    .scaledToFill()
                    .scaleEffect(CGFloat(scale))
                    .offset(x: CGFloat(offsetX), y: CGFloat(offsetY))
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(AetherTheme.red)
                    .padding(size * 0.12)
            }
        }
        .frame(width: size, height: size)
        .background(AetherTheme.redMuted, in: Circle())
        .clipShape(Circle())
        .overlay {
            Circle().stroke(AetherTheme.border, lineWidth: 1)
        }
    }

    private var platformImage: Image? {
        guard let data else { return nil }

        #if canImport(UIKit)
        guard let image = UIImage(data: data) else { return nil }
        return Image(uiImage: image)
        #elseif canImport(AppKit)
        guard let image = NSImage(data: data) else { return nil }
        return Image(nsImage: image)
        #else
        return nil
        #endif
    }
}

private struct HomeMetric: View {
    let title: String
    let value: String
    let unit: String
    let systemImage: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: systemImage)
                .font(.headline)
                .foregroundStyle(AetherTheme.red)

            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(AetherTheme.text)
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)

                Text(unit)
                    .font(.caption)
                    .foregroundStyle(AetherTheme.mutedText)
            }

            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(AetherTheme.text)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassSurface(cornerRadius: 16)
    }
}

private struct EmptyWorkoutLogState: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: "square.and.pencil")
                .font(.title)
                .foregroundStyle(AetherTheme.red)

            VStack(alignment: .leading, spacing: 4) {
                Text("No workouts logged")
                    .font(.headline)
                    .foregroundStyle(AetherTheme.text)
                Text("Use Workout Tracking to add sessions. This list only shows workouts saved directly in Aether.")
                    .font(.subheadline)
                    .foregroundStyle(AetherTheme.mutedText)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassSurface(cornerRadius: 22, interactive: true)
    }
}

private struct WorkoutSummaryRow: View {
    let workout: WorkoutEntry
    let energyUnit: EnergyUnit
    let distanceUnit: DistanceUnit

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: workout.kind.symbolName)
                .font(.headline)
                .foregroundStyle(AetherTheme.red)
                .frame(width: 42, height: 42)
                .background(AetherTheme.redMuted, in: RoundedRectangle(cornerRadius: 14, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(workout.title)
                    .font(.headline)
                    .foregroundStyle(AetherTheme.text)

                Text(workout.startDate, format: .dateTime.month(.abbreviated).day().hour().minute())
                    .font(.subheadline)
                    .foregroundStyle(AetherTheme.mutedText)

                if !workout.notes.isEmpty {
                    Text(workout.notes)
                        .font(.caption)
                        .foregroundStyle(AetherTheme.mutedText)
                        .lineLimit(2)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("Logged")
                    .font(.headline)
                    .foregroundStyle(AetherTheme.text)

                Text(workout.source.rawValue)
                    .font(.caption)
                    .foregroundStyle(AetherTheme.mutedText)
            }
        }
        .padding(14)
        .glassSurface(cornerRadius: 18, interactive: true)
    }
}

private struct ProgressTabView: View {
    @Bindable var store: WorkoutStore

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    progressHeader
                    analyticsGrid
                    prSection
                    trendSection
                    planningSection
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 14)
            }
            .background(AetherTheme.background.ignoresSafeArea())
            .navigationTitle("Progress")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
        }
    }

    private var progressHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Progress")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(AetherTheme.text)
            Text("Weekly training, streaks, PRs, and Health metrics.")
                .font(.subheadline)
                .foregroundStyle(AetherTheme.mutedText)
        }
        .padding(.top, 8)
    }

    private var analyticsGrid: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 145), spacing: 10)], spacing: 10) {
            ProgressMetricCard(title: "Weekly Volume", value: store.weeklyVolume.formatted(.number.grouping(.automatic)), unit: "lb x reps", systemImage: "dumbbell")
            ProgressMetricCard(title: "Days Trained", value: "\(store.trainedDaysThisWeek)", unit: "this week", systemImage: "calendar.badge.checkmark")
            ProgressMetricCard(title: "Streak", value: "\(store.consistencyStreakDays)", unit: "days", systemImage: "flame.fill")
            ProgressMetricCard(title: "Distance", value: store.formattedDistance(forKilometers: store.totalDistanceKilometers), unit: "total", systemImage: "figure.run")
            ProgressMetricCard(title: "Avg Heart Rate", value: store.healthMetrics.heartRateText, unit: "bpm", systemImage: "heart.fill")
            ProgressMetricCard(title: "Goal", value: "\(Int((store.sessionGoalProgress * 100).rounded()))%", unit: "\(store.trainedDaysThisWeek)/\(store.weeklySessionGoal) days", systemImage: "target")
        }
    }

    private var prSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("PRs")
                .font(.headline)
                .foregroundStyle(AetherTheme.text)

            VStack(spacing: 10) {
                PRRow(
                    title: "Heaviest Set",
                    value: store.bestWeightEntry.map { "\($0.weightPounds ?? 0) lb" } ?? "--",
                    detail: store.bestWeightEntry?.title ?? "Log strength workouts to track this."
                )
                PRRow(
                    title: "Best Volume Set",
                    value: store.bestVolumeEntry.map { $0.volumeLoad.formatted(.number.grouping(.automatic)) } ?? "--",
                    detail: store.bestVolumeEntry?.title ?? "Volume uses weight x reps."
                )
            }
        }
        .profilePanel()
    }

    private var trendSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Goal Completion")
                .font(.headline)
                .foregroundStyle(AetherTheme.text)

            HStack(alignment: .bottom, spacing: 10) {
                ForEach(store.weeklyGoalTrend) { point in
                    VStack(spacing: 7) {
                        GeometryReader { proxy in
                            VStack {
                                Spacer()
                                RoundedRectangle(cornerRadius: 6, style: .continuous)
                                    .fill(AetherTheme.red)
                                    .frame(height: max(8, proxy.size.height * point.progress))
                            }
                        }
                        .frame(height: 96)
                        .frame(maxWidth: .infinity)
                        .background(AetherTheme.elevated, in: RoundedRectangle(cornerRadius: 8, style: .continuous))

                        Text(point.title)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(AetherTheme.mutedText)
                    }
                }
            }
        }
        .profilePanel()
    }

    private var planningSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Plan & Reminders")
                        .font(.headline)
                        .foregroundStyle(AetherTheme.text)
                    Text(store.reminderStatusText)
                        .font(.caption)
                        .foregroundStyle(AetherTheme.mutedText)
                }

                Spacer()

                Toggle("", isOn: Binding(
                    get: { store.remindersEnabled },
                    set: { isEnabled in
                        Task { await store.updateReminderPreference(isEnabled) }
                    }
                ))
                .labelsHidden()
            }

            HStack(spacing: 8) {
                ForEach(WorkoutDay.allCases) { day in
                    DayBubble(
                        title: day.shortTitle,
                        accessibilityTitle: "Plan \(day.rawValue)",
                        isSelected: store.plannedWorkoutDays.contains(day)
                    ) {
                        store.togglePlannedWorkoutDay(day)
                    }
                }
            }
        }
        .profilePanel()
    }
}

private struct ProgressMetricCard: View {
    let title: String
    let value: String
    let unit: String
    let systemImage: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: systemImage)
                .font(.headline)
                .foregroundStyle(AetherTheme.red)

            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(size: 25, weight: .bold, design: .rounded))
                    .foregroundStyle(AetherTheme.text)
                    .lineLimit(1)
                    .minimumScaleFactor(0.65)
                Text(unit)
                    .font(.caption)
                    .foregroundStyle(AetherTheme.mutedText)
            }

            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(AetherTheme.text)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassSurface(cornerRadius: 16)
    }
}

private struct PRRow: View {
    let title: String
    let value: String
    let detail: String

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AetherTheme.text)
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(AetherTheme.mutedText)
                    .lineLimit(1)
            }

            Spacer()

            Text(value)
                .font(.headline)
                .foregroundStyle(AetherTheme.red)
        }
        .padding(12)
        .background(AetherTheme.elevated, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

private struct AuthButton: View {
    let title: String
    var systemImage: String?
    var leadingText: String?
    let foreground: Color
    let background: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: 18, weight: .semibold))
                        .frame(width: 22)
                }

                if let leadingText {
                    Text(leadingText)
                        .font(.system(size: 18, weight: .semibold))
                        .frame(width: 22)
                }

                Text(title)
                    .font(.system(size: 18, weight: .semibold))
            }
            .foregroundStyle(foreground)
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(background, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(AetherTheme.border, lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }
}

private extension View {
    @ViewBuilder
    func glassSurface(cornerRadius: CGFloat, interactive: Bool = false) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)

        if #available(iOS 26.0, macOS 26.0, *) {
            if interactive {
                self
                    .background(AetherTheme.panel.opacity(0.54), in: shape)
                    .glassEffect(.regular.tint(AetherTheme.red.opacity(0.08)).interactive(), in: .rect(cornerRadius: cornerRadius))
                    .overlay {
                        shape.stroke(AetherTheme.border, lineWidth: 1)
                    }
            } else {
                self
                    .background(AetherTheme.panel.opacity(0.54), in: shape)
                    .glassEffect(.regular.tint(AetherTheme.red.opacity(0.05)), in: .rect(cornerRadius: cornerRadius))
                    .overlay {
                        shape.stroke(AetherTheme.border, lineWidth: 1)
                    }
            }
        } else {
            self
                .background(AetherTheme.panel, in: shape)
                .overlay {
                    shape.stroke(AetherTheme.border, lineWidth: 1)
                }
        }
    }

    func profilePanel() -> some View {
        self
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .glassSurface(cornerRadius: 22)
    }
}
