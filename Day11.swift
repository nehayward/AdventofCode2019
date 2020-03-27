#!/usr/bin/env xcrun swift

import Foundation

let inputFileURL = URL(fileURLWithPath: CommandLine.arguments[1])
let inputs = try String(contentsOf: inputFileURL).split(separator: ",").compactMap { Int($0.trimmingCharacters(in: .whitespacesAndNewlines)) }

//Opcode 5 is jump-if-true: if the first parameter is non-zero, it sets the instruction pointer to the value from the second parameter. Otherwise, it does nothing.
//Opcode 6 is jump-if-false: if the first parameter is zero, it sets the instruction pointer to the value from the second parameter. Otherwise, it does nothing.
//Opcode 7 is less than: if the first parameter is less than the second parameter, it stores 1 in the position given by the third parameter. Otherwise, it stores 0.
//Opcode 8 is equals: if the first parameter is equal to the second parameter, it stores 1 in the position given by the third parameter. Otherwise, it stores 0.
//Opcode 9 adjusts the relative base by the value of its only parameter. The relative base increases (or decreases, if the value is negative) by the value of the parameter.

enum Opcode: Int {
    case add = 1
    case multiple = 2
    case input = 3
    case output = 4
    case jumpIfTrue = 5
    case jumpIfFalse = 6
    case lessThan = 7
    case equals = 8
    case adjustBase = 9
    case halt = 99
}

enum ParameterMode: Int {
    case position = 0
    case immediate = 1
    case relative = 2
}


@discardableResult func Intcode(for codesPtr: inout [Int], with input: Int = 0, prevOutput: Int = 0, index: Int = 0, flag: Bool = false, base: Int = 0, getInput: () -> (Int) = {return 0}, output: (Int, Bool) -> () = { _,_ in }) -> (Int, Int) {
    var lastOutput = 0
    var codes = codesPtr
    var i = index
    var base = base
    var alternate = true
    
    while i < codes.count - 1  {
        let (parameter1, parameter2, parameter3, opCode) = getParameterMode(with: codes[i])

        var p1 = -1
        var p2 = -1
        switch opCode! {
        case .add:
            switch parameter1 {
            case .immediate:
                p1 = codes[i+1]
            case .relative:
                p1 = codes[codes[i+1] + base]
            default:
                p1 = codes[codes[i+1]]
            }

            switch parameter2 {
            case .immediate:
                p2 = codes[i+2]
            case .relative:
                p2 = codes[codes[i+2] + base]
            default:
                p2 = codes[codes[i+2]]
            }

            switch parameter3 {
            case .immediate:
                codes[i+3] = p1 + p2
            case .relative:
                codes[codes[i+3] + base] = p1 + p2
            default:
                codes[codes[i+3]] = p1 + p2
            }
            i = i + 4
        case .multiple:
            switch parameter1 {
        
            case .immediate:
                p1 = codes[i+1]
            case .relative:
                p1 = codes[base + codes[i+1]]
            default:
                p1 = codes[codes[i+1]]
            }

            switch parameter2 {
            case .immediate:
                p2 = codes[i+2]
            case .relative:
                p2 = codes[base + codes[i+2]]
            default:
                p2 = codes[codes[i+2]]
            }
            switch parameter3 {
            case .immediate:
                codes[i+3] = p1 * p2
            case .relative:
                codes[base + codes[i+3]] =  p1 * p2
            default:
                codes[codes[i+3]] = p1 * p2
            }
            i = i + 4
        case .input:
            let input = getInput()
            print("INPUT: ", input)
            switch parameter1 {
            case .immediate:
                codes[i+1] = input
            case .relative:
                codes[base + codes[i+1]] = input
            default:
                codes[codes[i+1]] = input
            }
            i = i + 2
        case .output:
            switch parameter1 {
            case .immediate:
                lastOutput = codes[i+1]
            case .relative:
                lastOutput = codes[base + codes[i+1]]
            default:
                lastOutput = codes[codes[i+1]]
            }
            
            i = i + 2
//            print("OUTPUT:", lastOutput)
            // Paint
            output(lastOutput, alternate)
            alternate.toggle()
//            return (lastOutput, i)
        case .halt:
            return (lastOutput, -1)
        case .jumpIfTrue:
            switch parameter1 {
            case .immediate:
                p1 = codes[i+1]
            case .relative:
                p1 = codes[base + codes[i+1]]
            default:
                p1 = codes[codes[i+1]]
            }

            switch parameter2 {
            case .immediate:
                p2 = codes[i+2]
            case .relative:
                p2 = codes[base + codes[i+2]]
            default:
                p2 = codes[codes[i+2]]
            }
            if p1 != 0 {
                i = p2
                continue
            }
            i = i + 3
        case .jumpIfFalse:
            switch parameter1 {
            case .immediate:
                p1 = codes[i+1]
            case .relative:
                p1 = codes[base + codes[i+1]]
            default:
                p1 = codes[codes[i+1]]
            }

            switch parameter2 {
            case .immediate:
                p2 = codes[i+2]
            case .relative:
                p2 = codes[base + codes[i+2]]
            default:
                p2 = codes[codes[i+2]]
            }

            if p1 == 0 {
                i = p2
                continue
            }
            i = i + 3

        case .lessThan:
            switch parameter1 {
            case .immediate:
                p1 = codes[i+1]
            case .relative:
                p1 = codes[base + codes[i+1]]
            default:
                p1 = codes[codes[i+1]]
            }

            switch parameter2 {
            case .immediate:
                p2 = codes[i+2]
            case .relative:
                p2 = codes[base + codes[i+2]]
            default:
                p2 = codes[codes[i+2]]
            }

            switch parameter3 {
            case .immediate:
                if p1 < p2 {
                    codes[i+3] = 1
                } else {
                    codes[i+3] = 0
                }
            case .relative:
                if p1 < p2 {
                    codes[base + codes[i+3]] = 1
                } else {
                    codes[base + codes[i+3]] = 0
                }
            default:
                if p1 < p2 {
                    codes[codes[i+3]] = 1
                } else {
                    codes[codes[i+3]] = 0
                }
            }
            i = i + 4
        case .equals:

            switch parameter1 {
            case .immediate:
                p1 = codes[i+1]
            case .relative:
                p1 = codes[base + codes[i+1]]
            default:
                p1 = codes[codes[i+1]]
            }

            switch parameter2 {
            case .immediate:
                p2 = codes[i+2]
            case .relative:
                p2 = codes[base + codes[i+2]]
            default:
                p2 = codes[codes[i+2]]
            }

            switch parameter3 {
            case .immediate:
                if p1 == p2 {
                    codes[i+3] = 1
                } else {
                    codes[i+3] = 0
                }
            case .relative:
                if p1 == p2 {
                    codes[base + codes[i+3]] = 1
                } else {
                    codes[base + codes[i+3]] = 0
                }
            default:
                if p1 == p2 {
                    codes[codes[i+3]] = 1
                } else {
                    codes[codes[i+3]] = 0
                }
            }
            i = i + 4

            break
        case .adjustBase:
            switch parameter1 {
            case .immediate:
                base = base + codes[i+1]
            case  .relative:
                print("HERE")
                base = base + codes[base + codes[i+1]]
            default:
                base = base + codes[codes[i+1]]
                break
            }

            i = i + 2
        }
    }

    return (-1, -1)
}


func getParameterMode(with number: Int) -> (ParameterMode?, ParameterMode?, ParameterMode?, Opcode?) {

    var stringNumber = String(number)
    guard !stringNumber.hasPrefix("-") else {
        return (nil, nil,nil,nil)
    }

    if stringNumber.count < 3 {
        return (nil, nil, nil, Opcode(rawValue: number))
    }

    let stringOpCode = Int(String(stringNumber.suffix(2)))!
    stringNumber.removeLast()
    stringNumber.removeLast()
    guard let opCode = Opcode(rawValue: stringOpCode) else {
        return (nil, nil, nil, nil)
    }

    let parameter1Mode = ParameterMode(rawValue: Int(String(stringNumber.popLast() ?? "0")) ?? 0)
    let parameter2Mode = ParameterMode(rawValue: Int(String(stringNumber.popLast() ?? "0")) ?? 0)
    let parameter3Mode = ParameterMode(rawValue: Int(String(stringNumber.popLast() ?? "0")) ?? 0)
    return (parameter1Mode, parameter2Mode, parameter3Mode, opCode)
}

// Sequence is from 0-4
// MARK: Generate Sequence
// Ooops each phase setting only used ones
func generateSequence(with range: ClosedRange<Int> = 0...4) -> [[Int]] {
    var sequence: [[Int]] = []
    for a in range {
        for b in range {
            for c in range {
                for d in range {
                    for e in range {
                        let s = [a,b,c,d,e]
                        if Set(s).count == 5 {
                            sequence.append(s)
                        }
                    }
                }
            }
        }
    }


    return sequence
}


let sequences = generateSequence(with: 5...9)
// for sequence in sequences {
//   print(sequence)
// }


//var maxThrust = 0
//for sequence in sequences {
//    IntcodeInput = 0
//    Intcode(for: inputs, with: sequence[0])
//    Intcode(for: inputs, with: sequence[1])
//    Intcode(for: inputs, with: sequence[2])
//    Intcode(for: inputs, with: sequence[3])
//    let a = Intcode(for: inputs, with: sequence[4])
//    if a > maxThrust {
//        maxThrust = a
//    }
//}
////
//print("Max Thrust", maxThrust)
var maxThrust = 0
func feedBackLoop(with inputs: [Int], for sequence: [Int]) {
    var a = 0, b = 0, c = 0, d = 0, e = 0, index = 0
    var aInput = inputs
    var bInput = inputs
    var cInput = inputs
    var dInput = inputs
    var eInput = inputs

    var aIndex = 0
    var bIndex = 0
    var cIndex = 0
    var dIndex = 0
    var eIndex = 0

    var flag = false

    while e != -1 {


        (a, aIndex) = Intcode(for: &aInput, with: sequence[0], prevOutput: e, index: aIndex, flag: flag)


        (b, bIndex) = Intcode(for: &bInput, with: sequence[1], prevOutput: a, index: bIndex, flag: flag)

        (c, cIndex) = Intcode(for: &cInput, with: sequence[2], prevOutput: b, index: cIndex, flag: flag)
        (d, dIndex) = Intcode(for: &dInput, with: sequence[3], prevOutput: c, index: dIndex, flag: flag)
        print(e, index)
        let lastE = e
        (e, eIndex) = Intcode(for: &eInput, with: sequence[4], prevOutput: d, index: eIndex, flag: flag)

        print(aIndex,bIndex, cIndex, dIndex, eIndex)
        if aIndex == -1 {
            print(lastE, index)
            maxThrust = max(lastE, maxThrust)
            return
        }
        flag = true
    }
    print(e, index)
}

var inputCodes = inputs
inputCodes.append(contentsOf: Array(repeating: 0, count: 1000))


// MARK: Space Police - Day 11

enum Color: Int {
    case black = 0
    case white = 1
}

extension Color: CustomStringConvertible {
    var description: String {
        return "\(self == .white ? "White" : "Black")"
    }
}

enum Position: Int {
    case up = 0
    case right = 1
    case down = 2
    case left = 3
}


enum Rotate: Int {
    case left90 = 0
    case right90 = 1
}


struct Coordinate: Hashable {
    var x = 0, y = 0
}

extension Coordinate: CustomStringConvertible {
    var description: String {
        return "CGRect(x: \(x), y: \(y), width: 2, height: 2)"
//        return "(\(x), \(y))"
    }
}

extension Coordinate: Equatable {}

extension Coordinate: Comparable {
    static func < (lhs: Coordinate, rhs: Coordinate) -> Bool {
        lhs.y < rhs.y
    }
}

struct Panel {
    var color: Color = .black
    var coordinate: Coordinate = Coordinate()
}

extension Panel: CustomStringConvertible {
    var description: String {
        return "\(coordinate) is \(color == .white ? "White" : "Black")"
    }
}

typealias Panels = [Coordinate: Color]

func rotate(by rotation: Rotate, from position: Position) -> Position {
    var rotateBy = rotation == .left90 ? -1 : 1
    rotateBy = rotateBy + position.rawValue
    
    switch rotateBy {
    case 0...3:
        return Position(rawValue: rotateBy)!
    case -1:
        return Position.left
    case 4:
        return Position.up
    default:
        return Position.up
    }
}

func move(from current: Coordinate, in direction: Position) -> Coordinate {
    var newCoordinate = current
    switch direction {
    case .up:
        newCoordinate.y += 1
    case .down:
        newCoordinate.y -= 1
    case .right:
        newCoordinate.x += 1
    case .left:
        newCoordinate.x -= 1
    }
    
    return newCoordinate
}

// MARK: Test Rotate
//rotate(by: .right90, from: .up)
//rotate(by: .right90, from: .right)
//rotate(by: .right90, from: .down)
//rotate(by: .right90, from: .left)
//
//rotate(by: .left90, from: .up)
//rotate(by: .left90, from: .right)
//rotate(by: .left90, from: .down)
//rotate(by: .left90, from: .left)

// MARK: Test Move
//var current = Coordinate()
//current = move(from: current, in: .up)
//current = move(from: current, in: .up)
//current = move(from: current, in: .up)
//current = move(from: current, in: .up)
//current = move(from: current, in: .up)
//current = move(from: current, in: .left)
//current = move(from: current, in: .left)
//current = move(from: current, in: .left)

//
var panels = Panels()
var current = Coordinate(x: 50, y: 50)
var position = Position.up

panels[current] = .white

Intcode(for: &inputCodes, getInput: {
    let color = panels[current]
    return color?.rawValue ?? 0
}, output: { outputted, shouldColor in
    if shouldColor {
        panels[current] = Color(rawValue: outputted)
    } else {
        let rotation = Rotate(rawValue: outputted)!
        position = rotate(by: rotation, from: position)
        current = move(from: current, in: position)
    }
})

print(panels.count)

var p2 = Array(panels.keys).sorted(by: <)
var whitePanels = p2.filter { panels[$0]! == .white }
print(whitePanels)

