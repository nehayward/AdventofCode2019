
import Foundation

let inputFileURL = Bundle.main.url(forResource: "Input", withExtension: "txt")!
let inputs = try String(contentsOf: inputFileURL).split(separator: ",").compactMap { Int($0) }


enum Opcode: Int {
    case add = 1
    case multiple = 2
    case input = 3
    case output = 4
    case halt = 99
}

enum ParameterMode: Int {
    case position = 0
    case immediate = 1
}

func Intcode(for codes: [Int]) {
    var codes = codes
    var i = 0
    while i < codes.count - 1  {
        
        let (parameter1, parameter2, parameter3, opCode) = getParameterMode(with: codes[i])
        print(parameter1, parameter2, parameter3, opCode)
     
        var p1 = 0
        var p2 = 0
        var p3 = 0
        
        print(i, codes[i])
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
            print("INPUT", codes[i+1])

            codes[codes[i+1]] = 1
            i = i + 2
        case .output:
            print("Output", codes[codes[i+1]])

//            if codes[codes[i+1]] != 0 {
//                print(codes)
//                fatalError()
//            }
            i = i + 2
        case .halt:
            
            return
        }
    }
    print(codes)
}
//
func getParameterMode(with number: Int) -> (ParameterMode?, ParameterMode?, ParameterMode?, Opcode?) {

    var stringNumber = String(number)
    guard !stringNumber.hasPrefix("-") else {
        print("Negative Number", stringNumber)
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

    print(stringNumber)
    let parameter1Mode = ParameterMode(rawValue: Int(String(stringNumber.popLast() ?? "0")) ?? 0)
    let parameter2Mode = ParameterMode(rawValue: Int(String(stringNumber.popLast() ?? "0")) ?? 0)
    let parameter3Mode = ParameterMode(rawValue: Int(String(stringNumber.popLast() ?? "0")) ?? 0)
    
    return (parameter1Mode, parameter2Mode, parameter3Mode, opCode)
}


// MARK: Test
//Intcode(for: [1002,4,3,4,33])

// Reset input
Intcode(for: inputs)






