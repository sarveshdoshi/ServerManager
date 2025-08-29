//
//  RetryPolicy.swift
//  ServerManager
//
//  Created by Sarvesh Doshi on 29/08/25.
//
import Foundation

struct RetryPolicy {
    let baseDelaySeconds: Double
    let multiplier: Double
    let jitterFraction: Double

    static let `default` = RetryPolicy(baseDelaySeconds: 1.0, multiplier: 2.0, jitterFraction: 0.2)

    func shouldRetry(error: Error, attempt: Int) -> Bool {
        // Simple policy: retry on any error up to maxRetries
        return true
    }

    func delay(for attempt: Int) -> Double {
        let raw = baseDelaySeconds * pow(multiplier, Double(attempt))
        let jitter = raw * jitterFraction
        return max(0, raw - jitter + Double.random(in: 0...jitter * 2))
    }
}
