import Foundation

let file = Bundle.main.url(forResource: "Input", withExtension: "txt")
let input = try! String(contentsOf: file!, encoding: .utf8)
let pixels = input.compactMap{ Int(String($0)) }

func decodeLayers(from input: [Int], with width: Int, and height: Int) -> [[Int]] {
    let sizeOfLayer = width * height
    var layers = [[Int]]()
    
    for pixel in stride(from: 0, to: input.count, by: sizeOfLayer) {
        var layer = [Int]()
        for i in 0..<sizeOfLayer {
            layer.append(input[pixel + i])
        }
        layers.append(layer)
    }
    
    return layers
}


//The image you received is 25 pixels wide and 6 pixels tall.
//
//To make sure the image wasn't corrupted during transmission, the Elves would like you to find the layer that contains the fewest 0 digits. On that layer, what is the number of 1 digits multiplied by the number of 2 digits?

let testLayers = decodeLayers(from: [1,2,3,4,5,6,7,8,9,0,1,2], with: 3, and: 2)

func findLayer(withFewest digits: Int, from layers: [[Int]]) -> [Int] {
    var fewest = Int.max
    var index = -1
    
    for (i, layer) in layers.enumerated() {
        let zeroCount = layer.filter { $0 == digits}.count
        if zeroCount == 0 {
            continue
        }
        if zeroCount < fewest {
            index = i
            fewest = zeroCount
        }
    }
    
    return layers[index]
}

let layerWithFewest0 = findLayer(withFewest: 0, from: testLayers)

func countFor(digit1: Int, digit2: Int, for layer: [Int]) -> (Int, Int) {
    
    let count1 = layer.filter { $0 == digit1 }.count
    let count2 = layer.filter { $0 == digit2 }.count
    return (count1, count2)
}




let imageTestLayers = decodeLayers(from: [0,2,2,2,1,1,2,2,2,2,1,2,0,0,0,0], with: 2, and: 2)



// 0 black, 1 white, 2 transparent
func produceImage(from layers: [[Int]]) -> [Int] {
    var image = Array.init(repeating: -1, count: layers.first!.count)
    for layer in layers.reversed() {
        for (i,pixel) in layer.enumerated() {
            switch pixel {
            case 0:
                image[i] = 0
            case 1:
                image[i] = 1
            case 2:
                break
            default:
                break
            }
        }
    }
    
    return image
}

let image = produceImage(from: imageTestLayers)

func print(image: [Int], width: Int){
    for l in stride(from: 0, to: image.count, by: width) {
        var line = ""
        for pixel in 0..<width {
            
            switch image[l + pixel] {
            case 0:
                line += " "
            case 1:
                line += "*"
            case 2:
                line += " "
            default:
                break
            }
        }
        print(line)
    }
}


let layers = decodeLayers(from: pixels, with: 25, and: 6)

let image2 = produceImage(from: layers)
print(image: image2, width: 25)

