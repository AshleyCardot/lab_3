//
//  MotionModel.swift
//  Commotion
//
//  Created by Eric Cooper Larson on 10/2/24.
//  Copyright © 2024 Eric Larson. All rights reserved.
//

import CoreMotion

// Protocol for the ViewController to conform to
protocol MotionDelegate {
    func activityUpdated(activity: CMMotionActivity)
    func pedometerUpdated(pedData: CMPedometerData)
}
class MotionModel {

    // MARK: - Class Variables
    private let activityManager = CMMotionActivityManager()
    private let pedometer = CMPedometer()
    var delegate: MotionDelegate?
    private(set) var stepsToday: Int = 0
    private(set) var stepsYesterday: Int = 0

    // MARK: - Motion Methods
    func startActivityMonitoring() {
        if CMMotionActivityManager.isActivityAvailable() {
            self.activityManager.startActivityUpdates(to: OperationQueue.main) { [weak self] activity in
                if let unwrappedActivity = activity,
                   let delegate = self?.delegate {
                    delegate.activityUpdated(activity: unwrappedActivity)
                }
            }
        }
    }

    func startPedometerMonitoring() {
        if CMPedometer.isStepCountingAvailable() {
            pedometer.startUpdates(from: Date()) { [weak self] pedData, error in
                if let unwrappedPedData = pedData,
                   let delegate = self?.delegate {
                    // Update stepsToday by adding the steps from the pedometer
                    if let newSteps = self?.stepsToday, let pedometerSteps = pedData?.numberOfSteps.intValue {
                        self?.stepsToday = newSteps + pedometerSteps // Cumulative addition
                    } else {
                        self?.stepsToday = pedData?.numberOfSteps.intValue ?? 0
                    }
                    delegate.pedometerUpdated(pedData: unwrappedPedData)
                }
            }
        }
    }

    // Fetch steps for yesterday
    func fetchStepsForYesterday(completion: @escaping () -> Void) {
        let calendar = Calendar.current
        let now = Date()
        let startOfToday = calendar.startOfDay(for: now)
        guard let startOfYesterday = calendar.date(byAdding: .day, value: -1, to: startOfToday) else {
            stepsYesterday = 0
            completion()
            return
        }

        if CMPedometer.isStepCountingAvailable() {
            pedometer.queryPedometerData(from: startOfYesterday, to: startOfToday) { [weak self] data, error in
                if let steps = data?.numberOfSteps {
                    self?.stepsYesterday = steps.intValue
                } else {
                    self?.stepsYesterday = 0  // Set to 0 if error occurs
                }
                DispatchQueue.main.async {
                    completion()
                }
            }
        } else {
            stepsYesterday = 0
            completion()
        }
    }

    // Fetch steps for today 
    func fetchStepsForToday(completion: @escaping () -> Void) {
        let calendar = Calendar.current
        let now = Date()
        let startOfToday = calendar.startOfDay(for: now)

        if CMPedometer.isStepCountingAvailable() {
            pedometer.queryPedometerData(from: startOfToday, to: now) { [weak self] data, error in
                if let steps = data?.numberOfSteps {
                    // Add the fetched steps to the current total
                    self?.stepsToday += steps.intValue
                } else {
                    self?.stepsToday += 0  // Set to 0 if error occurs
                }
                DispatchQueue.main.async {
                    completion()
                }
            }
        } else {
            stepsToday += 0
            completion()
        }
    }
}
