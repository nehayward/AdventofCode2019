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

var inputCodes = inputs
inputCodes.append(contentsOf: Array(repeating: 0, count: 1000))


// MARK: Oxygen System - Day 15

enum Movement: Int {
    case north = 1
    case south = 2
    case west = 3
    case east = 4
}

enum Status: Int {
    case hitWall = 0
    case succeeded = 1
    case oxygenSystem = 2
}

struct Position: Hashable {
    var x = 0, y = 0
}

var board = Array(repeating: Array(repeating: "_", count: 100), count: 100)
var current = Position(x: 50, y: 40)
var finish = Position(x: 50, y: 50)
var traveled = [Position:String]()


// MARK: Find Fewest Movements

//func nextPosition(current: Position) -> (Position, Movement)? {
//    let move = Movement(rawValue: Int.random(in: 1...4))!
//
//    switch move {
//    case .north:
//        let tryMove = Position(x: current.x, y: current.y - 1)
//
//        if traveled[tryMove] == nil {
//            return (tryMove, move)
//        }
//    case .south:
//        let tryMove = Position(x: current.x, y: current.y + 1)
//        if traveled[tryMove] == nil {
//            return (tryMove, move)
//        }
//    case .west:
//        let tryMove = Position(x: current.x - 1, y: current.y)
//        if traveled[tryMove] == nil {
//            return (tryMove, move)
//        }
//    case .east:
//        let tryMove = Position(x: current.x + 1, y: current.y)
//        if traveled[tryMove] == nil {
//            return (tryMove, move)
//        }
//    }
//    return nil
//}

func nextRepeatMove(current: Position) -> Movement {
    
    var flag = true
    while flag {
        let move = Movement(rawValue: Int.random(in: 1...4))!
        print("MOVE-------------",move, traveled)
        print(current)
        switch move {
        case .north:
            let tryMove = Position(x: current.x, y: current.y - 1)
            if let repeated = traveled[tryMove], repeated == "#" || repeated == "." {
                fallthrough
            } else {
                return move
            }
        case .south:
            let tryMove = Position(x: current.x, y: current.y + 1)
            if let repeated = traveled[tryMove], repeated == "#" || repeated == "." {
                fallthrough
            } else {
                return move
            }
        case .west:
            let tryMove = Position(x: current.x - 1, y: current.y)
            if let repeated = traveled[tryMove], repeated == "#" || repeated == "." {
                fallthrough
            } else {
                return move
            }
            
        case .east:
            let tryMove = Position(x: current.x + 1, y: current.y)
            if let repeated = traveled[tryMove], repeated == "#" || repeated == "." {
                // MARK: Try Again
                fallthrough
            } else {
                return move
            }
        default:
            // MARK: STUCK
            return  Movement(rawValue: Int.random(in: 1...4))!
        }
    }
    
    //    var tryMove = Position(x: current.x, y: current.y + 1)
    //
    //    if let repeated = traveled[tryMove], repeated != "#" {
    //        return (tryMove, .north)
    //    }
    //
    //    tryMove = Position(x: current.x, y: current.y - 1)
    //
    //    if let repeated = traveled[tryMove], repeated != "#" {
    //        return (tryMove, .south)
    //    }
    //
    //    tryMove = Position(x: current.x - 1, y: current.y)
    //
    //    if let repeated = traveled[tryMove], repeated != "#" {
    //        return (tryMove, .west)
    //    }
    //
    //    tryMove = Position(x: current.x + 1, y: current.y)
    //
    //    if let repeated = traveled[tryMove], repeated != "#" {
    //        return (tryMove, .east)
    //    }
    //
    
//    return (nil, nil)
}

traveled[current] = "D"
board[current.y][current.x] = "D"
var tryMovement = current
var move = Movement.south
// MARK: Find Fewest Movements

var movement = [4,4,4,4,3,3,3,3]
Intcode(for: &inputCodes, getInput: {
//    usleep(200000)

    //    if let move = nextPosition(current: current) {
    //        tryMovement = move.0
    //        let nextMove = move.1
    //        print(nextMove)
    //        return nextMove.rawValue
    //    } else {
    move = nextRepeatMove(current: current)
    //    tryMovement = move.0
    //    let nextMove = move.1
    //    print(current, tryMovement)
    //    print(nextMove)
    return move.rawValue
    //    }
},output: { output, numberOfOutputs in
    //    let clearScreen = Process()
    //    clearScreen.launchPath = "/usr/bin/clear"
    //    clearScreen.arguments = []
    //    clearScreen.launch()
    //    clearScreen.waitUntilExit()
    
    let status = Status(rawValue: output)!
//    print(status, tryMovement)
//    print(output)
//    print(traveled[tryMovement])
    switch status {
    case .hitWall:
        print(current)
        switch move {
        case .north:
            tryMovement = Position(x: current.x, y: current.y - 1)
        case .south:
            tryMovement = Position(x: current.x, y: current.y + 1)
        case .west:
            tryMovement = Position(x: current.x - 1, y: current.y)
        case .east:
            tryMovement = Position(x: current.x + 1, y: current.y)
        }
        print(tryMovement)
        board[tryMovement.y][tryMovement.x] = "#"
        traveled[tryMovement] = "#"
    case .succeeded:
        //        traveled[current] = "."
        //        traveled[tryMovement] = "D"
        board[current.y][current.x] = "."
        traveled[current] = "."
        print(current)
        print(move)
        switch move {
        case .north:
            current = Position(x: current.x, y: current.y - 1)
        case .south:
            current = Position(x: current.x, y: current.y + 1)
        case .west:
            current = Position(x: current.x - 1, y: current.y)
        case .east:
            current = Position(x: current.x + 1, y: current.y)
        }
        print(current)
        board[current.y][current.x] = "D"
        traveled[current] = "D"
        //        current = tryMovement
        print("Success")
    case .oxygenSystem:
        print("YAY!!!")
        print("Oxygen Here", tryMovement)
        board[tryMovement.y][tryMovement.x] = "👩‍⚕️"
        usleep(200000)
    }
    
    board.forEach {
        print($0.joined())
    }
    
    // MARK: Framerate
//    usleep(10000)
})
