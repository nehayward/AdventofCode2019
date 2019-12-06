import Foundation

let inputFileURL = Bundle.main.url(forResource: "Input", withExtension: "txt")!
let inputs = try String(contentsOf: inputFileURL).split(separator: ",").compactMap { Int($0) }

func Intcode(for codes: [Int]) -> Int {
    var codes = codes
    for a in codes {
        print(a, "", separator: ",", terminator: "")
    }
    print()
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
    return codes.first!
}

var number = 0
var i = 0
var j = 0

// Reset input
outerLoop: while i != 99 {
    while j != 99 {
        var testInput = inputs
        
        testInput[1] = i
        testInput[2] = j
        
        number = Intcode(for: testInput)
        print("HERE")
        print(i,j, number)
        print("HERE")
        if number == 19690720 {
            print(i,j)
            break outerLoop
        }
        j += 1
    }
    i += 1
    j = 0
}





