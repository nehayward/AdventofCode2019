import Foundation

let inputFileURL = Bundle.main.url(forResource: "Input", withExtension: "txt")!
let inputs = try String(contentsOf: inputFileURL).split { $0.isNewline }.compactMap { String($0) }

let wire1 = inputs[0].split(separator: ",").compactMap{ String($0) }
let wire2 = inputs[1].split(separator: ",").compactMap{ String($0) }



let wire1Movement = ["R8","U5","L5","D3"]
let wire2Movement = ["U7","R6","D4","L4"]

// 0,0 ––––– 0,0
// 8,0 ––––– 0,7
// 8,5 ––––– 6,7
// 3,5 ––––– 6,3
// 8,5 ––––– 6,7






//func buildCircuit(with wire1: [String], wire2: [String]) {
//    let (x,y) = (0,0)
//    let (x1,y1) = (0,0)
//
//    for i in 0...wire1.count {
//        let w = wire1[i]
//        let z = wire2[i]
//    }
//}



struct Coordinate: Hashable {
    var x,y: Int
}

extension Coordinate: Equatable {
    static func == (lhs: Coordinate, rhs: Coordinate) -> Bool {
        return lhs.x == rhs.x &&
            lhs.y == rhs.y
    }
}

extension Coordinate: CustomStringConvertible {
    var description: String {
        return "(\(x), \(y))"
    }
}



func buildSet(wireMovement: [String]) -> (Set<Coordinate>, [Coordinate:Int]) {
    var allCoordinates = Set<Coordinate>()
    
    var currentPosition = Coordinate(x: 0, y: 0)
    var numberOfSteps = [Coordinate:Int]()
    var totalSteps = 0
    
    for move in wireMovement {
        guard let movement = Movement(rawValue: move.first!),
            let distance = Int(String(move.dropFirst())) else { fatalError() }
        
        print(movement, distance)
        switch movement {
        case .right:
            for _ in 0..<distance{
                totalSteps += 1
                currentPosition.x += 1
                numberOfSteps[currentPosition] = totalSteps
//                print("Position: ", currentPosition, "Total Steps: ", totalSteps)
                allCoordinates.insert(currentPosition)
            }
        case .up:
            for _ in 0..<distance{
                totalSteps += 1
                currentPosition.y += 1
                numberOfSteps[currentPosition] = totalSteps
//                print("Position: ", currentPosition, "Total Steps: ", totalSteps)
                allCoordinates.insert(currentPosition)
            }
        case .left:
            for _ in 0..<distance{
                totalSteps += 1
                currentPosition.x -= 1
                numberOfSteps[currentPosition] = totalSteps
// print("Position: ", currentPosition, "Total Steps: ", totalSteps)
                allCoordinates.insert(currentPosition)
            }
        case .down:
            for _ in 0..<distance{
                totalSteps += 1
                currentPosition.y -= 1
                numberOfSteps[currentPosition] = totalSteps
// print("Position: ", currentPosition, "Total Steps: ", totalSteps)
                allCoordinates.insert(currentPosition)
            }
        }
    }
    
    return (allCoordinates, numberOfSteps)
}

enum Movement: Character {
    case right = "R"
    case up = "U"
    case left = "L"
    case down = "D"
}


//R75,D30,R83,U83,L12,D49,R71,U7,L72
//U62,R66,U55,R34,D71,R55,D58,R83

//let (set1, steps1) = buildSet(wireMovement:
//    ["R75","D30","R83","U83","L12","D49","R71","U7","L72"])
//let (set2, steps2) = buildSet(wireMovement: ["U62","R66","U55","R34","D71","R55","D58","R83"])

func findTotalSteps(for set1: Set<Coordinate>, set2: Set<Coordinate>, steps1: [Coordinate:Int], steps2:[Coordinate:Int]){
    let intersections  = set1.intersection(set2)
    
    var fewestSteps = Int.max
    for intersection in intersections {
        print(steps1[intersection])
        print(steps2[intersection])
        
        fewestSteps = min(fewestSteps, steps1[intersection]! + steps2[intersection]!)
    }
    
    print("Fewest Steps: ", fewestSteps)
}

//findTotalSteps(for: set1, set2: set2, steps1: steps1, steps2: steps2)


//let (se1, _) = buildSet(wireMovement: wire1Movement)
//let (se2, _) = buildSet(wireMovement: wire2Movement)
//
//let a = se1.intersection(se2)
//print(a)

// Solution

let (set1, steps1) = buildSet(wireMovement: wire1)
let (set2, steps2) = buildSet(wireMovement: wire2)

//let (set1, steps1) = buildSet(wireMovement: ["R98","U47","R26","D63","R33","U87","L62","D20","R33","U53","R51"])
//let (set2, steps2) = buildSet(wireMovement: ["U98","R91","D20","R16","D67","R40","U7","R15","U6","R7"])
findTotalSteps(for: set1, set2: set2, steps1: steps1, steps2: steps2)
