module Metaprogramming_Layer;

import std.stdio;
import std.container : DList;
import std.string;

enum TokenKind
{
	UNKNOWN,
	IDENTIFIER,
	STAR,
	SLASH,
	PLUS,
	MINUS,
	ASSIGN,
	LEFT_PARENTHESIS,
	RIGHT_PARENTHESIS,
	LEFT_SQUARE_BRACKET,
	RIGHT_SQUARE_BRACKET,
	LEFT_BRACKET,
	RIGHT_BRACKET,
	MODULO,
	STRUCT,
	TYPE,
	KEYWORD_IF,
	KEYWORD_ELSE,
	DOUBLE_QUOTE,
	SINGLE_QUOTE,
	SEMICOLON,
	UNARY_OPERATOR,
	ANNOTATION
}

struct Token
{
	this(char[] TokenStr, TokenKind Kind)
	{
		this.TokenStr = TokenStr;
		this.Kind = Kind;
	}

	char[] TokenStr;
	TokenKind Kind;
}

pure
string GenerateSimpleCase(string Case, string TokenKindStr)
{
	import std.format;

	return format!"
		case '%s':
		  TokenList.insertBack(Token(Stream[0 .. 1], TokenKind.%s));
		  Stream = Stream[1 .. $];
		  break;"(Case, TokenKindStr);
}

struct Lexer
{
	public DList!Token Lex(char[] Stream)
	{
		auto TokenList = DList!Token();

		while (Stream.length)
		{
			Stream = stripLeft(Stream);
			switch (Stream[0])
			{
				mixin(GenerateSimpleCase("*", "STAR"));
				mixin(GenerateSimpleCase("+", "PLUS"));
				mixin(GenerateSimpleCase("-", "MINUS"));
				mixin(GenerateSimpleCase("=", "ASSIGN"));
				mixin(GenerateSimpleCase("%", "MODULO"));
				mixin(GenerateSimpleCase("(", "LEFT_PARENTHESIS"));
				mixin(GenerateSimpleCase(")", "RIGHT_PARENTHESIS"));
				mixin(GenerateSimpleCase("{", "LEFT_BRACKET"));
				mixin(GenerateSimpleCase("}", "RIGHT_BRACKET"));
				mixin(GenerateSimpleCase("[", "LEFT_SQUARE_BRACKET"));
				mixin(GenerateSimpleCase("]", "RIGHT_SQUARE_BRACKET"));
				mixin(GenerateSimpleCase(";", "SEMICOLON"));
				mixin(GenerateSimpleCase("@", "ANNOTATION"));
				case '/':
					if (Stream.length > 1)
					{
						if (Stream[1] == '/')
						{
							size_t Index = 0;
							while (Stream[Index] != '\n') 
							{
								++Index;
							}
							Stream = Stream[Index .. $];
						}
						else
						{
							TokenList.insertBack(Token(Stream[0 .. 1], TokenKind.SLASH));
							Stream = Stream[1 .. $];
						}
					}
					break;
					
				case 'a': .. case 'z':
					// Fallthrough
				case 'A': .. case 'Z':
					while (Strem.length && !isspace(Stream[0]))
					{
						
					}

				default:
					TokenList.insertBack(Token(Stream[0 .. 1], TokenKind.UNKNOWN));
					Stream = Stream[1 .. $];
					break;
			}
			if (Stream.length)
			{
				Stream = Stream[1 .. $];
			}
		}
		return TokenList;
	}

	public DList!Token Lex(string Filename)
	{
		char[] FileContents = ReadEntireFileIntoMemory(Filename);
		auto Result = Lex(FileContents);
		object.destroy(FileContents);
		return Result;
	}
}

char[] ReadEntireFileIntoMemory(string Filename)
{
	File file = File(Filename, "r");
	char[] Contents = file.rawRead(new char[file.size]);
	file.close();
	return Contents;
}

int main()
{
	Lexer lexer = Lexer();
	auto Tokens = lexer.Lex("Metaprogramming_Layer.d");
	foreach (token; Tokens)
	{
		writefln("%s\t%s", token.TokenStr, token.Kind);
	}
    return 0;
}