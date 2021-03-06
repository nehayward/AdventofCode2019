#!/usr/bin/env xcrun swift

import Foundation

let input = "147981-691423"
let dash = Character("-")
let range = input.split(separator: dash)

print(range[0], range[1])

let first = Int(range[0])
let last = Int(range[1])

let numberRange = Array(first!...last!)


func isPossiblePassword(for number: String) -> Bool {
    // First Criteria
    if number.count != 6 {
        return false
    }

    // Second Criteria

    // Convert to array
    let numbers = number.compactMap { Int(String($0)) }

    for i in 0..<numbers.count-1 {
        if numbers[i] > numbers[i + 1] {
            return false
        }
    }
    // Third Criteria
    for i in 0..<numbers.count-1 {
        if numbers[i] == numbers[i + 1] {
            return true
        }
    }

    return false
}


print(isPossiblePassword(for: "111111"))
print(isPossiblePassword(for: "223450"))
print(isPossiblePassword(for: "123789"))


//let numberOfPossible = ["111111", "223450", "123789"].filter { isPossiblePassword(for: $0)}.count
//
//print(numberOfPossible)

let numberOfPossible = numberRange.filter { isPossiblePassword(for: String($0))}.count

print(numberOfPossible)
