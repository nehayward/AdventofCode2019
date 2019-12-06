import Foundation

let inputFileURL = Bundle.main.url(forResource: "Input", withExtension: "txt")!
let inputs = try String(contentsOf: inputFileURL).split(separator: ",").compactMap { Int($0) }

func Intcode(for codes: [Int]) {
    var codes = codes
    for a in codes {
        print(a, "", separator: ",", terminator: "")
    }
    print()
    for i in stride(from: 0, to: codes.count+1, by: 4) {
        let opCode = codes[i]
        if opCode == 99 {
            break
        }
        if opCode == 1 {
            codes[codes[i+3]] = codes[codes[i+1]] + codes[codes[i+2]]
        } else if opCode == 2 {
            codes[codes[i+3]] = codes[codes[i+1]] * codes[codes[i+2]]
        }
    }
    
    for a in codes {
        print(a, "", separator: ",", terminator: "")
    }
}

Intcode(for: inputs)
print()
Intcode(for: [1,0,0,0,99])
print()
Intcode(for: [2,3,0,3,99])
print()
Intcode(for: [2,4,4,5,99,0])
print()
Intcode(for: [1,1,1,4,99,5,6,0,99])
print()

