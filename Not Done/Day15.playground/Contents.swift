
enum Movement: Int {
    case north = 1
    case south
    case west
    case east
}

enum Status: Int {
    case hitWall = 0
    case succeeded = 1
    case oxygenSystem = 2
}

struct Position: Hashable {
    var x = 0, y = 0
}

var board = Array(repeating: Array(repeating: "", count: 100), count: 100)
var current = Position(x: 50, y: 50)
var finish = Position(x: 50, y: 50)
var traveled = [Position:String]()


// MARK: Find Fewest Movements

func nextPosition(current: Position) -> (Position, Movement)? {
    let move = Movement(rawValue: Int.random(in: 1...4))!
    
    switch move {
    case .north:
        let tryMove = Position(x: current.x, y: current.y + 1)
        
        if traveled[tryMove] == nil {
            return (tryMove, .north)
        }
    case .south:
        let tryMove = Position(x: current.x, y: current.y - 1)
        if traveled[tryMove] == nil {
            return (tryMove, .west)
        }
    case .west:
        let tryMove = Position(x: current.x - 1, y: current.y)
        if traveled[tryMove] == nil {
            return (tryMove, .west)
        }
    case .east:
        let tryMove = Position(x: current.x + 1, y: current.y)
        if traveled[tryMove] == nil {
            return (tryMove, .east)
        }
    }
    
    return nil
}

func nextRepeatMove(current: Position) -> (Position?, Movement?) {
    var flag = false
    while flag {
        let move = Movement(rawValue: Int.random(in: 1...4))!
        print(move)
        switch move {
        case .north:
            let tryMove = Position(x: current.x, y: current.y + 1)
            if let repeated = traveled[tryMove], repeated != "#" {
                fallthrough
            } else {
                return (tryMove, move)
            }
        case .south:
            let tryMove = Position(x: current.x, y: current.y - 1)
            if let repeated = traveled[tryMove], repeated == "#" {
                fallthrough
            } else {
                return (tryMove, move)
            }
        case .west:
            let tryMove = Position(x: current.x - 1, y: current.y)
            if let repeated = traveled[tryMove], repeated == "#" {
                fallthrough
            } else {
                return (tryMove, move)
            }
            
        case .east:
            let tryMove = Position(x: current.x + 1, y: current.y)
            if let repeated = traveled[tryMove], repeated == "#" {
                // MARK: Try Again
                fallthrough
            } else {
                return (tryMove, move)
            }
        default:
            // MARK: Try Again
            print("REPEAT")
            flag = false
        }
    }
    
    //    var tryMove = Position(x: current.x, y: current.y + 1)
    //
    //    if let repeated = traveled[tryMove], repeated != "#" {
    //        return (tryMove, .north)
    //    }
    //
    //    tryMove = Position(x: current.x, y: current.y - 1)
    //
    //    if let repeated = traveled[tryMove], repeated != "#" {
    //        return (tryMove, .south)
    //    }
    //
    //    tryMove = Position(x: current.x - 1, y: current.y)
    //
    //    if let repeated = traveled[tryMove], repeated != "#" {
    //        return (tryMove, .west)
    //    }
    //
    //    tryMove = Position(x: current.x + 1, y: current.y)
    //
    //    if let repeated = traveled[tryMove], repeated != "#" {
    //        return (tryMove, .east)
    //    }
    //
    return (nil, nil)
}

traveled[current] = "."

let tryMove = Position(x: current.x, y: current.y - 1)
traveled[tryMove] = "#"
if let repeated = traveled[tryMove], repeated == "#" || repeated == "." {
    print(repeated)
} else {
    print(traveled[tryMove])
}

print(Movement.south.rawValue)
print(Movement.east.rawValue)
print(Movement.north.rawValue)
print(Movement.west.rawValue)
// MARK: Find Fewest Movements

//Intcode(for: &inputCodes, getInput: {
//    var nextMove: Movement = .north
//
//    if let move = nextPosition(current: current) {
//        tryMovement = move.0
//        nextMove = move.1
//    } else {
//        (tryMovement, nextMove) = nextRepeatMove(current: current) as! (Position, Movement)
//    }
//
//    return nextMove.rawValue
//
//},output: { output, numberOfOutputs in
//    let status = Status(rawValue: output)!
//    print(status, tryMovement)

//    switch status {
//    case .hitWall:
//        traveled[tryMovement] = "#"
//        board[tryMovement.y][tryMovement.x] = "#"
//    case .succeeded:
//        traveled[tryMovement] = "."
//        current = tryMovement
//        board[current.y][current.x] = "."
//        board[tryMovement.y][tryMovement.x] = "D"
//    case .oxygenSystem:
//        print("YAY!!!")
//        print("Oxygen Here", tryMovement)
//    }
//        board.forEach {
//            print($0.joined())
//        }
//})

