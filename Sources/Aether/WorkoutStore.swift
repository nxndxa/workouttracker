import Foundation
import Observation
import UserNotifications

enum HealthStatus: Equatable {
    case notRequested
    case unavailable
    case authorized
    case failed(String)

    var title: String {
        switch self {
        case .notRequested: "Health not connected"
        case .unavailable: "Health unavailable"
        case .authorized: "Health connected"
        case .failed: "Health sync failed"
        }
    }

    var detail: String {
        switch self {
        case .notRequested:
            "Allow access to read calories, heart rate, steps, and activity metrics from Apple Health."
        case .unavailable:
            "HealthKit is not available on this device."
        case .authorized:
            "Health metrics can sync from Apple Health."
        case .failed(let message):
            message
        }
    }

    var symbolName: String {
        switch self {
        case .notRequested: "heart.text.square"
        case .unavailable: "exclamationmark.triangle"
        case .authorized: "heart.text.square.fill"
        case .failed: "xmark.octagon"
        }
    }
}

private struct AetherSettings: Codable {
    var weeklyGoalMinutes: Int
    var energyUnit: EnergyUnit
    var distanceUnit: DistanceUnit
    var hasSeenWelcome: Bool
    var selectedGoals: [FitnessGoal]
    var isOnboarded: Bool
    var hasSeenHealthPrompt: Bool
    var userDisplayName: String
    var authProvider: AuthProvider?
    var emailAddress: String
    var heightInches: Int
    var weightPounds: Int
    var dateOfBirth: Date
    var profilePhotoData: Data?
    var profilePhotoScale: Double
    var profilePhotoOffsetX: Double
    var profilePhotoOffsetY: Double
    var workoutTemplates: [WorkoutTemplate]
    var plannedWorkoutDays: [WorkoutDay]
    var remindersEnabled: Bool

    static let defaults = AetherSettings(
        weeklyGoalMinutes: 180,
        energyUnit: .kilocalories,
        distanceUnit: .kilometers,
        hasSeenWelcome: false,
        selectedGoals: [],
        isOnboarded: false,
        hasSeenHealthPrompt: false,
        userDisplayName: "",
        authProvider: nil,
        emailAddress: "",
        heightInches: 68,
        weightPounds: 160,
        dateOfBirth: Calendar.current.date(from: DateComponents(year: 2000, month: 1, day: 1)) ?? .now,
        profilePhotoData: nil,
        profilePhotoScale: 1,
        profilePhotoOffsetX: 0,
        profilePhotoOffsetY: 0,
        workoutTemplates: WorkoutTemplate.defaults,
        plannedWorkoutDays: [.monday, .wednesday, .friday],
        remindersEnabled: false
    )

    init(
        weeklyGoalMinutes: Int,
        energyUnit: EnergyUnit,
        distanceUnit: DistanceUnit,
        hasSeenWelcome: Bool,
        selectedGoals: [FitnessGoal],
        isOnboarded: Bool,
        hasSeenHealthPrompt: Bool,
        userDisplayName: String,
        authProvider: AuthProvider?,
        emailAddress: String,
        heightInches: Int,
        weightPounds: Int,
        dateOfBirth: Date,
        profilePhotoData: Data?,
        profilePhotoScale: Double,
        profilePhotoOffsetX: Double,
        profilePhotoOffsetY: Double,
        workoutTemplates: [WorkoutTemplate],
        plannedWorkoutDays: [WorkoutDay],
        remindersEnabled: Bool
    ) {
        self.weeklyGoalMinutes = weeklyGoalMinutes
        self.energyUnit = energyUnit
        self.distanceUnit = distanceUnit
        self.hasSeenWelcome = hasSeenWelcome
        self.selectedGoals = selectedGoals
        self.isOnboarded = isOnboarded
        self.hasSeenHealthPrompt = hasSeenHealthPrompt
        self.userDisplayName = userDisplayName
        self.authProvider = authProvider
        self.emailAddress = emailAddress
        self.heightInches = heightInches
        self.weightPounds = weightPounds
        self.dateOfBirth = dateOfBirth
        self.profilePhotoData = profilePhotoData
        self.profilePhotoScale = profilePhotoScale
        self.profilePhotoOffsetX = profilePhotoOffsetX
        self.profilePhotoOffsetY = profilePhotoOffsetY
        self.workoutTemplates = workoutTemplates
        self.plannedWorkoutDays = plannedWorkoutDays
        self.remindersEnabled = remindersEnabled
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let defaults = Self.defaults

        weeklyGoalMinutes = try container.decodeIfPresent(Int.self, forKey: .weeklyGoalMinutes) ?? defaults.weeklyGoalMinutes
        energyUnit = try container.decodeIfPresent(EnergyUnit.self, forKey: .energyUnit) ?? defaults.energyUnit
        distanceUnit = try container.decodeIfPresent(DistanceUnit.self, forKey: .distanceUnit) ?? defaults.distanceUnit
        hasSeenWelcome = try container.decodeIfPresent(Bool.self, forKey: .hasSeenWelcome) ?? defaults.hasSeenWelcome
        selectedGoals = try container.decodeIfPresent([FitnessGoal].self, forKey: .selectedGoals) ?? defaults.selectedGoals
        isOnboarded = try container.decodeIfPresent(Bool.self, forKey: .isOnboarded) ?? defaults.isOnboarded
        hasSeenHealthPrompt = try container.decodeIfPresent(Bool.self, forKey: .hasSeenHealthPrompt) ?? defaults.hasSeenHealthPrompt
        userDisplayName = try container.decodeIfPresent(String.self, forKey: .userDisplayName) ?? defaults.userDisplayName
        authProvider = try container.decodeIfPresent(AuthProvider.self, forKey: .authProvider) ?? defaults.authProvider
        emailAddress = try container.decodeIfPresent(String.self, forKey: .emailAddress) ?? defaults.emailAddress
        heightInches = try container.decodeIfPresent(Int.self, forKey: .heightInches) ?? defaults.heightInches
        weightPounds = try container.decodeIfPresent(Int.self, forKey: .weightPounds) ?? defaults.weightPounds
        dateOfBirth = try container.decodeIfPresent(Date.self, forKey: .dateOfBirth) ?? defaults.dateOfBirth
        profilePhotoData = try container.decodeIfPresent(Data.self, forKey: .profilePhotoData) ?? defaults.profilePhotoData
        profilePhotoScale = try container.decodeIfPresent(Double.self, forKey: .profilePhotoScale) ?? defaults.profilePhotoScale
        profilePhotoOffsetX = try container.decodeIfPresent(Double.self, forKey: .profilePhotoOffsetX) ?? defaults.profilePhotoOffsetX
        profilePhotoOffsetY = try container.decodeIfPresent(Double.self, forKey: .profilePhotoOffsetY) ?? defaults.profilePhotoOffsetY
        workoutTemplates = try container.decodeIfPresent([WorkoutTemplate].self, forKey: .workoutTemplates) ?? defaults.workoutTemplates
        plannedWorkoutDays = try container.decodeIfPresent([WorkoutDay].self, forKey: .plannedWorkoutDays) ?? defaults.plannedWorkoutDays
        remindersEnabled = try container.decodeIfPresent(Bool.self, forKey: .remindersEnabled) ?? defaults.remindersEnabled
    }
}

@MainActor
@Observable
final class WorkoutStore {
    var workouts: [WorkoutEntry]
    var healthMetrics: HealthMetricsSnapshot
    var workoutHistoryFilter: WorkoutHistoryFilter
    var workoutTemplates: [WorkoutTemplate] {
        didSet { saveSettings() }
    }
    var plannedWorkoutDays: [WorkoutDay] {
        didSet { saveSettings() }
    }
    var remindersEnabled: Bool {
        didSet { saveSettings() }
    }
    var selectedFocus: TrainingFocus
    var searchText: String
    var healthStatus: HealthStatus
    var isSyncing: Bool
    var weeklyGoalMinutes: Int {
        didSet { saveSettings() }
    }
    var energyUnit: EnergyUnit {
        didSet { saveSettings() }
    }
    var distanceUnit: DistanceUnit {
        didSet { saveSettings() }
    }
    var hasSeenWelcome: Bool {
        didSet { saveSettings() }
    }
    var selectedGoals: [FitnessGoal] {
        didSet { saveSettings() }
    }
    var isOnboarded: Bool {
        didSet { saveSettings() }
    }
    var hasSeenHealthPrompt: Bool {
        didSet { saveSettings() }
    }
    var userDisplayName: String {
        didSet { saveSettings() }
    }
    var authProvider: AuthProvider? {
        didSet { saveSettings() }
    }
    var emailAddress: String {
        didSet { saveSettings() }
    }
    var heightInches: Int {
        didSet { saveSettings() }
    }
    var weightPounds: Int {
        didSet { saveSettings() }
    }
    var dateOfBirth: Date {
        didSet { saveSettings() }
    }
    var profilePhotoData: Data? {
        didSet { saveSettings() }
    }
    var profilePhotoScale: Double {
        didSet { saveSettings() }
    }
    var profilePhotoOffsetX: Double {
        didSet { saveSettings() }
    }
    var profilePhotoOffsetY: Double {
        didSet { saveSettings() }
    }

    private let healthKit: HealthKitClient
    private let persistenceURL: URL
    private let settingsURL: URL

    init(healthKit: HealthKitClient? = nil) {
        let healthKit = healthKit ?? HealthKitClient()
        self.healthKit = healthKit
        self.persistenceURL = Self.makePersistenceURL()
        self.settingsURL = Self.makeSettingsURL()
        self.workouts = []
        self.healthMetrics = HealthMetricsSnapshot()
        self.workoutHistoryFilter = .oneMonth
        self.workoutTemplates = WorkoutTemplate.defaults
        self.plannedWorkoutDays = [.monday, .wednesday, .friday]
        self.remindersEnabled = false
        self.selectedFocus = .all
        self.searchText = ""
        self.healthStatus = healthKit.isHealthDataAvailable ? .notRequested : .unavailable
        self.isSyncing = false
        self.weeklyGoalMinutes = 180
        self.energyUnit = .kilocalories
        self.distanceUnit = .kilometers
        self.hasSeenWelcome = false
        self.selectedGoals = []
        self.isOnboarded = false
        self.hasSeenHealthPrompt = false
        self.userDisplayName = ""
        self.authProvider = nil
        self.emailAddress = ""
        self.heightInches = 68
        self.weightPounds = 160
        self.dateOfBirth = Calendar.current.date(from: DateComponents(year: 2000, month: 1, day: 1)) ?? .now
        self.profilePhotoData = nil
        self.profilePhotoScale = 1
        self.profilePhotoOffsetX = 0
        self.profilePhotoOffsetY = 0

        loadSettings()
        load()
    }

    var filteredWorkouts: [WorkoutEntry] {
        workouts
            .filter { workout in
                let isAppLogged = workout.source == .app
                let isInsideHistoryWindow = workoutHistoryFilter.startDate.map { workout.startDate >= $0 } ?? true
                let matchesFocus = selectedFocus == .all || workout.kind.focus == selectedFocus
                let matchesSearch = searchText.isEmpty
                    || workout.title.localizedCaseInsensitiveContains(searchText)
                    || workout.kind.rawValue.localizedCaseInsensitiveContains(searchText)
                    || workout.notes.localizedCaseInsensitiveContains(searchText)
                return isAppLogged && isInsideHistoryWindow && matchesFocus && matchesSearch
            }
            .sorted { $0.startDate > $1.startDate }
    }

    var recentWorkouts: [WorkoutEntry] {
        Array(workouts.filter { $0.source == .app }.sorted { $0.startDate > $1.startDate }.prefix(6))
    }

    var weeklyWorkouts: [WorkoutEntry] {
        let start = Calendar.current.date(byAdding: .day, value: -6, to: .now) ?? .now
        return workouts.filter { $0.source == .app && $0.startDate >= start }
    }

    var weeklyMinutes: Int {
        weeklyWorkouts.reduce(0) { $0 + $1.durationMinutes }
    }

    var weeklyEnergy: Int {
        weeklyWorkouts.reduce(0) { $0 + $1.energyKilocalories }
    }

    var weeklyVolume: Int {
        weeklyWorkouts.reduce(0) { $0 + $1.volumeLoad }
    }

    var trainedDaysThisWeek: Int {
        let calendar = Calendar.current
        let weekdays = Set(weeklyWorkouts.map { calendar.component(.weekday, from: $0.startDate) })
        return weekdays.count
    }

    var weeklySessionGoal: Int {
        max(plannedWorkoutDays.count, 1)
    }

    var sessionGoalProgress: Double {
        min(Double(trainedDaysThisWeek) / Double(weeklySessionGoal), 1)
    }

    var consistencyStreakDays: Int {
        let calendar = Calendar.current
        let trainedDays = Set(workouts.filter { $0.source == .app }.map { calendar.startOfDay(for: $0.startDate) })
        guard !trainedDays.isEmpty else { return 0 }

        var cursor = calendar.startOfDay(for: .now)
        if !trainedDays.contains(cursor), let yesterday = calendar.date(byAdding: .day, value: -1, to: cursor) {
            cursor = yesterday
        }

        var streak = 0
        while trainedDays.contains(cursor) {
            streak += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: cursor) else { break }
            cursor = previous
        }
        return streak
    }

    var totalDistanceKilometers: Double {
        let loggedDistance = workouts.filter { $0.source == .app }.compactMap(\.distanceKilometers).reduce(0, +)
        return loggedDistance + healthMetrics.walkingRunningDistanceKilometers
    }

    var bestWeightEntry: WorkoutEntry? {
        workouts
            .filter { $0.source == .app && ($0.weightPounds ?? 0) > 0 }
            .max { ($0.weightPounds ?? 0) < ($1.weightPounds ?? 0) }
    }

    var bestVolumeEntry: WorkoutEntry? {
        workouts
            .filter { $0.source == .app && $0.volumeLoad > 0 }
            .max { $0.volumeLoad < $1.volumeLoad }
    }

    var weeklyGoalTrend: [ProgressTrendPoint] {
        let calendar = Calendar.current
        let target = weeklySessionGoal

        return (0..<4).reversed().compactMap { offset in
            guard
                let weekDate = calendar.date(byAdding: .weekOfYear, value: -offset, to: .now),
                let interval = calendar.dateInterval(of: .weekOfYear, for: weekDate)
            else {
                return nil
            }

            let completed = Set(workouts.filter { workout in
                workout.source == .app
                    && workout.startDate >= interval.start
                    && workout.startDate < interval.end
            }.map { calendar.component(.weekday, from: $0.startDate) }).count

            let title = offset == 0 ? "This" : "\(offset)w"
            return ProgressTrendPoint(title: title, completed: completed, target: target)
        }
    }

    var workoutsByWeek: [(weekStart: Date, workouts: [WorkoutEntry])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: filteredWorkouts) { workout in
            calendar.dateInterval(of: .weekOfYear, for: workout.startDate)?.start ?? calendar.startOfDay(for: workout.startDate)
        }

        return grouped
            .map { (weekStart: $0.key, workouts: $0.value.sorted { $0.startDate > $1.startDate }) }
            .sorted { $0.weekStart > $1.weekStart }
    }

    var loggedWorkoutCount: Int {
        workouts.filter { $0.source == .app }.count
    }

    var reminderStatusText: String {
        if remindersEnabled {
            let days = plannedWorkoutDays.map(\.shortTitle).joined(separator: " ")
            return "Reminders on for \(days)"
        }
        return "Reminders off"
    }

    var healthSyncTitle: String {
        switch healthStatus {
        case .notRequested:
            "Connect Apple Health"
        case .unavailable:
            "Health unavailable"
        case .authorized:
            "Health metrics synced"
        case .failed:
            "Try Health sync again"
        }
    }

    var healthSyncDetail: String {
        if let updatedAt = healthMetrics.updatedAt {
            return "Last updated \(updatedAt.formatted(date: .abbreviated, time: .shortened))."
        }

        return healthStatus.detail
    }

    var healthSyncButtonTitle: String {
        switch healthStatus {
        case .authorized: "Sync"
        case .unavailable: "Unavailable"
        case .notRequested, .failed: "Connect"
        }
    }

    var averageEffort: Double {
        guard !weeklyWorkouts.isEmpty else { return 0 }
        let total = weeklyWorkouts.reduce(0) { $0 + $1.perceivedEffort }
        return Double(total) / Double(weeklyWorkouts.count)
    }

    var greetingName: String {
        let trimmed = userDisplayName.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "Athlete" : trimmed
    }

    var onboardingProviderText: String {
        guard let authProvider else { return "Not signed in" }
        if authProvider == .email, !emailAddress.isEmpty {
            return "Signed in with \(emailAddress)"
        }
        return "Signed in with \(authProvider.rawValue)"
    }

    var goalsSummaryText: String {
        guard !selectedGoals.isEmpty else { return "No goals selected" }
        return selectedGoals.map(\.rawValue).joined(separator: ", ")
    }

    var heightText: String {
        let feet = heightInches / 12
        let inches = heightInches % 12
        return "\(feet) ft \(inches) in"
    }

    var weightText: String {
        "\(weightPounds) lb"
    }

    var needsGoalSelection: Bool {
        selectedGoals.isEmpty
    }

    var needsWelcome: Bool {
        !hasSeenWelcome
    }

    var needsAuthentication: Bool {
        !isOnboarded
    }

    var needsHealthPrompt: Bool {
        isOnboarded && !hasSeenHealthPrompt
    }

    var goalProgress: Double {
        guard weeklyGoalMinutes > 0 else { return 0 }
        return min(Double(weeklyMinutes) / Double(weeklyGoalMinutes), 1)
    }

    func energyValueText(forKilocalories kilocalories: Int) -> String {
        energyUnit.valueText(forKilocalories: kilocalories)
    }

    func formattedEnergy(forKilocalories kilocalories: Int) -> String {
        energyUnit.formattedEnergy(forKilocalories: kilocalories)
    }

    func formattedDistance(forKilometers kilometers: Double) -> String {
        distanceUnit.formattedDistance(forKilometers: kilometers)
    }

    func syncHealthWorkouts() async {
        guard healthKit.isHealthDataAvailable else {
            healthStatus = .unavailable
            return
        }

        if healthStatus == .authorized {
            await refreshFromHealth()
        } else {
            await requestHealthAccess()
        }
    }

    func toggleGoal(_ goal: FitnessGoal) {
        if selectedGoals.contains(goal) {
            selectedGoals.removeAll { $0 == goal }
        } else {
            selectedGoals.append(goal)
        }
    }

    func completeOnboarding(provider: AuthProvider, displayName: String = "") {
        authProvider = provider
        userDisplayName = displayName
        if provider != .email {
            emailAddress = ""
        }
        isOnboarded = true
    }

    func completeEmailOnboarding(displayName: String, email: String) {
        authProvider = .email
        userDisplayName = displayName
        emailAddress = email
        isOnboarded = true
    }

    func markHealthPromptSeen() {
        hasSeenHealthPrompt = true
    }

    func markWelcomeSeen() {
        hasSeenWelcome = true
    }

    func signOutForTesting() {
        hasSeenWelcome = false
        selectedGoals = []
        isOnboarded = false
        hasSeenHealthPrompt = false
        authProvider = nil
        emailAddress = ""
        userDisplayName = ""
        workouts = []
        workoutTemplates = WorkoutTemplate.defaults
        plannedWorkoutDays = [.monday, .wednesday, .friday]
        remindersEnabled = false
        save()
    }

    func requestHealthAccess() async {
        guard healthKit.isHealthDataAvailable else {
            healthStatus = .unavailable
            return
        }

        isSyncing = true
        defer { isSyncing = false }

        do {
            try await healthKit.requestAuthorization()
            healthStatus = .authorized
            await refreshFromHealth(silent: true)
            hasSeenHealthPrompt = true
        } catch {
            healthStatus = .failed(error.localizedDescription)
        }
    }

    func refreshFromHealth(silent: Bool = false) async {
        guard healthKit.isHealthDataAvailable else {
            if !silent {
                healthStatus = .unavailable
            }
            return
        }

        isSyncing = true
        defer { isSyncing = false }

        do {
            healthMetrics = try await healthKit.fetchRecentMetrics(days: 7)
            healthStatus = .authorized
        } catch {
            if !silent {
                healthStatus = .failed(error.localizedDescription)
            }
        }
    }

    func deleteWorkouts(at offsets: IndexSet) {
        let visibleIDs = filteredWorkouts.map(\.id)
        let idsToDelete = offsets.compactMap { visibleIDs[safe: $0] }
        workouts.removeAll { idsToDelete.contains($0.id) }
        save()
    }

    func saveTrackedWorkout(_ draft: WorkoutTrackingDraft) async {
        guard draft.isSubmittable else { return }

        let workout = WorkoutEntry(
            kind: draft.kind,
            title: draft.title,
            startDate: dateInCurrentWeek(for: draft.day),
            durationMinutes: 0,
            energyKilocalories: 0,
            distanceKilometers: draft.kind.tracksDistance ? draft.distanceKilometers : nil,
            perceivedEffort: 6,
            source: .app,
            notes: draft.summaryNotes,
            muscleGroups: draft.muscleGroups,
            splitName: draft.splitName,
            weightPounds: draft.kind.tracksDistance ? nil : draft.weightPounds,
            reps: draft.kind.tracksDistance ? nil : draft.reps
        )

        workouts.insert(workout, at: 0)
        workouts.sort { $0.startDate > $1.startDate }
        save()
    }

    func saveTemplate(from draft: WorkoutTrackingDraft) {
        guard draft.isSubmittable else { return }
        let template = WorkoutTemplate(draft: draft)
        workoutTemplates.removeAll { $0.name.localizedCaseInsensitiveCompare(template.name) == .orderedSame }
        workoutTemplates.insert(template, at: 0)
    }

    func deleteTemplate(_ template: WorkoutTemplate) {
        workoutTemplates.removeAll { $0.id == template.id }
    }

    func togglePlannedWorkoutDay(_ day: WorkoutDay) {
        if plannedWorkoutDays.contains(day) {
            plannedWorkoutDays.removeAll { $0 == day }
        } else {
            plannedWorkoutDays.append(day)
            plannedWorkoutDays.sort { lhs, rhs in
                (WorkoutDay.allCases.firstIndex(of: lhs) ?? 0) < (WorkoutDay.allCases.firstIndex(of: rhs) ?? 0)
            }
        }

        if remindersEnabled {
            Task { await scheduleWorkoutReminders() }
        }
    }

    func updateReminderPreference(_ enabled: Bool) async {
        if enabled {
            let granted = try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound])
            remindersEnabled = granted == true
            if remindersEnabled {
                await scheduleWorkoutReminders()
            }
        } else {
            remindersEnabled = false
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: reminderIdentifiers)
        }
    }

    private func load() {
        guard let data = try? Data(contentsOf: persistenceURL) else { return }
        guard let decoded = try? JSONDecoder().decode([WorkoutEntry].self, from: data) else { return }
        workouts = decoded.filter { $0.source == .app }
    }

    private func dateInCurrentWeek(for day: WorkoutDay) -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: .now)
        components.weekday = (WorkoutDay.allCases.firstIndex(of: day) ?? 0) + 1
        components.hour = calendar.component(.hour, from: .now)
        components.minute = calendar.component(.minute, from: .now)
        return calendar.date(from: components) ?? .now
    }

    private func loadSettings() {
        guard let data = try? Data(contentsOf: settingsURL) else { return }
        guard let decoded = try? JSONDecoder().decode(AetherSettings.self, from: data) else { return }
        weeklyGoalMinutes = decoded.weeklyGoalMinutes
        energyUnit = decoded.energyUnit
        distanceUnit = decoded.distanceUnit
        hasSeenWelcome = decoded.hasSeenWelcome
        selectedGoals = decoded.selectedGoals
        isOnboarded = decoded.isOnboarded
        hasSeenHealthPrompt = decoded.hasSeenHealthPrompt
        userDisplayName = decoded.userDisplayName
        authProvider = decoded.authProvider
        emailAddress = decoded.emailAddress
        heightInches = decoded.heightInches
        weightPounds = decoded.weightPounds
        dateOfBirth = decoded.dateOfBirth
        profilePhotoData = decoded.profilePhotoData
        profilePhotoScale = decoded.profilePhotoScale
        profilePhotoOffsetX = decoded.profilePhotoOffsetX
        profilePhotoOffsetY = decoded.profilePhotoOffsetY
        workoutTemplates = decoded.workoutTemplates
        plannedWorkoutDays = decoded.plannedWorkoutDays
        remindersEnabled = decoded.remindersEnabled
    }

    private func save() {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        guard let data = try? encoder.encode(workouts) else { return }

        try? FileManager.default.createDirectory(
            at: persistenceURL.deletingLastPathComponent(),
            withIntermediateDirectories: true,
            attributes: nil
        )
        try? data.write(to: persistenceURL, options: [.atomic])
    }

    private func saveSettings() {
        let settings = AetherSettings(
            weeklyGoalMinutes: weeklyGoalMinutes,
            energyUnit: energyUnit,
            distanceUnit: distanceUnit,
            hasSeenWelcome: hasSeenWelcome,
            selectedGoals: selectedGoals,
            isOnboarded: isOnboarded,
            hasSeenHealthPrompt: hasSeenHealthPrompt,
            userDisplayName: userDisplayName,
            authProvider: authProvider,
            emailAddress: emailAddress,
            heightInches: heightInches,
            weightPounds: weightPounds,
            dateOfBirth: dateOfBirth,
            profilePhotoData: profilePhotoData,
            profilePhotoScale: profilePhotoScale,
            profilePhotoOffsetX: profilePhotoOffsetX,
            profilePhotoOffsetY: profilePhotoOffsetY,
            workoutTemplates: workoutTemplates,
            plannedWorkoutDays: plannedWorkoutDays,
            remindersEnabled: remindersEnabled
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        guard let data = try? encoder.encode(settings) else { return }

        try? FileManager.default.createDirectory(
            at: settingsURL.deletingLastPathComponent(),
            withIntermediateDirectories: true,
            attributes: nil
        )
        try? data.write(to: settingsURL, options: [.atomic])
    }

    private static func makePersistenceURL() -> URL {
        makeSupportDirectory()
            .appendingPathComponent("workouts.json")
    }

    private static func makeSettingsURL() -> URL {
        makeSupportDirectory()
            .appendingPathComponent("settings.json")
    }

    private static func makeSupportDirectory() -> URL {
        let supportDirectory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? URL(fileURLWithPath: NSTemporaryDirectory())
        return supportDirectory
            .appendingPathComponent("Aether", isDirectory: true)
    }

    private var reminderIdentifiers: [String] {
        WorkoutDay.allCases.map { "aether.workout-reminder.\($0.rawValue)" }
    }

    private func scheduleWorkoutReminders() async {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: reminderIdentifiers)

        for day in plannedWorkoutDays {
            let content = UNMutableNotificationContent()
            content.title = "Aether"
            content.body = "Planned workout today."
            content.sound = .default

            var dateComponents = DateComponents()
            dateComponents.weekday = (WorkoutDay.allCases.firstIndex(of: day) ?? 0) + 1
            dateComponents.hour = 8
            dateComponents.minute = 0

            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(
                identifier: "aether.workout-reminder.\(day.rawValue)",
                content: content,
                trigger: trigger
            )
            try? await center.add(request)
        }
    }
}

private extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
