#!/usr/bin/env xcrun swift

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

func fft(_ input: inout [Int]) -> [Int] {
    var newPhase = Array(repeating: 0, count: input.count)
    var pattern = basePattern
//    print("----",pattern)
    var x = 2
    for (i, _) in input.enumerated() {
        var newNumber = 0
//        print("---------", i)
//        pattern.shiftInPlace(withDistance: i)
        
        for number in i...input.count-1 {
//            pattern.shiftInPlace()
//            print(input, number, pattern)
//            print(number, pattern.first!, number * pattern.first!)
            newNumber += input[number] * pattern.first!
        }
//        print(newNumber)
        let digit = newNumber.digits.last!
        newPhase[i] = digit

        pattern = basePattern
//        pattern = double(array: pattern, by: x)
        x += 1
    }
    let phase = newPhase.compactMap{ String($0) }.joined()

    print(phase.prefix(8))
    input = newPhase
    return newPhase
}

func phases(number: Int, with input: [Int]) -> [Int] {
    var input = input
    for _ in 0..<number {
        fft(&input)
    }
    return input
}

var number = "59782619540402316074783022180346847593683757122943307667976220344797950034514416918778776585040527955353805734321825495534399127207245390950629733658814914072657145711801385002282630494752854444244301169223921275844497892361271504096167480707096198155369207586705067956112600088460634830206233130995298022405587358756907593027694240400890003211841796487770173357003673931768403098808243977129249867076581200289745279553289300165042557391962340424462139799923966162395369050372874851854914571896058891964384077773019120993386024960845623120768409036628948085303152029722788889436708810209513982988162590896085150414396795104755977641352501522955134675"
// for i in 0...10000 {
//   number += number
// }
 var n = number.compactMap{ Int(String($0)) }
 var final = phases(number: 100, with: n)

//var n = "12345678".compactMap{ Int(String($0)) }
//phases(number: 2, with: n)
