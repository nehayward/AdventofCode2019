import Foundation

// MARK: Day 14 - Space Stoichiometry

// Figure out Ore Fuel needed for one unit of fuel

struct Reaction: Hashable {
    var inputs: [Chemical]
    var output: Chemical
}

struct Chemical: Hashable {
    var quantity: Int = 1
    var type: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(type)
    }
}

extension Chemical: Equatable {
    static func == (lhs: Chemical, rhs: Chemical) -> Bool {
        return lhs.type == rhs.type
    }
}

extension Chemical: CustomStringConvertible {
    var description: String {
        return "\(quantity) \(type)"
    }
}

func createReaction(from input: String) -> Reaction {
    let reaction = input.components(separatedBy: CharacterSet(charactersIn: "=>"))
    let inputs = reaction.first!.split(separator: ",").map{ String($0) }
    
    let chemicalInputs = inputs.map { createChemical(from: $0) }
    let output = createChemical(from: reaction.last!)
    
    return Reaction(inputs: chemicalInputs, output: output)
}

func createChemical(from input: String) -> Chemical {
    let chemical = input.split(separator: " ").map{ String($0) }
    let quantity = Int(chemical[0])!
    let type = chemical[1]
    
    return Chemical(quantity: quantity, type: type)
}


// 4a + 9b + 11c = 1 Fuel
//18ore + 24ore + 21Ore
//36 + 72 + 84

var testInput = """
9 ORE => 2 A
8 ORE => 3 B
7 ORE => 5 C
3 A, 4 B => 1 AB
5 B, 7 C => 1 BC
4 C, 1 A => 1 CA
2 AB, 3 BC, 4 CA => 1 FUEL
"""

var testInput2 = """
157 ORE => 5 NZVS
165 ORE => 6 DCFZ
44 XJWVT, 5 KHKGT, 1 QDVJ, 29 NZVS, 9 GPVTF, 48 HKGWZ => 1 FUEL
12 HKGWZ, 1 GPVTF, 8 PSHF => 9 QDVJ
179 ORE => 7 PSHF
177 ORE => 5 HKGWZ
7 DCFZ, 7 PSHF => 2 XJWVT
165 ORE => 2 GPVTF
3 DCFZ, 7 NZVS, 5 HKGWZ, 10 PSHF => 8 KHKGT
"""

var testInput3 = """
2 VPVL, 7 FWMGM, 2 CXFTF, 11 MNCFX => 1 STKFG
17 NVRVD, 3 JNWZP => 8 VPVL
53 STKFG, 6 MNCFX, 46 VJHF, 81 HVMC, 68 CXFTF, 25 GNMV => 1 FUEL
22 VJHF, 37 MNCFX => 5 FWMGM
139 ORE => 4 NVRVD
144 ORE => 7 JNWZP
5 MNCFX, 7 RFSQX, 2 FWMGM, 2 VPVL, 19 CXFTF => 3 HVMC
5 VJHF, 7 MNCFX, 9 VPVL, 37 CXFTF => 6 GNMV
145 ORE => 6 MNCFX
1 NVRVD => 8 CXFTF
1 VJHF, 6 MNCFX => 4 RFSQX
176 ORE => 6 VJHF
"""

var reactionEquations = testInput3.split { $0.isNewline }
var reactions = reactionEquations.map { createReaction(from: String($0)) }

var dict = [Chemical: [Chemical]]()
for reaction in reactions {
    dict[reaction.output] = reaction.inputs
}

let ORE = Chemical(type: "ORE")
var ores = reactions.filter{ $0.inputs.first == ORE }

var OreDict = [Chemical: (Chemical,Chemical)]()
for ore in ores {
    OreDict[ore.output] = (ore.inputs.first!, ore.output)
}
//print("ORES--------",OreDict)
//print(dict)

//print(dict[Chemical(type: "FUEL")])

//func adfa(_ a: [Chemical], _ dict: [Chemical: [Chemical]]) -> [Chemical] {
//    var array = [Chemical]()
//    for b in a {
//
//    }
//    return array
//}
var sum = 0.0
var totals = [String:Int]()

func convertWithQuantity(chemical: Chemical, amount: Int) -> Int {
    // Get Ore
    let (chemicalOre, chemicalAmount) = OreDict[chemical]!
//    print("CONVERSATION-------", chemical, chemicalOre, amount)
//    print(ceil(Double(amount)/Double(chemicalAmount.quantity)))
//    print(Double(chemicalOre.quantity) * ceil(Double(amount)/Double(chemicalAmount.quantity)))
    
    print(chemicalOre, amount, chemicalAmount)
    
    let ores = Double(chemicalOre.quantity) * ceil(Double(amount)/Double(chemicalAmount.quantity))
    
    return Int(ores)
}

func neededMaterial(for chemical: Chemical,  from dict: [Chemical: [Chemical]], multiply: Int) {
    for input in dict[chemical] ?? [] {
        if let a = OreDict[input] {
            let key = dict.keys.first(where: { $0 == chemical })
            print(ceil(Double(multiply)/Double(key!.quantity)))
            print("----", a, chemical, input, multiply, key)
            var z = ceil(Double(key!.quantity)/Double(chemical.quantity))
            var multiplier = ceil(Double(multiply)/Double(key!.quantity))
//            print("----", chemical)
//            print(input.type, input.quantity * multiply/chemical.quantity)
//            print("AMOUNT", input.quantity *  multiply/chemical.quantity)
            let amount = Int(Double(input.quantity) * multiplier)
            if let total = totals[input.type] {
                totals[input.type] = total + amount
            } else {
                totals[input.type] = amount
            }
        }
        else {
            print(chemical)
            print(input.type, input.quantity * multiply/chemical.quantity)
            let amountNeeded = Int(ceil(Double(input.quantity)/Double(chemical.quantity)))
            neededMaterial(for: input, from: dict, multiply: amountNeeded)
        }
    }
}
//print(dict)
//neededMaterial(for: Chemical(quantity: 1, type: "FUEL"), from: dict, multiply: 1)
////print(totals)
//
//for total in totals {
//    convertWithQuantity(chemical: Chemical(type: total.key), amount: total.value)
//}
//
//var total = totals.map { convertWithQuantity(chemical: Chemical(type: $0.key), amount: $0.value) }.reduce(0, +)
//
//print(total)
var reserves = [Chemical: Int]()
func printThisEq(for chemical: Chemical, from dict: [Chemical: [Chemical]], multi: Double = 1) -> String {
    var readableEq  = ""
    var eq = ""
    let inputs = dict[chemical] ?? []
    for (i, input) in inputs.enumerated() {
        let spacer = inputs.count - 1 == i ? "" : " + "
        if let a = OreDict[input] {
//            string += "(\(input)) + "
            eq += "(\(input))" + spacer
            print(input.type, multi, input.quantity)
            
            var needed = Int(Double(input.quantity) * multi)
            let remainder = input.quantity % Int(multi)
            print("-----------",remainder)
            
            
            if let reserve = reserves[input] {
                needed = reserve - needed
                if needed < 0 {
                    reserves[input]! = 0
                    needed.negate()
                } else {
                    reserves[input]! = needed
                }
            } else {
                reserves[input] = remainder
            }
            
            if let total = totals[input.type] {
                totals[input.type] = total + needed
            } else {
                totals[input.type] = needed
            }
        }
        else {
            let key = dict.keys.first(where: { $0 == input })
//            string += "\(input)/\(key!.quantity)(\(printThisEq(for: input, from: dict))/) +
            var needed = Int(ceil(Double(input.quantity)/Double(key!.quantity)))
            let remainder = input.quantity % key!.quantity
            
            if let reserve = reserves[input] {
                print("-------RESERVES", reserve, input)
                print("--------Needed", needed)
                needed = reserve - needed
                if needed < 0 {
                    reserves[input]! = 0
                    needed.negate()
                    eq += "\(needed)(\(printThisEq(for: input, from: dict, multi: Double(needed) * multi)))" + spacer
                } else {
                    reserves[input]! = needed
                }
            } else {
                reserves[input] = remainder
                eq += "\(needed)(\(printThisEq(for: input, from: dict, multi: Double(needed) * multi)))" + spacer
            }
            print(needed)
            print("REMAINDERRRR----", remainder, input)
        }
    }
//    print("\(chemical) (\(string))")
//    print("\(eq)")

    return eq
}

var a = printThisEq(for: Chemical(type: "FUEL"), from: dict)
print("1 Fuel = \(a)")

//6004/6

var total = totals.map { convertWithQuantity(chemical: Chemical(type: $0.key), amount: $0.value) }.reduce(0, +)

print(total)
