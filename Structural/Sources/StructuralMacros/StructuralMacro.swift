import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

struct StructuralError: Error {
    var message: String
}

extension DeclSyntax {
    var asStoredProperty: (TokenSyntax, TypeSyntax)? {
        get throws {
            guard let v = self.as(VariableDeclSyntax.self) else { return nil }
            guard v.bindings.count == 1 else { throw StructuralError(message: "Multiple bindings not supported.") }
            let binding = v.bindings.first!
            guard binding.accessorBlock == nil else { return nil }
            guard let id = binding.pattern.as(IdentifierPatternSyntax.self) else { throw StructuralError(message: "Only Identifier patterns supported.")
            }
            guard let type = binding.typeAnnotation?.type else { throw StructuralError(message: "Only properties with explicit types supported.")}
            return (id.identifier, type)
        }
    }
}


public struct StructuralMacro: MemberMacro, ExtensionMacro {
    public static func expansion(of node: AttributeSyntax, attachedTo declaration: some DeclGroupSyntax, providingExtensionsOf type: some TypeSyntaxProtocol, conformingTo protocols: [TypeSyntax], in context: some MacroExpansionContext) throws -> [ExtensionDeclSyntax] {
        let decl: DeclSyntax = "extension \(type.trimmed): Structural {}"
        return [
            decl.as(ExtensionDeclSyntax.self)!
        ]
    }

    public static func expansion(of node: AttributeSyntax, providingMembersOf declaration: some DeclGroupSyntax, in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        guard let structDecl = declaration.as(StructDeclSyntax.self) else { throw StructuralError(message: "Only works on structs") }
        let storedProperties = try declaration.memberBlock.members.compactMap { item in
            try item.decl.asStoredProperty
        }
        let typeDecl: DeclSyntax = storedProperties.reversed().reduce("Empty", { result, prop in
            "List<Property<\(prop.1)>, \(result)>"
        })
        let propsDecl: DeclSyntax = storedProperties.reversed().reduce("Empty()", { result, prop in
            "List(head: Property(name: \(literal: prop.0.text), value: \(prop.0)), tail: \(result))"
        })
        let fromDecl = zip(storedProperties.indices, storedProperties).map { (idx, prop) in
            let tails = Array(repeating: ".tail", count: idx).joined()
            return "\(prop.0): s.properties\(tails).head.value"
        }.joined(separator: ", ")
        return [
            "typealias Structure = Struct<\(typeDecl)>",
            """
            var to: Structure {
                Struct(name: \(literal: structDecl.name.text), properties: \(propsDecl))
            }
            static func from(_ s: Structure) -> Self {
                .init(\(raw: fromDecl))
            }
            """
        ]
    }
}

@main
struct StructuralPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        StructuralMacro.self
    ]
}
