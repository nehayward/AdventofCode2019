// MARK: --- Day 16: Flawed Frequency Transmission ---

extension Array {
    func shift(withDistance distance: Int = 1) -> Array<Element> {
        let offsetIndex = distance >= 0 ?
            self.index(startIndex, offsetBy: distance, limitedBy: endIndex) :
            self.index(endIndex, offsetBy: distance, limitedBy: startIndex)
        
        guard let index = offsetIndex else { return self }
        return Array(self[index ..< endIndex] + self[startIndex ..< index])
    }
    
    mutating func shiftInPlace(withDistance distance: Int = 1) {
        self = shift(withDistance: distance)
    }
    
}
extension StringProtocol  {
    var digits: [Int] { compactMap{ $0.wholeNumberValue } }
}
extension LosslessStringConvertible {
    var string: String { .init(self) }
}

extension Numeric where Self: LosslessStringConvertible {
    var digits: [Int] { string.digits }
}


func double(array: [Int], by number: Int = 1) -> [Int] {
    
    var doubled = Array(repeating: 0, count: array.count * number)
    
    var outerI = 0
    for a in stride(from: 0, through: doubled.count-number, by: number) {
        for i in 0..<number {
            doubled[a + i] = array[outerI]
        }
        outerI += 1
    }
    //        let offsetIndex = distance >= 0 ?
    //            self.index(startIndex, offsetBy: distance, limitedBy: endIndex) :
    //            self.index(endIndex, offsetBy: distance, limitedBy: startIndex)
    
    //        guard let index = offsetIndex else { return self }
    //        return doubled
    //        return Array(self[index ..< endIndex] + self[startIndex ..< index])
    return doubled
}





var basePattern = [0, 1, 0, -1]

var testInput = [1, 2, 3, 4, 5, 6, 7, 8]

var new = double(array: basePattern, by: 3)
print(new)

func fft(_ input: inout [Int]) -> [Int] {
    var newPhase = Array(repeating: 0, count: input.count)
    var pattern = basePattern
//    print("----",pattern)
    var x = 2
    for (i, _) in input.enumerated() {
        var newNumber = 0
        for number in input {
            pattern.shiftInPlace()
//            print(number, pattern.first!, number * pattern.first!)
            newNumber += number * pattern.first!
        }
//        print(newNumber)
        let digit = newNumber.digits.last!
        newPhase[i] = digit

        pattern = basePattern
        pattern = double(array: pattern, by: x)
        x += 1
    }
    let phase = newPhase.compactMap{ String($0) }.joined()
    
    print(phase.prefix(8))
    input = newPhase
    return newPhase
}

func phases(number: Int, with input: [Int]) {
    var input = input
    for _ in 0..<number {
        fft(&input)
    }
}

//var number = "80871224585914546619083218645595"
//var n = number.compactMap{ Int(String($0)) }
//phases(number: 100, with: n)

var a = [1,2,3]
for b in a.reversed() {
    print(b)
}
