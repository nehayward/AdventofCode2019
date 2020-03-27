#!/usr/bin/env xcrun swift

import Foundation

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


@discardableResult func Intcode(for codesPtr: inout [Int], with input: Int = 0, prevOutput: Int = 0, index: Int = 0, flag: Bool = false, base: Int = 0, getInput: () -> (Int) = {return 0}, output: (Int, Int) -> () = { _,_ in }) -> (Int, Int) {

    var lastOutput = 0
    var codes = codesPtr
    codes.append(contentsOf: Array(repeating: 0, count: 10000))

    var i = index
    var base = base
    var alternate = true
    var numberOutputs = 0

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
            //            print("INPUT: ", input)
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
            if numberOutputs == 3 { numberOutputs = 0 }
            numberOutputs += 1
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
            output(lastOutput, numberOutputs)

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

// MARK: --- Day 17: Set and Forget ---

var input = """
1,330,331,332,109,2952,1101,1182,0,16,1101,1467,0,24,102,1,0,570,1006,570,36,1002,571,1,0,1001,570,-1,570,1001,24,1,24,1106,0,18,1008,571,0,571,1001,16,1,16,1008,16,1467,570,1006,570,14,21101,0,58,0,1105,1,786,1006,332,62,99,21102,1,333,1,21101,73,0,0,1106,0,579,1101,0,0,572,1101,0,0,573,3,574,101,1,573,573,1007,574,65,570,1005,570,151,107,67,574,570,1005,570,151,1001,574,-64,574,1002,574,-1,574,1001,572,1,572,1007,572,11,570,1006,570,165,101,1182,572,127,101,0,574,0,3,574,101,1,573,573,1008,574,10,570,1005,570,189,1008,574,44,570,1006,570,158,1105,1,81,21101,340,0,1,1105,1,177,21101,477,0,1,1106,0,177,21101,514,0,1,21101,0,176,0,1105,1,579,99,21102,1,184,0,1106,0,579,4,574,104,10,99,1007,573,22,570,1006,570,165,101,0,572,1182,21101,375,0,1,21101,211,0,0,1106,0,579,21101,1182,11,1,21101,222,0,0,1105,1,979,21101,0,388,1,21102,233,1,0,1106,0,579,21101,1182,22,1,21101,0,244,0,1106,0,979,21101,401,0,1,21102,1,255,0,1106,0,579,21101,1182,33,1,21101,266,0,0,1105,1,979,21101,414,0,1,21102,1,277,0,1106,0,579,3,575,1008,575,89,570,1008,575,121,575,1,575,570,575,3,574,1008,574,10,570,1006,570,291,104,10,21101,1182,0,1,21101,313,0,0,1105,1,622,1005,575,327,1101,0,1,575,21102,327,1,0,1106,0,786,4,438,99,0,1,1,6,77,97,105,110,58,10,33,10,69,120,112,101,99,116,101,100,32,102,117,110,99,116,105,111,110,32,110,97,109,101,32,98,117,116,32,103,111,116,58,32,0,12,70,117,110,99,116,105,111,110,32,65,58,10,12,70,117,110,99,116,105,111,110,32,66,58,10,12,70,117,110,99,116,105,111,110,32,67,58,10,23,67,111,110,116,105,110,117,111,117,115,32,118,105,100,101,111,32,102,101,101,100,63,10,0,37,10,69,120,112,101,99,116,101,100,32,82,44,32,76,44,32,111,114,32,100,105,115,116,97,110,99,101,32,98,117,116,32,103,111,116,58,32,36,10,69,120,112,101,99,116,101,100,32,99,111,109,109,97,32,111,114,32,110,101,119,108,105,110,101,32,98,117,116,32,103,111,116,58,32,43,10,68,101,102,105,110,105,116,105,111,110,115,32,109,97,121,32,98,101,32,97,116,32,109,111,115,116,32,50,48,32,99,104,97,114,97,99,116,101,114,115,33,10,94,62,118,60,0,1,0,-1,-1,0,1,0,0,0,0,0,0,1,20,14,0,109,4,2102,1,-3,586,21001,0,0,-1,22101,1,-3,-3,21102,1,0,-2,2208,-2,-1,570,1005,570,617,2201,-3,-2,609,4,0,21201,-2,1,-2,1105,1,597,109,-4,2105,1,0,109,5,2101,0,-4,629,21001,0,0,-2,22101,1,-4,-4,21101,0,0,-3,2208,-3,-2,570,1005,570,781,2201,-4,-3,652,21002,0,1,-1,1208,-1,-4,570,1005,570,709,1208,-1,-5,570,1005,570,734,1207,-1,0,570,1005,570,759,1206,-1,774,1001,578,562,684,1,0,576,576,1001,578,566,692,1,0,577,577,21101,702,0,0,1105,1,786,21201,-1,-1,-1,1106,0,676,1001,578,1,578,1008,578,4,570,1006,570,724,1001,578,-4,578,21101,0,731,0,1105,1,786,1106,0,774,1001,578,-1,578,1008,578,-1,570,1006,570,749,1001,578,4,578,21102,1,756,0,1105,1,786,1105,1,774,21202,-1,-11,1,22101,1182,1,1,21101,0,774,0,1105,1,622,21201,-3,1,-3,1106,0,640,109,-5,2106,0,0,109,7,1005,575,802,20102,1,576,-6,20101,0,577,-5,1106,0,814,21101,0,0,-1,21102,1,0,-5,21101,0,0,-6,20208,-6,576,-2,208,-5,577,570,22002,570,-2,-2,21202,-5,45,-3,22201,-6,-3,-3,22101,1467,-3,-3,1202,-3,1,843,1005,0,863,21202,-2,42,-4,22101,46,-4,-4,1206,-2,924,21102,1,1,-1,1106,0,924,1205,-2,873,21101,0,35,-4,1105,1,924,1201,-3,0,878,1008,0,1,570,1006,570,916,1001,374,1,374,1201,-3,0,895,1102,1,2,0,1201,-3,0,902,1001,438,0,438,2202,-6,-5,570,1,570,374,570,1,570,438,438,1001,578,558,921,21001,0,0,-4,1006,575,959,204,-4,22101,1,-6,-6,1208,-6,45,570,1006,570,814,104,10,22101,1,-5,-5,1208,-5,33,570,1006,570,810,104,10,1206,-1,974,99,1206,-1,974,1101,0,1,575,21101,973,0,0,1106,0,786,99,109,-7,2105,1,0,109,6,21101,0,0,-4,21102,1,0,-3,203,-2,22101,1,-3,-3,21208,-2,82,-1,1205,-1,1030,21208,-2,76,-1,1205,-1,1037,21207,-2,48,-1,1205,-1,1124,22107,57,-2,-1,1205,-1,1124,21201,-2,-48,-2,1106,0,1041,21102,-4,1,-2,1106,0,1041,21102,1,-5,-2,21201,-4,1,-4,21207,-4,11,-1,1206,-1,1138,2201,-5,-4,1059,1202,-2,1,0,203,-2,22101,1,-3,-3,21207,-2,48,-1,1205,-1,1107,22107,57,-2,-1,1205,-1,1107,21201,-2,-48,-2,2201,-5,-4,1090,20102,10,0,-1,22201,-2,-1,-2,2201,-5,-4,1103,1201,-2,0,0,1106,0,1060,21208,-2,10,-1,1205,-1,1162,21208,-2,44,-1,1206,-1,1131,1105,1,989,21101,0,439,1,1105,1,1150,21102,477,1,1,1106,0,1150,21102,1,514,1,21102,1149,1,0,1106,0,579,99,21102,1157,1,0,1105,1,579,204,-2,104,10,99,21207,-3,22,-1,1206,-1,1138,1202,-5,1,1176,2102,1,-4,0,109,-6,2105,1,0,10,11,34,1,9,1,34,1,9,1,7,9,18,1,9,1,7,1,7,1,18,1,9,1,7,1,7,1,18,1,9,1,7,1,7,1,18,1,9,1,7,1,7,1,18,1,9,1,7,1,7,1,18,9,1,13,3,1,26,1,9,1,3,1,3,1,20,11,5,1,1,9,18,1,5,1,3,1,5,1,1,1,1,1,3,1,1,1,18,1,5,1,3,1,5,1,1,1,1,1,3,1,1,1,18,1,5,1,3,1,5,1,1,1,1,1,3,1,1,1,18,1,5,1,1,9,1,1,1,1,3,9,12,1,5,1,3,1,7,1,1,1,5,1,5,1,10,9,3,1,1,9,5,1,5,1,10,1,1,1,9,1,1,1,5,1,7,1,5,14,9,9,7,1,5,2,9,1,13,1,13,1,5,2,7,9,7,1,13,1,5,2,7,1,1,1,5,1,7,1,19,2,7,1,1,1,5,1,7,1,19,2,7,1,1,1,5,1,7,1,19,2,7,1,1,13,1,1,7,14,7,1,7,1,5,1,1,1,7,1,12,1,7,1,7,1,5,1,1,1,7,1,12,1,7,1,7,1,5,1,1,1,7,1,12,9,7,9,7,1,34,1,9,1,34,1,9,1,34,1,9,1,34,11,12
"""

enum ASCII: Int {
    case scaffold = 35
    case empty = 46
    case newLine = 10
}

struct Coordinate: Hashable {
    var x = 0, y = 0
    var display: String = ""
}

var x = 0, y = 0
var array = [Coordinate]()
var scaffoldPositions = Set<Coordinate>()

var inputCodes = input.split(separator: ",").compactMap{ Int(String($0)) }
print(inputCodes.last!)
Intcode(for: &inputCodes , output: { output, _ in

    guard let o = ASCII(rawValue: output) else {
        print(output, x, y)

        array.append(Coordinate(x: x, y: y, display: String(UnicodeScalar(output)!)))
                x += 1

        return
    }

    switch o {
    case .scaffold:
        array.append(Coordinate(x: x, y: y, display: "#"))
        scaffoldPositions.insert(Coordinate(x: x, y: y))
                x += 1

    case .empty:
        array.append(Coordinate(x: x, y: y, display: "."))
                x += 1

    case .newLine:
        y += 1
        x = 0
        array.append(Coordinate(x: x, y: y, display: "new"))
    }
})

var a = [String]()
var b = [[String]]()
array.forEach {

    if $0.display == "new" {
        b.append(a)
        a.removeAll()
        return
    }
print($0)
    a.append($0.display)
}

for c in b {
    var p = c.reduce("", +)
    print(p)
}

extension Coordinate {
  func surroundingPositions() -> Array<Self> {
        var surround = [
            Self(x: x, y: y-1),
            Self(x: x, y: y+1),
            Self(x: x+1, y: y),
            Self(x: x-1, y: y),
        ]
        return surround
    }
}
var aligned = Set<Coordinate>()
for p in scaffoldPositions {
    let around = p.surroundingPositions()
    if scaffoldPositions.isSuperset(of: around) {
        aligned.insert(p)
    }
}

print(aligned)
  //       let parameters = aligned.map { $0.x * $0.y }
  //       g.draw(using: { $0!.character })

var sum = aligned.compactMap { $0.x * $0.y }.reduce(0, +)
print(sum)