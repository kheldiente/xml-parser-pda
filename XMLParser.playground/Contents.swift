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
<amulet size='medium' website="http://www.w3.org/2001/XMLSchema-instance" >
    < gem   >   sapphire blue  <  /    gem    >
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
let sampleInput7 = """
<WindowElement xmins="http://windiws.lbl.gov" xsi="http://www.w3.org/2001/XMLSchema-instance" schemaLocation="http://windows.lbl.gov BSDG-v1.4xsd">
<Optical>
<Layer>
    <Material>
        <Name>Perfect Diffuser</Name>
        <Manufacturer>ACME Surfaces</Manufacturer>
        <Width unit="Meter">1.000</Width>
        <Height unit="Meter">1.000</Height>
    </Material>
    <DataDefinition>
        <IncidentDataStructure>TensorTree3</IncidentDataStructure>
    </DataDefinition>
    <WavelengthData>
        <LayerNumber>System</LayerNumber>
        <Wavelength unit="Integral">Visible</Wavelength>
        <SourceSpectrum>CIE Illuminant D65 1nm.ssp</SourceSpectrum>
        <DetectorSpectrum>ASTM E308 1931 Y.dsp</DetectorSpectrum>
        <WavelengthDataBlock>
            <WavelengthDataDirection>Reflection Back</WavelengthDataDirection>
            <AngleBasis>LBNL/Shirley-Chiu</AngleBasis>
            <ScatteringDataType>BRDF</ScatteringDataType>
            <ScatteringData>[ 0.318309886 ]</ScatteringData>
        </WavelengthDataBlock>
    </WavelengthData>
</Layer>
</Optical>
</WindowElement>
"""
let sampleInput8 = """
<amulet>
    <gem>sapphire</gem>
</amulet>
<DataDefinition>
    <IncidentDataStructure>TensorTree3</IncidentDataStructure>
</DataDefinition>
"""

class Token {
    var value: String = ""
    var type: TokenType = .empty
    
    init(value: String, type: TokenType) {
        self.value = value
        self.type = type
    }
}

enum TokenType: String {
    case undefined
    case lessThanSymbol
    case greaterThanSymbol
    case tag
    case slash
    case value
    case attrib
    case attribValue
    case questionMark
    case oper
    case empty
}

extension String.Element {
    var isXmlSymbol: Bool {
        return CharacterSet(charactersIn: "\(self)").isSubset(of: CharacterSet(charactersIn: "</>?="))
    }

    var isQuotes: Bool {
        return CharacterSet(charactersIn: "\(self)").isSubset(of: CharacterSet(charactersIn: "\"\"''"))
    }

    var isValueSymbol: Bool {
        return CharacterSet(charactersIn: "\(self)").isSubset(of: CharacterSet(charactersIn: ".:-/_?*,#"))
    }
    
    var isAttrib: Bool {
        return self.isLetter || self.isNumber
    }
    
    var isTag: Bool {
        return self.isLetter || self.isNumber
    }
    
}


func getXmlTokens(xmlString: String) -> [Token] {
    var tokens: [Token] = []
    let formattedXmlString = xmlString.components(separatedBy: CharacterSet.newlines)
    for lineString in formattedXmlString {
        let formattedLineString = lineString.trimmingCharacters(in: CharacterSet.whitespaces)
        var tempString = ""
        
        for (index, character) in formattedLineString.enumerated() {
            let isXmlSymbol = character.isXmlSymbol
            let isQuotes = character.isQuotes
            let isAttrib = character.isAttrib
            let isTag = character.isTag
            let isValueSymbol = character.isValueSymbol
            let isWhiteSpace = character.isWhitespace
            var type: TokenType = .undefined
            
            if isXmlSymbol || isWhiteSpace {
                if !tempString.isEmpty {
                    let lastTokenType = tokens.last?.type ?? .undefined
                    
                    switch lastTokenType {
                    case .lessThanSymbol:
                        type = .tag
                    case .greaterThanSymbol:
                        type = .value
                    case .tag, .attribValue:
                        type = .attrib
                    case .oper:
                        type = .attribValue
                    case .slash:
                        type = .tag
                    case .value:
                        type = .value
                    default:
                        type = .undefined
                    }
                    
                    if type == .attribValue {
                        let inQuotes = (tempString.first == "\"" && tempString.last == "\"") || (tempString.first == "'" && tempString.last == "'")
                        if inQuotes { // Attrib value should be in quotes
                            tokens.append(Token(value: tempString, type: type))
                            tempString = ""
                        }
                    } else if type == .value {
                        if lastTokenType == .greaterThanSymbol {
                            if isWhiteSpace {
                                tempString += String(character)
                            } else {
                                tokens.append(Token(value: tempString, type: type))
                                tempString = ""
                            }
                        }
                    } else {
                        let trimmedValue = tempString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                        if !trimmedValue.isEmpty {
                            tokens.append(Token(value: trimmedValue, type: type))
                            tempString = ""
                        }
                    }
                }
            }
            
            if isXmlSymbol {
                let lastTokenType = tokens.last?.type ?? .undefined
                // print("lastToken: \(lastTokenType), character: \(character), tempString: \(tempString)")
                if lastTokenType != .oper {
                    if character == "<" {
                        type = .lessThanSymbol
                    } else if character == ">" {
                        type = .greaterThanSymbol
                    } else if character == "/" {
                        type = .slash
                    } else if character == "?" {
                        type = .questionMark
                    } else if character == "=" {
                        type = .oper
                    }
                    tokens.append(Token(value: String(character), type: type))
                } else {
                    tempString += String(character)
                    
                }
            } else {
                if isTag || isAttrib || isQuotes || isValueSymbol || isWhiteSpace {
                    // print("character: \(character)")
                    tempString += String(character)
                }
            }
        }
    }
    return tokens
}

func isXmlFileValid(xmlString: String) {
    var tokens = getXmlTokens(xmlString: xmlString)
    var stack = Array<Token>(repeating: Token(value: "", type: .undefined), count: 100000)
    var tempToken = Token(value: "", type: .undefined)
    var top = -1
    
    top += 1
    stack[top] = Token(value: "", type: .empty)
    
    for token in tokens {
        print("token: \(token.value) ---- \(token.type)")
        // print("stack: \(stack[0...top].map { $0.value }), top: \(top)")
        
        if stack[top].type == .lessThanSymbol {
            if token.type == .tag || token.type == .slash {
                stack[top] = token
            }
        } else if stack[top].type == .tag {
            if token.type == .greaterThanSymbol {
                tempToken = stack[top]
                
                stack[top] = Token(value: "", type: .undefined)
                top -= 1
                
                if stack[top].value == tempToken.value {
                    stack[top] = Token(value: "", type: .undefined)
                    top -= 1
                } else {
                    // push back
                    top += 1
                    stack[top] = tempToken
                    
                    top += 1
                    stack[top] = token
                }
            } else if token.type == .attrib {
                top += 1
                stack[top] = token
            }
        } else if stack[top].type == .slash {
            if token.type == .tag {
                stack[top] = Token(value: "", type: .undefined)
                top -= 1
                
                if stack[top].value == token.value {
                    stack[top] = Token(value: "", type: .undefined)
                    top -= 1
                } else {
                    top += 1
                    stack[top] = token
                }
            }
        } else if stack[top].type == .greaterThanSymbol {
            if token.type == .lessThanSymbol {
                stack[top] = token
            }
        } else if stack[top].type == .attrib {
            if token.type == .oper {
                stack[top] = token
            }
        } else if stack[top].type == .oper {
            if token.type == .attribValue {
                stack[top] = Token(value: "", type: .undefined)
                top -= 1
            }
        } else {
            if token.type == .greaterThanSymbol {
                if stack[top].type != .empty {
                    top += 1
                    stack[top] = token
                }
            } else {
                top += 1
                stack[top] = token
            }
        }
    }
    
    print("stack: \(stack[0...top].map { $0.value }), top: \(top)")
    if stack[top].type == .empty {
        stack[top] = Token(value: "", type: .undefined)
        top -= 1
    }
    
    print("top: \(top)")
    
    if top == -1 {
        print("YES")
    } else {
        print("NO")
    }
}

isXmlFileValid(xmlString: sampleInput3)

