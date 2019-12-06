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

//HEY




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

extension Coordinate: CustomStringConvertible {
    var description: String {
        return "(\(x), \(y))"
    }
}



func buildSet(wireMovement: [String]) -> Set<Coordinate> {
    var allCoordinates = Set<Coordinate>()
    
    var currentPosition = Coordinate(x: 0, y: 0)
    //    allCoordinates.insert(currentPosition)
    
    for move in wireMovement {
        guard let movement = Movement(rawValue: move.first!),
            let distance = Int(String(move.dropFirst())) else { fatalError() }
        
        print(movement, distance)
        switch movement {
        case .right:
            for _ in 0...distance{
                currentPosition.x += 1
                print(currentPosition)
                allCoordinates.insert(currentPosition)
            }
        case .up:
            for _ in 0...distance{
                currentPosition.y += 1
                allCoordinates.insert(currentPosition)
            }
        case .left:
            for _ in 0...distance{
                currentPosition.x -= 1
                allCoordinates.insert(currentPosition)
            }
        case .down:
            for _ in 0...distance{
                currentPosition.y -= 1
                allCoordinates.insert(currentPosition)
            }
        }
    }
    
    return allCoordinates
}

enum Movement: Character {
    case right = "R"
    case up = "U"
    case left = "L"
    case down = "D"
}


let set1 = buildSet(wireMovement: wire1Movement)
print(set1)

let set2 = buildSet(wireMovement: wire2Movement)


let intersections = set1.intersection(set2)

print(intersections)

func findCloset(for intersections: Set<Coordinate>){
    var smallest = Int.max
    
    for intersection in intersections {
        let distance = abs(intersection.x) + abs(intersection.y)
        print(distance)
        smallest = min(distance, smallest)
    }
    
    print("Smallest: ", smallest)
}

//findCloset(for: intersections)

// Solution
//let wireMovements1 = buildSet(wireMovement: ["R98","U47","R26","D63","R33","U87","L62","D20","R33","U53","R51"])
//let wireMovements2 = buildSet(wireMovement: ["U98","R91","D20","R16","D67","R40","U7","R15","U6","R7"])
let wireMovements1 = buildSet(wireMovement: wire1)
let wireMovements2 = buildSet(wireMovement: wire2)

let wiresIntersections = wireMovements1.intersection(wireMovements2)
print()
print(wireMovements1)
//print(wiresIntersections)
findCloset(for: wiresIntersections)
