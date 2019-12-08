import Foundation

let inputFileURL = Bundle.main.url(forResource: "Input", withExtension: "txt")
let inputs = try String(contentsOf: inputFileURL!).split(separator: ",").compactMap { Int($0.trimmingCharacters(in: .whitespacesAndNewlines)) }

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

@discardableResult func Intcode(for codesPtr: inout [Int], with input: Int = 0, prevOutput: Int = 0, index: Int = 0, flag: Bool = false) -> (Int, Int) {
    var lastOutput = 0
    var codes = codesPtr
    var i = index
    var flag = flag
    
    while i < codes.count - 1  {
    
        print("I is now = ", i)
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
            print("Input Needed -------", prevOutput)
            if flag {
                switch parameter1 {
                case .immediate:
                    codes[codes[i+1]] = prevOutput
                default:
                    codes[codes[i+1]] = prevOutput
                }
                i = i + 2
                continue
            }
            print("Input -------", input)

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
            default:
                lastOutput = codes[codes[i+1]]
            }
            i = i + 2
            print(input)
            print("HELLO")
            codesPtr = codes
            return (lastOutput, i)
        case .halt:
            return (lastOutput, -1)
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
    
    return (-1, -1)
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

    (e, eIndex) = Intcode(for: &eInput, with: sequence[4], prevOutput: d, index: eIndex, flag: flag)
        
        print(aIndex,bIndex, cIndex, dIndex, eIndex)
        if aIndex == -1 {
            print(e, index)
            maxThrust = max(e, maxThrust)
            return
        }
        flag = true
    }
    print(e, index)
}

let s1 = [9,7,8,5,6]
//IntcodeInput = 0
//let test1 = [3,26,1001,26,-4,26,3,27,1002,27,2,27,1,27,26,
//         27,4,27,1001,28,-1,28,1005,28,6,99,0,0,5]
//
//feedBackLoop(with: test1, for: s1)

feedBackLoop(with: [3,52,1001,52,-5,52,3,53,1,52,56,54,1007,54,5,55,1005,55,26,1001,54,
                    -5,54,1105,1,12,1,53,54,53,1008,54,0,55,1001,55,1,55,2,53,55,53,4,
                    53,1001,56,-1,56,1005,56,6,99,0,0,0,0,10], for: s1)

var maxThrust = 0
for sequence in sequences {
    feedBackLoop(with: inputs, for: sequence)
}

print(maxThrust)
//
//let s2 = [1,0,4,3,2]
//feedBackLoop(with: [3,31,3,32,1002,32,10,32,1001,31,-2,31,1007,31,0,33,
//                    1002,33,7,33,1,33,31,31,1,32,31,31,4,31,99,0,0,0], for: s1)


