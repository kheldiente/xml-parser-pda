import Foundation

let sampleInput1 = """
<?xml version="1.0" encoding="UTF-8" ?>
<XMLFile>
    <Colors>
        <Color1>White</Color1>
        <Color2>Blue</Color2>
        <Color3>Black</Color3>
        <Color4 Special="Light\tOpaque">Green</Color4>
        <Color5>Red</Color5>
    </Colors>
    <Fruits>
        <Fruits1>Apple</Fruits1>
        <Fruits2>Pineapple</Fruits2>
        <Fruits3>Grapes</Fruits3>
        <Fruits4>Melon</Fruits4>
    </Fruits>
</XMLFile>
"""
let sampleInput2 = """
<?xml version="1.0" encoding="UTF-8" ?>
"""
let sampleInput3 = """
<amulet size="medium">
    <gem>sapphire</gem>
</amulet>
"""
let sampleInput4 = """
<cim-Substation rdf:ID="_28159176D77E2467">
    <cim-Naming.name>LEGAZZI</cim-Naming.name>
    <cim-Substation.MemberOf_SubControlArea rdf:resource="#_55D3DE" />
</cim-Substation>
"""
let sampleInput5 = """
<ingredients>Big A** Spoon</ingredients>
"""
let sampleInput6 = """
<magnitude>-5.53</magnitude>
"""

extension String.Element {
    var isXmlSymbol: Bool {
        return CharacterSet(charactersIn: "\(self)").isSubset(of: CharacterSet(charactersIn: "</>?="))
    }

    var isQuotes: Bool {
        return CharacterSet(charactersIn: "\(self)").isSubset(of: CharacterSet(charactersIn: "\"\""))
    }

    var isValueSymbol: Bool {
        return CharacterSet(charactersIn: "\(self)").isSubset(of: CharacterSet(charactersIn: "_?*,#"))
    }
}


func getXmlTokens(xmlString: String) -> [String] {
    var tokens: [String] = []
    let formattedXmlString = xmlString.components(separatedBy: CharacterSet.newlines)
    for lineString in formattedXmlString {
        let formattedLineString = lineString.trimmingCharacters(in: CharacterSet.whitespaces)
        var tempString = ""
        
        for (index, character) in formattedLineString.enumerated() {
            let isXmlSymbol = character.isXmlSymbol
            let isQuotes = character.isQuotes
            let isValueSymbol = character.isValueSymbol
            let isLetter = character.isLetter
            let isNumber = character.isNumber
            
            if !isLetter && !isQuotes && !isNumber && !isValueSymbol {
                if !tempString.isEmpty {
                    tokens.append(tempString)
                    tempString = ""
                }
            }
            
            if isXmlSymbol {
                tokens.append(String(character))
            } else {
                if isLetter || isQuotes || isNumber || isValueSymbol {
                    tempString += String(character)
                }
            }
        }
    }
    print("getXmlTokens: \(tokens)")
    return tokens
}

func isXmlFileValid(xmlString: String) {
    var stack = Array<String>(repeating: "", count: 100)
    var top = -1
    var tokens = getXmlTokens(xmlString: xmlString)
    var isValid = false
    
    top += 1
    stack[top] = "#"
    
    for token in tokens {
        if token == "<" || token == ">" || token == "/" || token == "?" {
            top += 1
            stack[top] = token
        } else {
            if stack[top] == "<" || stack[top] == "/" {
                top += 1
                stack[top] = token
            }
        }
    }
    
    print("top: \(top)")
    var start = -1
    while start < top {
        start += 1
        print(stack[start], terminator: "")
    }
    
    if isValid {
        print("YES")
    } else {
        print("NO")
    }
}

isXmlFileValid(xmlString: sampleInput1)

