//
//  Logger.swift
//  ServerManager
//
//  Created by Sarvesh Doshi on 29/08/25.
//

import Foundation

final class Logger {
    var isEnabled: Bool
    var redactedHeaders: Set<String>

    init(isEnabled: Bool = true, redactedHeaders: Set<String> = ["Authorization"]) {
        self.isEnabled = isEnabled
        self.redactedHeaders = redactedHeaders
    }

    func info(_ message: String) { guard isEnabled else { return }; print("ℹ️ [INFO] \(message)") }
    func error(_ message: String) { guard isEnabled else { return }; print("🚨 [ERROR] \(message)") }
    func success(_ message: String) { guard isEnabled else { return }; print("🎉 [SUCCESS] \(message)") }

    func prettyJSON(_ data: Data) {
        guard isEnabled else { return }
        do {
            let obj = try JSONSerialization.jsonObject(with: data, options: [])
            let pretty = try JSONSerialization.data(withJSONObject: obj, options: [.prettyPrinted])
            if let string = String(data: pretty, encoding: .utf8) {
                info("📨 Response Data (Pretty Printed):\n\(string)")
            }
        } catch {
            self.error("Failed to Pretty Print JSON: \(error)")
        }
    }
}
