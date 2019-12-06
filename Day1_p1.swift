#!/usr/bin/env xcrun swift

import Foundation

// Module Based on Mass - roundDown(mass/3) - 2
func parseInput() -> [String]? {
    let file = CommandLine.arguments[1]
    guard let data = try? Data(contentsOf: URL(fileURLWithPath: file)) else { return nil }
    let input = String(data: data, encoding: .utf8)!
    return input.split { $0.isNewline }.map{ String($0) }
}

func calculateFuel(for mass: Double) -> Int {
   Int((mass/3).rounded(.down) - 2)
}

guard let lines = parseInput() else { fatalError() }

let answer = lines.map{ calculateFuel(for: Double($0) as! Double) }.reduce(0, +)
print(answer)