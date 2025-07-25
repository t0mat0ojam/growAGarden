//
//  Habit.swift
//  growAGardenApp
//
//  Created by YourName on 2023/01/01.
//

import Foundation
import FirebaseFirestoreSwift // For @DocumentID and Codable support

/// Represents a single habit with its name and daily completion status.
struct Habit: Identifiable, Codable, Equatable {
    // @DocumentID automatically maps the Firestore document ID to this property.
    @DocumentID var id: String?
    var name: String
    // Stores completion status for each day, e.g., ["YYYY-MM-DD": true/false]
    var completions: [String: Bool] = [:]

    // Conformance to Equatable for List operations (optional but good practice)
    static func == (lhs: Habit, rhs: Habit) -> Bool {
        lhs.id == rhs.id
    }
}
