import Foundation

let inputFileURL = URL(fileURLWithPath: CommandLine.arguments[1])
let inputs = try String(contentsOf: inputFileURL).split(separator: ",").compactMap { Int($0.trimmingCharacters(in: .whitespacesAndNewlines)) }

//Opcode 5 is jump-if-true: if the first parameter is non-zero, it sets the instruction pointer to the value from the second parameter. Otherwise, it does nothing.
//Opcode 6 is jump-if-false: if the first parameter is zero, it sets the instruction pointer to the value from the second parameter. Otherwise, it does nothing.
//Opcode 7 is less than: if the first parameter is less than the second parameter, it stores 1 in the position given by the third parameter. Otherwise, it stores 0.
//Opcode 8 is equals: if the first parameter is equal to the second parameter, it stores 1 in the position given by the third parameter. Otherwise, it stores 0.
enum Opcode: Int {
    case add = 1
    case multiple = 2
    case input = 3
    case output = 4
    case jumpIfTrue = 5
    case jumpIfFalse = 6
    case lessThan = 7
    case equals = 8
    case halt = 99
}

enum ParameterMode: Int {
    case position = 0
    case immediate = 1
}

var IntcodeInput = 1

@discardableResult func Intcode(for codes: [Int], with input: Int = 0) -> Int {
    var lastOutput = 0
    var codes = codes
    var i = 0
    var flag = false
    while i < codes.count - 1  {
        
        let (parameter1, parameter2, parameter3, opCode) = getParameterMode(with: codes[i])
        
        var p1 = -1
        var p2 = -1
        switch opCode! {
        case .add:
            
            switch parameter1 {
            case .immediate:
                p1 = codes[i+1]
            default:
                p1 = codes[codes[i+1]]
            }
            
            switch parameter2 {
            case .immediate:
                p2 = codes[i+2]
            default:
                p2 = codes[codes[i+2]]
            }
            
            switch parameter3 {
            case .immediate:
                codes[i+3] = p1 + p2
            default:
                codes[codes[i+3]] = p1 + p2
            }
            i = i + 4
        case .multiple:
            switch parameter1 {
            case .immediate:
                p1 = codes[i+1]
            default:
                p1 = codes[codes[i+1]]
            }
            
            switch parameter2 {
            case .immediate:
                p2 = codes[i+2]
            default:
                p2 = codes[codes[i+2]]
            }
            
            switch parameter3 {
            case .immediate:
                codes[i+3] = p1 * p2
            default:
                codes[codes[i+3]] = p1 * p2
            }
            i = i + 4
        case .input:
            if flag {
                switch parameter1 {
                case .immediate:
                    codes[codes[i+1]] = IntcodeInput
                default:
                    codes[codes[i+1]] = IntcodeInput
                }
                i = i + 2
                continue
            }
            switch parameter1 {
            case .immediate:
                codes[i+1] = input
            default:
                codes[codes[i+1]] = input
            }
            flag = true
            i = i + 2
        case .output:
            
            switch parameter1 {
            case .immediate:
                lastOutput = codes[i+1]
                IntcodeInput = codes[i+1]
            default:
                lastOutput = codes[codes[i+1]]
                IntcodeInput = codes[codes[i+1]]
            }
            i = i + 2
        case .halt:
            
            return lastOutput
        case .jumpIfTrue:
            switch parameter1 {
            case .immediate:
                p1 = codes[i+1]
            default:
                p1 = codes[codes[i+1]]
            }
            
            switch parameter2 {
            case .immediate:
                p2 = codes[i+2]
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
            default:
                p1 = codes[codes[i+1]]
            }
            
            switch parameter2 {
            case .immediate:
                p2 = codes[i+2]
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
            default:
                p1 = codes[codes[i+1]]
            }
            
            switch parameter2 {
            case .immediate:
                p2 = codes[i+2]
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
            default:
                
                p1 = codes[codes[i+1]]
                
            }
            
            switch parameter2 {
            case .immediate:
                p2 = codes[i+2]
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
            default:
                if p1 == p2 {
                    codes[codes[i+3]] = 1
                } else {
                    codes[codes[i+3]] = 0
                }
            }
            i = i + 4
            
            break
        }
    }
    
    return -1
}
//
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


// MARK: Test
IntcodeInput = 0
Intcode(for: [3,15,3,16,1002,16,10,16,1,16,15,15,4,15,99,0,0], with: 4)
Intcode(for: [3,15,3,16,1002,16,10,16,1,16,15,15,4,15,99,0,0], with: 3)
Intcode(for: [3,15,3,16,1002,16,10,16,1,16,15,15,4,15,99,0,0], with: 2)
Intcode(for: [3,15,3,16,1002,16,10,16,1,16,15,15,4,15,99,0,0], with: 1)
Intcode(for: [3,15,3,16,1002,16,10,16,1,16,15,15,4,15,99,0,0], with: 0)

IntcodeInput = 0
Intcode(for: [3,23,3,24,1002,24,10,24,1002,23,-1,23,
              101,5,23,23,1,24,23,23,4,23,99,0,0], with: 0)
Intcode(for: [3,23,3,24,1002,24,10,24,1002,23,-1,23,
              101,5,23,23,1,24,23,23,4,23,99,0,0], with: 1)
Intcode(for: [3,23,3,24,1002,24,10,24,1002,23,-1,23,
              101,5,23,23,1,24,23,23,4,23,99,0,0], with: 2)
Intcode(for: [3,23,3,24,1002,24,10,24,1002,23,-1,23,
              101,5,23,23,1,24,23,23,4,23,99,0,0], with: 3)
let a = Intcode(for: [3,23,3,24,1002,24,10,24,1002,23,-1,23,
                      101,5,23,23,1,24,23,23,4,23,99,0,0], with: 4)

IntcodeInput = 0
Intcode(for: [3,31,3,32,1002,32,10,32,1001,31,-2,31,1007,31,0,33,
              1002,33,7,33,1,33,31,31,1,32,31,31,4,31,99,0,0,0], with: 1)
Intcode(for: [3,31,3,32,1002,32,10,32,1001,31,-2,31,1007,31,0,33,
              1002,33,7,33,1,33,31,31,1,32,31,31,4,31,99,0,0,0], with: 0)
Intcode(for: [3,31,3,32,1002,32,10,32,1001,31,-2,31,1007,31,0,33,
              1002,33,7,33,1,33,31,31,1,32,31,31,4,31,99,0,0,0], with: 4)
Intcode(for: [3,31,3,32,1002,32,10,32,1001,31,-2,31,1007,31,0,33,
              1002,33,7,33,1,33,31,31,1,32,31,31,4,31,99,0,0,0], with: 3)
Intcode(for: [3,31,3,32,1002,32,10,32,1001,31,-2,31,1007,31,0,33,
              1002,33,7,33,1,33,31,31,1,32,31,31,4,31,99,0,0,0], with: 2)
//Intcode(for: inputs)




// Sequence is from 0-4
// MARK: Generate Sequence
// Ooops each phase setting only used ones
func generateSequence() -> Set<[Int]> {
    var sequence = Set<[Int]>()
    for a in 0...4 {
        for b in 0...4 {
            for c in 0...4 {
                for d in 0...4 {
                    for e in 0...4 {
                        let s = [a,b,c,d,e]
                        if Set(s).count == 5 {
                            sequence.insert(s)
                        }
                    }
                }
            }
        }
    }
    
    
    return sequence
}

let sequences = generateSequence()
print(sequences)
// for sequence in sequences {
//   print(sequence)
// }
var maxThrust = 0
for sequence in sequences {
    IntcodeInput = 0
    Intcode(for: inputs, with: sequence[0])
    Intcode(for: inputs, with: sequence[1])
    Intcode(for: inputs, with: sequence[2])
    Intcode(for: inputs, with: sequence[3])
    let a = Intcode(for: inputs, with: sequence[4])
    if a > maxThrust {
        maxThrust = a
    }
}
//
print("Max Thrust", maxThrust)
