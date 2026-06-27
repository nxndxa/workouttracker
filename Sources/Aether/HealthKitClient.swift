import Foundation

#if canImport(HealthKit)
@preconcurrency import HealthKit
#endif

enum HealthKitClientError: LocalizedError {
    case unavailable
    case missingType

    var errorDescription: String? {
        switch self {
        case .unavailable:
            "HealthKit is not available on this device."
        case .missingType:
            "A required HealthKit data type is unavailable."
        }
    }
}

#if canImport(HealthKit)
@MainActor
final class HealthKitClient {
    private let store = HKHealthStore()

    var isHealthDataAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }

    func requestAuthorization() async throws {
        guard isHealthDataAvailable else { throw HealthKitClientError.unavailable }

        guard
            let activeEnergy = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned),
            let distance = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning),
            let steps = HKQuantityType.quantityType(forIdentifier: .stepCount),
            let heartRate = HKQuantityType.quantityType(forIdentifier: .heartRate)
        else {
            throw HealthKitClientError.missingType
        }

        let shareTypes = Set<HKSampleType>()
        let readTypes: Set<HKObjectType> = [activeEnergy, distance, steps, heartRate]

        try await store.requestAuthorization(toShare: shareTypes, read: readTypes)
    }

    func fetchCurrentWeekMetrics() async throws -> HealthMetricsSnapshot {
        guard isHealthDataAvailable else { throw HealthKitClientError.unavailable }

        guard
            let activeEnergy = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned),
            let distance = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning),
            let steps = HKQuantityType.quantityType(forIdentifier: .stepCount),
            let heartRate = HKQuantityType.quantityType(forIdentifier: .heartRate)
        else {
            throw HealthKitClientError.missingType
        }

        let calendar = Calendar.current
        let startDate = calendar.dateInterval(of: .weekOfYear, for: .now)?.start ?? .now
        let endDate = Date()

        async let energyValue = cumulativeQuantity(
            activeEnergy,
            unit: .kilocalorie(),
            startDate: startDate,
            endDate: endDate
        )
        async let stepsValue = cumulativeQuantity(
            steps,
            unit: .count(),
            startDate: startDate,
            endDate: endDate
        )
        async let distanceValue = cumulativeQuantity(
            distance,
            unit: HKUnit.meterUnit(with: .kilo),
            startDate: startDate,
            endDate: endDate
        )
        async let heartRateValue = averageQuantity(
            heartRate,
            unit: HKUnit.count().unitDivided(by: .minute()),
            startDate: startDate,
            endDate: endDate
        )

        let energy = try await energyValue
        let stepCount = try await stepsValue
        let walkingDistance = try await distanceValue
        let averageHeartRate = try await heartRateValue

        return HealthMetricsSnapshot(
            activeEnergyKilocalories: Int(energy.rounded()),
            averageHeartRate: averageHeartRate.map { Int($0.rounded()) },
            steps: Int(stepCount.rounded()),
            walkingRunningDistanceKilometers: walkingDistance,
            updatedAt: .now
        )
    }

    private func cumulativeQuantity(
        _ type: HKQuantityType,
        unit: HKUnit,
        startDate: Date,
        endDate: Date
    ) async throws -> Double {
        try await withCheckedThrowingContinuation { continuation in
            let predicate = HKQuery.predicateForSamples(
                withStart: startDate,
                end: endDate,
                options: .strictStartDate
            )
            let query = HKStatisticsQuery(
                quantityType: type,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, statistics, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                let value = statistics?.sumQuantity()?.doubleValue(for: unit) ?? 0
                continuation.resume(returning: value)
            }

            store.execute(query)
        }
    }

    private func averageQuantity(
        _ type: HKQuantityType,
        unit: HKUnit,
        startDate: Date,
        endDate: Date
    ) async throws -> Double? {
        try await withCheckedThrowingContinuation { continuation in
            let predicate = HKQuery.predicateForSamples(
                withStart: startDate,
                end: endDate,
                options: .strictStartDate
            )
            let query = HKStatisticsQuery(
                quantityType: type,
                quantitySamplePredicate: predicate,
                options: .discreteAverage
            ) { _, statistics, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                let value = statistics?.averageQuantity()?.doubleValue(for: unit)
                continuation.resume(returning: value)
            }

            store.execute(query)
        }
    }

}
#else
@MainActor
final class HealthKitClient {
    var isHealthDataAvailable: Bool { false }

    func requestAuthorization() async throws {
        throw HealthKitClientError.unavailable
    }

    func fetchCurrentWeekMetrics() async throws -> HealthMetricsSnapshot {
        throw HealthKitClientError.unavailable
    }
}
#endif
