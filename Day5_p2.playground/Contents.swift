
import Foundation

let inputFileURL = Bundle.main.url(forResource: "Input", withExtension: "txt")!
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

func Intcode(for codes: [Int]) {
    var codes = codes
    var i = 0
    while i < codes.count - 1  {
        
        let (parameter1, parameter2, parameter3, opCode) = getParameterMode(with: codes[i])
     
        var p1 = -1
        var p2 = -1
        var p3 = -1
        print(codes[i])
        print(parameter1,parameter2, parameter3, opCode)
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
            
            switch parameter1 {
            case .immediate:
                codes[i+1] = IntcodeInput
            default:
                codes[codes[i+1]] = IntcodeInput
            }

            i = i + 2
        case .output:
            
            switch parameter1 {
            case .immediate:
                print("Output", codes[i+1])
            default:
                print("Output", codes[codes[i+1]])
            }
            i = i + 2
        case .halt:
            
            return
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
                print("HERE")
                print(codes[i+2])
                print(codes.count)
                p2 = codes[codes[i+2]]
                print("HERE")

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
}
//
func getParameterMode(with number: Int) -> (ParameterMode?, ParameterMode?, ParameterMode?, Opcode?) {

    var stringNumber = String(number)
    guard !stringNumber.hasPrefix("-") else {
        return (nil, nil,nil,nil)
    }
    print("HERE STRING NUM: ", stringNumber)
    
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
// Equal Position
Intcode(for: [3,9,8,9,10,9,4,9,99,-1,8])

// Less Than Position
Intcode(for: [3,9,7,9,10,9,4,9,99,-1,8])

IntcodeInput = 9
// Equal Immediate
Intcode(for: [3,3,1108,-1,8,3,4,3,99])

IntcodeInput = 8
print(IntcodeInput)
// Less Than Immediate
Intcode(for: [3,9,7,9,10,9,4,9,99,-1,8])

// Jump Test Position
IntcodeInput = 5
Intcode(for: [3,12,6,12,15,1,13,14,13,4,13,99,-1,0,1,9])

// Jump Test Immediate
IntcodeInput = 5
Intcode(for: [3,3,1105,-1,9,1101,0,0,12,4,12,99,1])



// Large
IntcodeInput = 5
Intcode(for: [3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,
    1106,0,36,98,0,0,1002,21,125,20,4,20,1105,1,46,104,
    999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99])

// Reset input
IntcodeInput = 5
Intcode(for: inputs)






