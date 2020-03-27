import Foundation


let inputFileURL = Bundle.main.url(forResource: "Input", withExtension: "txt")!
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


@discardableResult func Intcode(for codesPtr: inout [Int], with input: Int = 0, prevOutput: Int = 0, index: Int = 0, flag: Bool = false, base: Int = 0, getInput: () -> (Int) = {return 0}, output: (Int, Int) -> () = { _,_ in }) -> (Int, Int) {
    var lastOutput = 0
    var codes = codesPtr
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

var inputCodes = inputs
inputCodes.append(contentsOf: Array(repeating: 0, count: 1000))


// MARK: Care Package - Day 13
// 1,2,3,6,5,4

enum TileID: Int {
    case empty = 0
    case wall
    case block
    case horizontalPaddle
    case ball
}

enum JoyStick: Int {
    case neutral = 0
    case tiltedLeft = -1
    case titledRight = 1
}

typealias Board = String



var array = [TileID]()
var previousPosition = ""
var board = Array(repeating: Array(repeating: " ", count: 50), count: 50)

var x = 0
var y = 0

Intcode(for: &inputCodes, getInput: {
    return 1
},output: { output, numberOfOutputs in

    if numberOfOutputs.isMultiple(of: 3) {
        print(output)
        if output == TileID.block.rawValue {
            array.append(TileID.block)
        }
        else if output == TileID.horizontalPaddle.rawValue {
//            print("Paddle Position", previousPosition)
        }
        previousPosition = ""
        print(x,y)
        switch TileID(rawValue: output)! {
        case .empty:
            break
        case .wall:
            board[y][x] = "W"
        case .block:
             board[y][x] = "*"
        case .horizontalPaddle:
             board[y][x] = "⎽"
        case .ball:
            board[y][x] = "O"
        }
    }else if numberOfOutputs.isMultiple(of: 2) {
//        print("y = ", output)
//        previousPosition += " \(output)"
        y = output
    }
    else {
        x = output
//        print("x = ", output)
//        previousPosition += "\(output)"
    }
})

//var xx = 20
//var yy = 0
//
//board[yy][xx] = "*"
//board[1][xx] = "*"

board.forEach {
    var row = ""
    $0.forEach { row += $0 }
    print(row)
}
