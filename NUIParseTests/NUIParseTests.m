//
//  NUIParseTests.m
//  NUIParseTests
//
//  Created by Tom Davie on 10/02/2011.
//  Copyright 2011 In The Beginning... All rights reserved.
//

#import "NUIParseTests.h"

#import "NUIParse.h"

#import "NUIPTestEvaluatorDelegate.h"
#import "NUIPTestErrorEvaluatorDelegate.h"
#import "NUIPTestWhiteSpaceIgnoringDelegate.h"
#import "NUIPTestMapCSSTokenisingDelegate.h"
#import "NUIPTestErrorHandlingDelegate.h"

#import "Expression.h"

@interface NUIParseTests ()

- (void)runMapCSSTokeniser:(NUIPTokenStream *)result;

@end

@implementation NUIParseTests
{
    NSString *mapCssInput;
    NUIPParser *mapCssParser;
    NUIPTokeniser *mapCssTokeniser;
}

- (void)setUpMapCSS
{
    NSCharacterSet *identifierCharacters = [NSCharacterSet characterSetWithCharactersInString:
                                            @"abcdefghijklmnopqrstuvwxyz"
                                            @"ABCDEFGHIJKLMNOPQRSTUVWXYZ"
                                            @"0123456789-_"];
    NSCharacterSet *initialIdCharacters = [NSCharacterSet characterSetWithCharactersInString:
                                           @"abcdefghijklmnopqrstuvwxyz"
                                           @"ABCDEFGHIJKLMNOPQRSTUVWXYZ"
                                           @"_-"];
    mapCssTokeniser = [[NUIPTokeniser alloc] init];
    [mapCssTokeniser addTokenRecogniser:[NUIPKeywordRecogniser recogniserForKeyword:@"node"     invalidFollowingCharacters:identifierCharacters]];
    [mapCssTokeniser addTokenRecogniser:[NUIPKeywordRecogniser recogniserForKeyword:@"way"      invalidFollowingCharacters:identifierCharacters]];
    [mapCssTokeniser addTokenRecogniser:[NUIPKeywordRecogniser recogniserForKeyword:@"relation" invalidFollowingCharacters:identifierCharacters]];
    [mapCssTokeniser addTokenRecogniser:[NUIPKeywordRecogniser recogniserForKeyword:@"area"     invalidFollowingCharacters:identifierCharacters]];
    [mapCssTokeniser addTokenRecogniser:[NUIPKeywordRecogniser recogniserForKeyword:@"line"     invalidFollowingCharacters:identifierCharacters]];
    [mapCssTokeniser addTokenRecogniser:[NUIPKeywordRecogniser recogniserForKeyword:@"canvas"   invalidFollowingCharacters:identifierCharacters]];
    [mapCssTokeniser addTokenRecogniser:[NUIPKeywordRecogniser recogniserForKeyword:@"url"      invalidFollowingCharacters:identifierCharacters]];
    [mapCssTokeniser addTokenRecogniser:[NUIPKeywordRecogniser recogniserForKeyword:@"eval"     invalidFollowingCharacters:identifierCharacters]];
    [mapCssTokeniser addTokenRecogniser:[NUIPKeywordRecogniser recogniserForKeyword:@"rgba"     invalidFollowingCharacters:identifierCharacters]];
    [mapCssTokeniser addTokenRecogniser:[NUIPKeywordRecogniser recogniserForKeyword:@"rgb"      invalidFollowingCharacters:identifierCharacters]];
    [mapCssTokeniser addTokenRecogniser:[NUIPKeywordRecogniser recogniserForKeyword:@"pt"       invalidFollowingCharacters:identifierCharacters]];
    [mapCssTokeniser addTokenRecogniser:[NUIPKeywordRecogniser recogniserForKeyword:@"px"       invalidFollowingCharacters:identifierCharacters]];
    [mapCssTokeniser addTokenRecogniser:[NUIPKeywordRecogniser recogniserForKeyword:@"*"]];
    [mapCssTokeniser addTokenRecogniser:[NUIPKeywordRecogniser recogniserForKeyword:@"["]];
    [mapCssTokeniser addTokenRecogniser:[NUIPKeywordRecogniser recogniserForKeyword:@"]"]];
    [mapCssTokeniser addTokenRecogniser:[NUIPKeywordRecogniser recogniserForKeyword:@"{"]];
    [mapCssTokeniser addTokenRecogniser:[NUIPKeywordRecogniser recogniserForKeyword:@"}"]];
    [mapCssTokeniser addTokenRecogniser:[NUIPKeywordRecogniser recogniserForKeyword:@"("]];
    [mapCssTokeniser addTokenRecogniser:[NUIPKeywordRecogniser recogniserForKeyword:@")"]];
    [mapCssTokeniser addTokenRecogniser:[NUIPKeywordRecogniser recogniserForKeyword:@"."]];
    [mapCssTokeniser addTokenRecogniser:[NUIPKeywordRecogniser recogniserForKeyword:@","]];
    [mapCssTokeniser addTokenRecogniser:[NUIPKeywordRecogniser recogniserForKeyword:@";"]];
    [mapCssTokeniser addTokenRecogniser:[NUIPKeywordRecogniser recogniserForKeyword:@"@import"]];
    [mapCssTokeniser addTokenRecogniser:[NUIPKeywordRecogniser recogniserForKeyword:@"|z"]];
    [mapCssTokeniser addTokenRecogniser:[NUIPKeywordRecogniser recogniserForKeyword:@"-"]];
    [mapCssTokeniser addTokenRecogniser:[NUIPKeywordRecogniser recogniserForKeyword:@"!="]];
    [mapCssTokeniser addTokenRecogniser:[NUIPKeywordRecogniser recogniserForKeyword:@"=~"]];
    [mapCssTokeniser addTokenRecogniser:[NUIPKeywordRecogniser recogniserForKeyword:@"<"]];
    [mapCssTokeniser addTokenRecogniser:[NUIPKeywordRecogniser recogniserForKeyword:@">"]];
    [mapCssTokeniser addTokenRecogniser:[NUIPKeywordRecogniser recogniserForKeyword:@"<="]];
    [mapCssTokeniser addTokenRecogniser:[NUIPKeywordRecogniser recogniserForKeyword:@">="]];
    [mapCssTokeniser addTokenRecogniser:[NUIPKeywordRecogniser recogniserForKeyword:@"="]];
    [mapCssTokeniser addTokenRecogniser:[NUIPKeywordRecogniser recogniserForKeyword:@":"]];
    [mapCssTokeniser addTokenRecogniser:[NUIPWhiteSpaceRecogniser whiteSpaceRecogniser]];
    [mapCssTokeniser addTokenRecogniser:[NUIPNumberRecogniser numberRecogniser]];
    [mapCssTokeniser addTokenRecogniser:[NUIPQuotedRecogniser quotedRecogniserWithStartQuote:@"/*" endQuote:@"*/" name:@"Comment"]];
    [mapCssTokeniser addTokenRecogniser:[NUIPQuotedRecogniser quotedRecogniserWithStartQuote:@"//" endQuote:@"\n" name:@"Comment"]];
    [mapCssTokeniser addTokenRecogniser:[NUIPQuotedRecogniser quotedRecogniserWithStartQuote:@"/"  endQuote:@"/"  escapeSequence:@"\\" name:@"Regex"]];
    [mapCssTokeniser addTokenRecogniser:[NUIPQuotedRecogniser quotedRecogniserWithStartQuote:@"'"  endQuote:@"'"  escapeSequence:@"\\" name:@"String"]];
    [mapCssTokeniser addTokenRecogniser:[NUIPQuotedRecogniser quotedRecogniserWithStartQuote:@"\"" endQuote:@"\"" escapeSequence:@"\\" name:@"String"]];
    [mapCssTokeniser addTokenRecogniser:[NUIPIdentifierRecogniser identifierRecogniserWithInitialCharacters:initialIdCharacters identifierCharacters:identifierCharacters]];
    [mapCssTokeniser setDelegate:[[[NUIPTestMapCSSTokenisingDelegate alloc] init] autorelease]];
    
    mapCssInput = @"node[highway=\"trunk\"]"
    @"{"
    @"  line-width: 5.0;"
    @"  label: jam;"
    @"} // Zomg boobs!\n"
    @"/* Haha, fooled you */"
    @"way relation[type=\"multipolygon\"]"
    @"{"
    @"  line-width: 0.0;"
    @"}";
    
    NUIPGrammar *grammar = [NUIPGrammar grammarWithStart:@"ruleset"
                                      backusNaurForm:
                          @"ruleset       ::= <rule>*;"
                          @"rule          ::= <selector> <commaSelector>* <declaration>+ | <import>;"
                          @"import        ::= '@import' 'url' '(' 'String' ')' 'Identifier';"
                          @"commaSelector ::= ',' <selector>;"
                          @"selector      ::= <subselector>+;"
                          @"subselector   ::= <object> 'Whitespace' | <object> <zoom> <test>* | <class>;"
                          @"zoom          ::= '|z' <range> | ;"
                          @"range         ::= 'Number' | 'Number' '-' 'Number';"
                          @"test          ::= '[' <condition> ']';"
                          @"condition     ::= <key> <binary> <value> | <unary> <key> | <key>;"
                          @"key           ::= 'Identifier';"
                          @"value         ::= 'String' | 'Regex';"
                          @"binary        ::= '=' | '!=' | '=~' | '<' | '>' | '<=' | '>=';"
                          @"unary         ::= '-' | '!';"
                          @"class         ::= '.' 'Identifier';"
                          @"object        ::= 'node' | 'way' | 'relation' | 'area' | 'line' | '*';"
                          @"declaration   ::= '{' <style>+ '}' | '{' '}';"
                          @"style         ::= <styledef> ';';"
                          @"styledef      ::= <key> ':' <unquoted>;"
                          @"unquoted      ::= 'Number' | 'Identifier';"
                                               error:NULL];
    mapCssParser = [[NUIPLALR1Parser alloc] initWithGrammar:grammar];
}

- (void)tearDownMapCSS
{
    [mapCssParser release];
    [mapCssTokeniser release];
}

- (void)testKeywordTokeniser
{
    NUIPTokeniser *tokeniser = [[[NUIPTokeniser alloc] init] autorelease];
    [tokeniser addTokenRecogniser:[NUIPKeywordRecogniser recogniserForKeyword:@"{"]];
    [tokeniser addTokenRecogniser:[NUIPKeywordRecogniser recogniserForKeyword:@"}"]];
    NUIPTokenStream *tokenStream = [tokeniser tokenise:@"{}"];
    NUIPTokenStream *expectedTokenStream = [NUIPTokenStream tokenStreamWithTokens:[NSArray arrayWithObjects:[NUIPKeywordToken tokenWithKeyword:@"{"], [NUIPKeywordToken tokenWithKeyword:@"}"], [NUIPEOFToken eof], nil]];
    STAssertEqualObjects(tokenStream, expectedTokenStream, @"Incorrect tokenisation of braces", nil);
}

- (void)testIntegerTokeniser
{
    NUIPTokeniser *tokeniser = [[[NUIPTokeniser alloc] init] autorelease];
    [tokeniser addTokenRecogniser:[NUIPNumberRecogniser integerRecogniser]];
    NUIPTokenStream *tokenStream = [tokeniser tokenise:@"1234"];
    NUIPTokenStream *expectedTokenStream = [NUIPTokenStream tokenStreamWithTokens:[NSArray arrayWithObjects:[NUIPNumberToken tokenWithNumber:[NSNumber numberWithInteger:1234]], [NUIPEOFToken eof], nil]];
    STAssertEqualObjects(tokenStream, expectedTokenStream, @"Incorrect tokenisation of integers", nil);

    tokenStream = [tokeniser tokenise:@"1234abcd"];
    expectedTokenStream = [NUIPTokenStream tokenStreamWithTokens:[NSArray arrayWithObjects:[NUIPNumberToken tokenWithNumber:[NSNumber numberWithInteger:1234]], [NUIPErrorToken errorWithMessage:nil], nil]];
    STAssertEqualObjects(tokenStream, expectedTokenStream, @"Incorrect tokenisation of integers with additional cruft", nil);
}

- (void)testFloatTokeniser
{
    NUIPTokeniser *tokeniser = [[[NUIPTokeniser alloc] init] autorelease];
    [tokeniser addTokenRecogniser:[NUIPNumberRecogniser floatRecogniser]];
    NUIPTokenStream *tokenStream = [tokeniser tokenise:@"1234.5678"];
    NUIPTokenStream *expectedTokenStream = [NUIPTokenStream tokenStreamWithTokens:[NSArray arrayWithObjects:[NUIPNumberToken tokenWithNumber:[NSNumber numberWithDouble:1234.5678]], [NUIPEOFToken eof], nil]];
    STAssertEqualObjects(tokenStream, expectedTokenStream, @"Incorrect tokenisation of floats", nil);
    
    tokenStream = [tokeniser tokenise:@"1234"];
    expectedTokenStream = [NUIPTokenStream tokenStreamWithTokens:[NSArray arrayWithObject:[NUIPErrorToken errorWithMessage:nil]]];
    STAssertEqualObjects(tokenStream, expectedTokenStream, @"Tokenising floats recognises integers as well", nil);
}

- (void)testNumberTokeniser
{
    NUIPTokeniser *tokeniser = [[[NUIPTokeniser alloc] init] autorelease];
    [tokeniser addTokenRecogniser:[NUIPNumberRecogniser numberRecogniser]];

    NUIPTokenStream *tokenStream = [tokeniser tokenise:@"1234.5678"];
    NUIPTokenStream *expectedTokenStream = [NUIPTokenStream tokenStreamWithTokens:[NSArray arrayWithObjects:[NUIPNumberToken tokenWithNumber:[NSNumber numberWithDouble:1234.5678]], [NUIPEOFToken eof], nil]];
    STAssertEqualObjects(tokenStream, expectedTokenStream, @"Incorrect tokenisation of numbers", nil);
    
    tokenStream = [tokeniser tokenise:@"1234abcd"];
    expectedTokenStream = [NUIPTokenStream tokenStreamWithTokens:[NSArray arrayWithObjects:[NUIPNumberToken tokenWithNumber:[NSNumber numberWithInteger:1234]], [NUIPErrorToken errorWithMessage:nil], nil]];
    STAssertEqualObjects(tokenStream, expectedTokenStream, @"Incorrect tokenisation of numbers with additional cruft", nil);
}

- (void)testWhiteSpaceTokeniser
{
    NUIPTokeniser *tokeniser = [[[NUIPTokeniser alloc] init] autorelease];
    [tokeniser addTokenRecogniser:[NUIPNumberRecogniser numberRecogniser]];
    [tokeniser addTokenRecogniser:[NUIPWhiteSpaceRecogniser whiteSpaceRecogniser]];
    NUIPTokenStream *tokenStream = [tokeniser tokenise:@"12.34 56.78\t90"];
    NUIPTokenStream *expectedTokenStream = [NUIPTokenStream tokenStreamWithTokens:[NSArray arrayWithObjects:
                                                                               [NUIPNumberToken tokenWithNumber:[NSNumber numberWithDouble:12.34]], [NUIPWhiteSpaceToken whiteSpace:@" "],
                                                                               [NUIPNumberToken tokenWithNumber:[NSNumber numberWithDouble:56.78]], [NUIPWhiteSpaceToken whiteSpace:@"\t"],
                                                                               [NUIPNumberToken tokenWithNumber:[NSNumber numberWithDouble:90]]   , [NUIPEOFToken eof], nil]];
    STAssertEqualObjects(tokenStream, expectedTokenStream, @"Failed to tokenise white space correctly", nil);
}

- (void)testIdentifierTokeniser
{
    NUIPTokeniser *tokeniser = [[[NUIPTokeniser alloc] init] autorelease];
    [tokeniser addTokenRecogniser:[NUIPKeywordRecogniser recogniserForKeyword:@"long"]];
    [tokeniser addTokenRecogniser:[NUIPIdentifierRecogniser identifierRecogniser]];
    [tokeniser addTokenRecogniser:[NUIPWhiteSpaceRecogniser whiteSpaceRecogniser]];
    NUIPTokenStream *tokenStream = [tokeniser tokenise:@"long jam _ham long _spam59e_53"];
    NUIPTokenStream *expectedTokenStream = [NUIPTokenStream tokenStreamWithTokens:[NSArray arrayWithObjects:
                                                                               [NUIPKeywordToken tokenWithKeyword:@"long"]             , [NUIPWhiteSpaceToken whiteSpace:@" "],
                                                                               [NUIPIdentifierToken tokenWithIdentifier:@"jam"]        , [NUIPWhiteSpaceToken whiteSpace:@" "],
                                                                               [NUIPIdentifierToken tokenWithIdentifier:@"_ham"]       , [NUIPWhiteSpaceToken whiteSpace:@" "],
                                                                               [NUIPKeywordToken tokenWithKeyword:@"long"]             , [NUIPWhiteSpaceToken whiteSpace:@" "],
                                                                               [NUIPIdentifierToken tokenWithIdentifier:@"_spam59e_53"], [NUIPEOFToken eof], nil]];
    STAssertEqualObjects(tokenStream, expectedTokenStream, @"Failed to tokenise identifiers space correctly", nil);
    
    tokeniser = [[[NUIPTokeniser alloc] init] autorelease];
    [tokeniser addTokenRecogniser:[NUIPIdentifierRecogniser identifierRecogniserWithInitialCharacters:[NSCharacterSet characterSetWithCharactersInString:@"abc"]
                                                                               identifierCharacters:[NSCharacterSet characterSetWithCharactersInString:@"def"]]];
    [tokeniser addTokenRecogniser:[NUIPWhiteSpaceRecogniser whiteSpaceRecogniser]];
    tokenStream = [tokeniser tokenise:@"adef abdef"];
    expectedTokenStream = [NUIPTokenStream tokenStreamWithTokens:[NSArray arrayWithObjects:
                                                                [NUIPIdentifierToken tokenWithIdentifier:@"adef"], [NUIPWhiteSpaceToken whiteSpace:@" "],
                                                                [NUIPIdentifierToken tokenWithIdentifier:@"a"], [NUIPIdentifierToken tokenWithIdentifier:@"bdef"],
                                                                [NUIPEOFToken eof], nil]];
    STAssertEqualObjects(tokenStream, expectedTokenStream, @"Incorrectly tokenised identifiers", nil);
}

- (void)testQuotedTokeniser
{
    NUIPTokeniser *tokeniser = [[[NUIPTokeniser alloc] init] autorelease];
    [tokeniser addTokenRecogniser:[NUIPQuotedRecogniser quotedRecogniserWithStartQuote:@"/*" endQuote:@"*/" name:@"Comment"]];
    NUIPTokenStream *tokenStream = [tokeniser tokenise:@"/* abcde ghi */"];
    NUIPTokenStream *expectdTokenStream = [NUIPTokenStream tokenStreamWithTokens:[NSArray arrayWithObjects:[NUIPQuotedToken content:@" abcde ghi " quotedWith:@"/*" name:@"Comment"], [NUIPEOFToken eof], nil]];
    STAssertEqualObjects(tokenStream, expectdTokenStream, @"Failed to tokenise comment", nil);
    
    [tokeniser addTokenRecogniser:[NUIPQuotedRecogniser quotedRecogniserWithStartQuote:@"\"" endQuote:@"\"" escapeSequence:@"\\" name:@"String"]];
    tokenStream = [tokeniser tokenise:@"/* abc */\"def\""];
    expectdTokenStream = [NUIPTokenStream tokenStreamWithTokens:[NSArray arrayWithObjects:[NUIPQuotedToken content:@" abc " quotedWith:@"/*" name:@"Comment"], [NUIPQuotedToken content:@"def" quotedWith:@"\"" name:@"String"], [NUIPEOFToken eof], nil]];
    STAssertEqualObjects(tokenStream, expectdTokenStream, @"Failed to tokenise comment and string", nil);
    
    tokenStream = [tokeniser tokenise:@"\"def\\\"\""];
    expectdTokenStream = [NUIPTokenStream tokenStreamWithTokens:[NSArray arrayWithObjects:[NUIPQuotedToken content:@"def\"" quotedWith:@"\"" name:@"String"], [NUIPEOFToken eof], nil]];
    STAssertEqualObjects(tokenStream, expectdTokenStream, @"Failed to tokenise string with quote in it", nil);
    
    tokenStream = [tokeniser tokenise:@"\"def\\\\\""];
    expectdTokenStream = [NUIPTokenStream tokenStreamWithTokens:[NSArray arrayWithObjects:[NUIPQuotedToken content:@"def\\" quotedWith:@"\"" name:@"String"], [NUIPEOFToken eof], nil]];
    STAssertEqualObjects(tokenStream, expectdTokenStream, @"Failed to tokenise string with backslash in it", nil);

    tokeniser = [[[NUIPTokeniser alloc] init] autorelease];
    NUIPQuotedRecogniser *rec = [NUIPQuotedRecogniser quotedRecogniserWithStartQuote:@"\"" endQuote:@"\"" escapeSequence:@"\\" name:@"String"];
    [rec setEscapeReplacer:^ NSString * (NSString *str, NSUInteger *loc)
     {
         if ([str length] > *loc)
         {
             switch ([str characterAtIndex:*loc])
             {
                 case 'b':
                     *loc = *loc + 1;
                     return @"\b";
                 case 'f':
                     *loc = *loc + 1;
                     return @"\f";
                 case 'n':
                     *loc = *loc + 1;
                     return @"\n";
                 case 'r':
                     *loc = *loc + 1;
                     return @"\r";
                 case 't':
                     *loc = *loc + 1;
                     return @"\t";
                 default:
                     break;
             }
         }
         return nil;
     }];
    [tokeniser addTokenRecogniser:rec];
    tokenStream = [tokeniser tokenise:@"\"\\n\\r\\f\""];
    expectdTokenStream = [NUIPTokenStream tokenStreamWithTokens:[NSArray arrayWithObjects:[NUIPQuotedToken content:@"\n\r\f" quotedWith:@"\"" name:@"String"], [NUIPEOFToken eof], nil]];
    STAssertEqualObjects(tokenStream, expectdTokenStream, @"Failed to correctly tokenise string with recognised escape chars", nil);
    
    tokeniser = [[[NUIPTokeniser alloc] init] autorelease];
    [tokeniser addTokenRecogniser:[NUIPQuotedRecogniser quotedRecogniserWithStartQuote:@"'" endQuote:@"'" escapeSequence:nil maximumLength:1 name:@"Character"]];
    tokenStream = [tokeniser tokenise:@"'a''bc'"];
    expectdTokenStream = [NUIPTokenStream tokenStreamWithTokens:[NSArray arrayWithObjects:[NUIPQuotedToken content:@"a" quotedWith:@"'" name:@"Character"], [NUIPErrorToken errorWithMessage:nil], nil]];
    STAssertEqualObjects(tokenStream, expectdTokenStream, @"Failed to correctly tokenise characters", nil);
}

- (void)testTokeniserError
{
    NUIPTokeniser *tokeniser = [[[NUIPTokeniser alloc] init] autorelease];
    [tokeniser addTokenRecogniser:[NUIPQuotedRecogniser quotedRecogniserWithStartQuote:@"/*" endQuote:@"*/" name:@"Comment"]];
    NUIPTokenStream *tokenStream = [tokeniser tokenise:@"/* abcde ghi */ abc /* def */"];
    NUIPTokenStream *expectedTokenStream = [NUIPTokenStream tokenStreamWithTokens:[NSArray arrayWithObjects:[NUIPQuotedToken content:@" abcde ghi " quotedWith:@"/*" name:@"Comment"], [NUIPErrorToken errorWithMessage:nil], nil]];
    STAssertEqualObjects(tokenStream, expectedTokenStream, @"Inserting error token and bailing failed", nil);
    
    [tokeniser setDelegate:[[[NUIPTestErrorHandlingDelegate alloc] init] autorelease]];
    tokenStream = [tokeniser tokenise:@"/* abcde ghi */ abc /* def */"];
    expectedTokenStream = [NUIPTokenStream tokenStreamWithTokens:[NSArray arrayWithObjects:[NUIPQuotedToken content:@" abcde ghi " quotedWith:@"/*" name:@"Comment"], [NUIPErrorToken errorWithMessage:nil], [NUIPQuotedToken content:@" def " quotedWith:@"/*" name:@"Comment"], [NUIPEOFToken eof], nil]];
    STAssertEqualObjects(tokenStream, expectedTokenStream, @"Inserting error token and continuing according to delegate failed.", nil);
}

- (void)testTokenLineColumnNumbers
{
    NUIPTokeniser *tokeniser = [[[NUIPTokeniser alloc] init] autorelease];
    [tokeniser addTokenRecogniser:[NUIPQuotedRecogniser quotedRecogniserWithStartQuote:@"/*" endQuote:@"*/" name:@"Comment"]];
    [tokeniser addTokenRecogniser:[NUIPKeywordRecogniser recogniserForKeyword:@"long"]];
    [tokeniser addTokenRecogniser:[NUIPIdentifierRecogniser identifierRecogniser]];
    [tokeniser addTokenRecogniser:[NUIPWhiteSpaceRecogniser whiteSpaceRecogniser]];
    NUIPTokenStream *tokenStream = [tokeniser tokenise:@"/* blah\nblah blah\n blah */ long jam\n\nlong ham"];
    NSUInteger tokenLines[]     = {0, 2 , 2 , 2 , 2 , 2 , 4 , 4 , 4 , 4 };
    NSUInteger tokenColumns[]   = {0, 8 , 9 , 13, 14, 17, 0 , 4 , 5 , 8 };
    NSUInteger tokenPositions[] = {0, 26, 27, 31, 32, 35, 37, 41, 42, 45};
    NSUInteger tokenNumber = 0;
    NUIPToken *token = nil;
    while ((token = [tokenStream popToken]))
    {
        STAssertEquals([token lineNumber     ], tokenLines  [tokenNumber]  , @"Line number for token %lu is incorrect", tokenNumber, nil);
        STAssertEquals([token columnNumber   ], tokenColumns[tokenNumber]  , @"Column number for token %lu is incorrect", tokenNumber, nil);
        STAssertEquals([token characterNumber], tokenPositions[tokenNumber], @"Character number for token %lu is incorrect", tokenNumber, nil);
        tokenNumber++;
    }
}

- (void)testMapCSSTokenisation
{
    [self setUpMapCSS];
    
    NUIPTokenStream *tokenStream = [mapCssTokeniser tokenise:mapCssInput];
    NUIPTokenStream *expectedTokenStream = [NUIPTokenStream tokenStreamWithTokens:[NSArray arrayWithObjects:
                                                                               [NUIPKeywordToken tokenWithKeyword:@"node"],
                                                                               [NUIPKeywordToken tokenWithKeyword:@"["],
                                                                               [NUIPIdentifierToken tokenWithIdentifier:@"highway"],
                                                                               [NUIPKeywordToken tokenWithKeyword:@"="],
                                                                               [NUIPQuotedToken content:@"trunk" quotedWith:@"\"" name:@"String"],
                                                                               [NUIPKeywordToken tokenWithKeyword:@"]"],
                                                                               [NUIPKeywordToken tokenWithKeyword:@"{"],
                                                                               [NUIPIdentifierToken tokenWithIdentifier:@"line-width"],
                                                                               [NUIPKeywordToken tokenWithKeyword:@":"],
                                                                               [NUIPNumberToken tokenWithNumber:[NSNumber numberWithFloat:5.0f]],
                                                                               [NUIPKeywordToken tokenWithKeyword:@";"],
                                                                               [NUIPIdentifierToken tokenWithIdentifier:@"label"],
                                                                               [NUIPKeywordToken tokenWithKeyword:@":"],
                                                                               [NUIPIdentifierToken tokenWithIdentifier:@"jam"],
                                                                               [NUIPKeywordToken tokenWithKeyword:@";"],
                                                                               [NUIPKeywordToken tokenWithKeyword:@"}"],
                                                                               [NUIPKeywordToken tokenWithKeyword:@"way"],
                                                                               [NUIPWhiteSpaceToken whiteSpace:@" "],
                                                                               [NUIPKeywordToken tokenWithKeyword:@"relation"],
                                                                               [NUIPKeywordToken tokenWithKeyword:@"["],
                                                                               [NUIPIdentifierToken tokenWithIdentifier:@"type"],
                                                                               [NUIPKeywordToken tokenWithKeyword:@"="],
                                                                               [NUIPQuotedToken content:@"multipolygon" quotedWith:@"\"" name:@"String"],
                                                                               [NUIPKeywordToken tokenWithKeyword:@"]"],
                                                                               [NUIPKeywordToken tokenWithKeyword:@"{"],
                                                                               [NUIPIdentifierToken tokenWithIdentifier:@"line-width"],
                                                                               [NUIPKeywordToken tokenWithKeyword:@":"],
                                                                               [NUIPNumberToken tokenWithNumber:[NSNumber numberWithFloat:0.0f]],
                                                                               [NUIPKeywordToken tokenWithKeyword:@";"],
                                                                               [NUIPKeywordToken tokenWithKeyword:@"}"],
                                                                               [NUIPEOFToken eof],
                                                                               nil]];
    STAssertEqualObjects(tokenStream, expectedTokenStream, @"Tokenisation of MapCSS failed", nil);
    
    [self tearDownMapCSS];
}

- (void)testSLR
{
    NUIPTokeniser *tokeniser = [[[NUIPTokeniser alloc] init] autorelease];
    [tokeniser addTokenRecogniser:[NUIPNumberRecogniser integerRecogniser]];
    [tokeniser addTokenRecogniser:[NUIPWhiteSpaceRecogniser whiteSpaceRecogniser]];
    [tokeniser addTokenRecogniser:[NUIPKeywordRecogniser recogniserForKeyword:@"+"]];
    [tokeniser addTokenRecogniser:[NUIPKeywordRecogniser recogniserForKeyword:@"*"]];
    [tokeniser addTokenRecogniser:[NUIPKeywordRecogniser recogniserForKeyword:@"("]];
    [tokeniser addTokenRecogniser:[NUIPKeywordRecogniser recogniserForKeyword:@")"]];
    [tokeniser setDelegate:[[[NUIPTestWhiteSpaceIgnoringDelegate alloc] init] autorelease]];
    NUIPTokenStream *tokenStream = [tokeniser tokenise:@"5 + (2 * 5 + 9) * 8"];
    
    NUIPRule *tE = [NUIPRule ruleWithName:@"e" rightHandSideElements:[NSArray arrayWithObject:[NUIPGrammarSymbol nonTerminalWithName:@"t"]] tag:0];
    NUIPRule *aE = [NUIPRule ruleWithName:@"e" rightHandSideElements:[NSArray arrayWithObjects:[NUIPGrammarSymbol nonTerminalWithName:@"e"], [NUIPGrammarSymbol terminalWithName:@"+"], [NUIPGrammarSymbol nonTerminalWithName:@"t"], nil] tag:1];
    NUIPRule *fT = [NUIPRule ruleWithName:@"t" rightHandSideElements:[NSArray arrayWithObject:[NUIPGrammarSymbol nonTerminalWithName:@"f"]] tag:2];
    NUIPRule *mT = [NUIPRule ruleWithName:@"t" rightHandSideElements:[NSArray arrayWithObjects:[NUIPGrammarSymbol nonTerminalWithName:@"t"], [NUIPGrammarSymbol terminalWithName:@"*"], [NUIPGrammarSymbol nonTerminalWithName:@"f"], nil] tag:3];
    NUIPRule *iF = [NUIPRule ruleWithName:@"f" rightHandSideElements:[NSArray arrayWithObject:[NUIPGrammarSymbol terminalWithName:@"Number"]] tag:4];
    NUIPRule *pF = [NUIPRule ruleWithName:@"f" rightHandSideElements:[NSArray arrayWithObjects:[NUIPGrammarSymbol terminalWithName:@"("], [NUIPGrammarSymbol nonTerminalWithName:@"e"], [NUIPGrammarSymbol terminalWithName:@")"], nil] tag:5];
    NUIPGrammar *grammar = [NUIPGrammar grammarWithStart:@"e" rules:[NSArray arrayWithObjects:tE, aE, fT, mT, iF, pF, nil]];
    NUIPSLRParser *parser = [NUIPSLRParser parserWithGrammar:grammar];
    [parser setDelegate:[[[NUIPTestEvaluatorDelegate alloc] init] autorelease]];
    NSNumber *result = [parser parse:tokenStream];
    
    STAssertEquals([result intValue], 157, @"Parsed expression had incorrect value when using SLR parser", nil);
}

- (void)testLR1
{
    NUIPTokeniser *tokeniser = [[[NUIPTokeniser alloc] init] autorelease];
    [tokeniser addTokenRecogniser:[NUIPNumberRecogniser integerRecogniser]];
    [tokeniser addTokenRecogniser:[NUIPWhiteSpaceRecogniser whiteSpaceRecogniser]];
    [tokeniser addTokenRecogniser:[NUIPKeywordRecogniser recogniserForKeyword:@"+"]];
    [tokeniser addTokenRecogniser:[NUIPKeywordRecogniser recogniserForKeyword:@"*"]];
    [tokeniser addTokenRecogniser:[NUIPKeywordRecogniser recogniserForKeyword:@"("]];
    [tokeniser addTokenRecogniser:[NUIPKeywordRecogniser recogniserForKeyword:@")"]];
    [tokeniser setDelegate:[[[NUIPTestWhiteSpaceIgnoringDelegate alloc] init] autorelease]];
    NUIPTokenStream *tokenStream = [tokeniser tokenise:@"5 + (2 * 5 + 9) * 8"];
    
    NUIPRule *tE = [NUIPRule ruleWithName:@"e" rightHandSideElements:[NSArray arrayWithObject:[NUIPGrammarSymbol nonTerminalWithName:@"t"]] tag:0];
    NUIPRule *aE = [NUIPRule ruleWithName:@"e" rightHandSideElements:[NSArray arrayWithObjects:[NUIPGrammarSymbol nonTerminalWithName:@"e"], [NUIPGrammarSymbol terminalWithName:@"+"], [NUIPGrammarSymbol nonTerminalWithName:@"t"], nil] tag:1];
    NUIPRule *fT = [NUIPRule ruleWithName:@"t" rightHandSideElements:[NSArray arrayWithObject:[NUIPGrammarSymbol nonTerminalWithName:@"f"]] tag:2];
    NUIPRule *mT = [NUIPRule ruleWithName:@"t" rightHandSideElements:[NSArray arrayWithObjects:[NUIPGrammarSymbol nonTerminalWithName:@"t"], [NUIPGrammarSymbol terminalWithName:@"*"], [NUIPGrammarSymbol nonTerminalWithName:@"f"], nil] tag:3];
    NUIPRule *iF = [NUIPRule ruleWithName:@"f" rightHandSideElements:[NSArray arrayWithObject:[NUIPGrammarSymbol terminalWithName:@"Number"]] tag:4];
    NUIPRule *pF = [NUIPRule ruleWithName:@"f" rightHandSideElements:[NSArray arrayWithObjects:[NUIPGrammarSymbol terminalWithName:@"("], [NUIPGrammarSymbol nonTerminalWithName:@"e"], [NUIPGrammarSymbol terminalWithName:@")"], nil] tag:5];
    NUIPGrammar *grammar = [NUIPGrammar grammarWithStart:@"e" rules:[NSArray arrayWithObjects:tE, aE, fT, mT, iF, pF, nil]];
    NUIPLR1Parser *parser = [NUIPLR1Parser parserWithGrammar:grammar];
    [parser setDelegate:[[[NUIPTestEvaluatorDelegate alloc] init] autorelease]];
    NSNumber *result = [parser parse:tokenStream];
    
    STAssertEquals([result intValue], 157, @"Parsed expression had incorrect value when using LR(1) parser", nil);
    
    tokeniser = [[[NUIPTokeniser alloc] init] autorelease];
    [tokeniser addTokenRecogniser:[NUIPKeywordRecogniser recogniserForKeyword:@"a"]];
    [tokeniser addTokenRecogniser:[NUIPKeywordRecogniser recogniserForKeyword:@"b"]];
    tokenStream = [tokeniser tokenise:@"aaabab"];
    NUIPRule *s  = [NUIPRule ruleWithName:@"s" rightHandSideElements:[NSArray arrayWithObjects:[NUIPGrammarSymbol nonTerminalWithName:@"b"], [NUIPGrammarSymbol nonTerminalWithName:@"b"], nil]];
    NUIPRule *b1 = [NUIPRule ruleWithName:@"b" rightHandSideElements:[NSArray arrayWithObjects:[NUIPGrammarSymbol terminalWithName:@"a"], [NUIPGrammarSymbol nonTerminalWithName:@"b"], nil]];
    NUIPRule *b2 = [NUIPRule ruleWithName:@"b" rightHandSideElements:[NSArray arrayWithObject:[NUIPGrammarSymbol terminalWithName:@"b"]]];
    grammar = [NUIPGrammar grammarWithStart:@"s" rules:[NSArray arrayWithObjects:s, b1, b2, nil]];
    parser = [NUIPLR1Parser parserWithGrammar:grammar];
    NUIPSyntaxTree *tree = [parser parse:tokenStream];
    
    NUIPSyntaxTree *bTree = [NUIPSyntaxTree syntaxTreeWithRule:b2 children:[NSArray arrayWithObject:[NUIPKeywordToken tokenWithKeyword:@"b"]] tagValues:[NSDictionary dictionary]];
    NUIPSyntaxTree *abTree = [NUIPSyntaxTree syntaxTreeWithRule:b1 children:[NSArray arrayWithObjects:[NUIPKeywordToken tokenWithKeyword:@"a"], bTree, nil] tagValues:[NSDictionary dictionary]];
    NUIPSyntaxTree *aabTree = [NUIPSyntaxTree syntaxTreeWithRule:b1 children:[NSArray arrayWithObjects:[NUIPKeywordToken tokenWithKeyword:@"a"], abTree, nil] tagValues:[NSDictionary dictionary]];
    NUIPSyntaxTree *aaabTree = [NUIPSyntaxTree syntaxTreeWithRule:b1 children:[NSArray arrayWithObjects:[NUIPKeywordToken tokenWithKeyword:@"a"], aabTree, nil] tagValues:[NSDictionary dictionary]];
    NUIPSyntaxTree *sTree = [NUIPSyntaxTree syntaxTreeWithRule:s children:[NSArray arrayWithObjects:aaabTree, abTree, nil] tagValues:[NSDictionary dictionary]];
    
    STAssertEqualObjects(tree, sTree, @"Parsing LR(1) grammar failed when using LR(1) parser", nil);
}

- (void)testLALR1
{
    NUIPTokeniser *tokeniser = [[[NUIPTokeniser alloc] init] autorelease];
    [tokeniser addTokenRecogniser:[NUIPNumberRecogniser integerRecogniser]];
    [tokeniser addTokenRecogniser:[NUIPWhiteSpaceRecogniser whiteSpaceRecogniser]];
    [tokeniser addTokenRecogniser:[NUIPKeywordRecogniser recogniserForKeyword:@"="]];
    [tokeniser addTokenRecogniser:[NUIPKeywordRecogniser recogniserForKeyword:@"*"]];
    [tokeniser setDelegate:[[[NUIPTestWhiteSpaceIgnoringDelegate alloc] init] autorelease]];
    NUIPTokenStream *tokenStream = [tokeniser tokenise:@"*10 = 5"];
    
    NUIPRule *sL = [NUIPRule ruleWithName:@"s" rightHandSideElements:[NSArray arrayWithObjects:[NUIPGrammarSymbol nonTerminalWithName:@"l"], [NUIPGrammarSymbol terminalWithName:@"="], [NUIPGrammarSymbol nonTerminalWithName:@"r"], nil]];
    NUIPRule *sR = [NUIPRule ruleWithName:@"s" rightHandSideElements:[NSArray arrayWithObjects:[NUIPGrammarSymbol nonTerminalWithName:@"r"], nil]];
    NUIPRule *lM = [NUIPRule ruleWithName:@"l" rightHandSideElements:[NSArray arrayWithObjects:[NUIPGrammarSymbol terminalWithName:@"*"], [NUIPGrammarSymbol nonTerminalWithName:@"r"], nil]];
    NUIPRule *lN = [NUIPRule ruleWithName:@"l" rightHandSideElements:[NSArray arrayWithObjects:[NUIPGrammarSymbol terminalWithName:@"Number"], nil]];
    NUIPRule *rL = [NUIPRule ruleWithName:@"r" rightHandSideElements:[NSArray arrayWithObjects:[NUIPGrammarSymbol nonTerminalWithName:@"l"], nil]];
    NUIPGrammar *grammar = [NUIPGrammar grammarWithStart:@"s" rules:[NSArray arrayWithObjects:sL, sR, lM, lN, rL, nil]];
    NUIPLALR1Parser *parser = [NUIPLALR1Parser parserWithGrammar:grammar];
    NUIPSyntaxTree *tree = [parser parse:tokenStream];
    
    NUIPSyntaxTree *tenTree  = [NUIPSyntaxTree syntaxTreeWithRule:lN children:[NSArray arrayWithObject:[NUIPNumberToken tokenWithNumber:[NSNumber numberWithInt:10]]] tagValues:[NSDictionary dictionary]];
    NUIPSyntaxTree *fiveTree = [NUIPSyntaxTree syntaxTreeWithRule:lN children:[NSArray arrayWithObject:[NUIPNumberToken tokenWithNumber:[NSNumber numberWithInt:5]]] tagValues:[NSDictionary dictionary]];
    NUIPSyntaxTree *tenRTree = [NUIPSyntaxTree syntaxTreeWithRule:rL children:[NSArray arrayWithObject:tenTree] tagValues:[NSDictionary dictionary]];
    NUIPSyntaxTree *starTenTree = [NUIPSyntaxTree syntaxTreeWithRule:lM children:[NSArray arrayWithObjects:[NUIPKeywordToken tokenWithKeyword:@"*"], tenRTree, nil] tagValues:[NSDictionary dictionary]];
    NUIPSyntaxTree *fiveRTree = [NUIPSyntaxTree syntaxTreeWithRule:rL children:[NSArray arrayWithObject:fiveTree] tagValues:[NSDictionary dictionary]];
    NUIPSyntaxTree *wholeTree = [NUIPSyntaxTree syntaxTreeWithRule:sL children:[NSArray arrayWithObjects:starTenTree, [NUIPKeywordToken tokenWithKeyword:@"="], fiveRTree, nil] tagValues:[NSDictionary dictionary]];
    
    STAssertEqualObjects(tree, wholeTree, @"Parsing LALR(1) grammar failed", nil);
    
    tokeniser = [[[NUIPTokeniser alloc] init] autorelease];
    [tokeniser addTokenRecogniser:[NUIPNumberRecogniser integerRecogniser]];
    [tokeniser addTokenRecogniser:[NUIPWhiteSpaceRecogniser whiteSpaceRecogniser]];
    [tokeniser addTokenRecogniser:[NUIPKeywordRecogniser recogniserForKeyword:@"+"]];
    [tokeniser addTokenRecogniser:[NUIPKeywordRecogniser recogniserForKeyword:@"*"]];
    [tokeniser addTokenRecogniser:[NUIPKeywordRecogniser recogniserForKeyword:@"("]];
    [tokeniser addTokenRecogniser:[NUIPKeywordRecogniser recogniserForKeyword:@")"]];
    [tokeniser setDelegate:[[[NUIPTestWhiteSpaceIgnoringDelegate alloc] init] autorelease]];
    tokenStream = [tokeniser tokenise:@"5 + (2 * 5 + 9) * 8"];
    
    NUIPRule *tE = [NUIPRule ruleWithName:@"e" rightHandSideElements:[NSArray arrayWithObject:[NUIPGrammarSymbol nonTerminalWithName:@"t"]] tag:0];
    NUIPRule *aE = [NUIPRule ruleWithName:@"e" rightHandSideElements:[NSArray arrayWithObjects:[NUIPGrammarSymbol nonTerminalWithName:@"e"], [NUIPGrammarSymbol terminalWithName:@"+"], [NUIPGrammarSymbol nonTerminalWithName:@"t"], nil] tag:1];
    NUIPRule *fT = [NUIPRule ruleWithName:@"t" rightHandSideElements:[NSArray arrayWithObject:[NUIPGrammarSymbol nonTerminalWithName:@"f"]] tag:2];
    NUIPRule *mT = [NUIPRule ruleWithName:@"t" rightHandSideElements:[NSArray arrayWithObjects:[NUIPGrammarSymbol nonTerminalWithName:@"t"], [NUIPGrammarSymbol terminalWithName:@"*"], [NUIPGrammarSymbol nonTerminalWithName:@"f"], nil] tag:3];
    NUIPRule *iF = [NUIPRule ruleWithName:@"f" rightHandSideElements:[NSArray arrayWithObject:[NUIPGrammarSymbol terminalWithName:@"Number"]] tag:4];
    NUIPRule *pF = [NUIPRule ruleWithName:@"f" rightHandSideElements:[NSArray arrayWithObjects:[NUIPGrammarSymbol terminalWithName:@"("], [NUIPGrammarSymbol nonTerminalWithName:@"e"], [NUIPGrammarSymbol terminalWithName:@")"], nil] tag:5];
    grammar = [NUIPGrammar grammarWithStart:@"e" rules:[NSArray arrayWithObjects:tE, aE, fT, mT, iF, pF, nil]];
    parser = [NUIPLALR1Parser parserWithGrammar:grammar];
    [parser setDelegate:[[[NUIPTestEvaluatorDelegate alloc] init] autorelease]];
    NSNumber *result = [parser parse:tokenStream];
    
    STAssertEquals([result intValue], 157, @"Parsed expression had incorrect value when using LALR(1) parser", nil);
    
    tokeniser = [[[NUIPTokeniser alloc] init] autorelease];
    [tokeniser addTokenRecogniser:[NUIPKeywordRecogniser recogniserForKeyword:@"a"]];
    [tokeniser addTokenRecogniser:[NUIPKeywordRecogniser recogniserForKeyword:@"b"]];
    tokenStream = [tokeniser tokenise:@"aaabab"];
    NUIPRule *s  = [NUIPRule ruleWithName:@"s" rightHandSideElements:[NSArray arrayWithObjects:[NUIPGrammarSymbol nonTerminalWithName:@"b"], [NUIPGrammarSymbol nonTerminalWithName:@"b"], nil]];
    NUIPRule *b1 = [NUIPRule ruleWithName:@"b" rightHandSideElements:[NSArray arrayWithObjects:[NUIPGrammarSymbol terminalWithName:@"a"], [NUIPGrammarSymbol nonTerminalWithName:@"b"], nil]];
    NUIPRule *b2 = [NUIPRule ruleWithName:@"b" rightHandSideElements:[NSArray arrayWithObject:[NUIPGrammarSymbol terminalWithName:@"b"]]];
    grammar = [NUIPGrammar grammarWithStart:@"s" rules:[NSArray arrayWithObjects:s, b1, b2, nil]];
    parser = [NUIPLALR1Parser parserWithGrammar:grammar];
    tree = [parser parse:tokenStream];
    
    NUIPSyntaxTree *bTree = [NUIPSyntaxTree syntaxTreeWithRule:b2 children:[NSArray arrayWithObject:[NUIPKeywordToken tokenWithKeyword:@"b"]] tagValues:[NSDictionary dictionary]];
    NUIPSyntaxTree *abTree = [NUIPSyntaxTree syntaxTreeWithRule:b1 children:[NSArray arrayWithObjects:[NUIPKeywordToken tokenWithKeyword:@"a"], bTree, nil] tagValues:[NSDictionary dictionary]];
    NUIPSyntaxTree *aabTree = [NUIPSyntaxTree syntaxTreeWithRule:b1 children:[NSArray arrayWithObjects:[NUIPKeywordToken tokenWithKeyword:@"a"], abTree, nil] tagValues:[NSDictionary dictionary]];
    NUIPSyntaxTree *aaabTree = [NUIPSyntaxTree syntaxTreeWithRule:b1 children:[NSArray arrayWithObjects:[NUIPKeywordToken tokenWithKeyword:@"a"], aabTree, nil] tagValues:[NSDictionary dictionary]];
    NUIPSyntaxTree *sTree = [NUIPSyntaxTree syntaxTreeWithRule:s children:[NSArray arrayWithObjects:aaabTree, abTree, nil] tagValues:[NSDictionary dictionary]];
    
    STAssertEqualObjects(tree, sTree, @"Parsing LR(1) grammar failed when using LALR(1) parser", nil);
}

- (void)testBNFGrammarGeneration
{
    NUIPTokeniser *tokeniser = [[[NUIPTokeniser alloc] init] autorelease];
    [tokeniser addTokenRecogniser:[NUIPNumberRecogniser integerRecogniser]];
    [tokeniser addTokenRecogniser:[NUIPWhiteSpaceRecogniser whiteSpaceRecogniser]];
    [tokeniser addTokenRecogniser:[NUIPKeywordRecogniser recogniserForKeyword:@"+"]];
    [tokeniser addTokenRecogniser:[NUIPKeywordRecogniser recogniserForKeyword:@"*"]];
    [tokeniser addTokenRecogniser:[NUIPKeywordRecogniser recogniserForKeyword:@"("]];
    [tokeniser addTokenRecogniser:[NUIPKeywordRecogniser recogniserForKeyword:@")"]];
    [tokeniser setDelegate:[[[NUIPTestWhiteSpaceIgnoringDelegate alloc] init] autorelease]];
    NUIPTokenStream *tokenStream = [tokeniser tokenise:@"5 + (2 * 5 + 9) * 8"];
    
    NUIPRule *e1 = [NUIPRule ruleWithName:@"e" rightHandSideElements:[NSArray arrayWithObjects:[NUIPGrammarSymbol nonTerminalWithName:@"t"], nil] tag:0];
    NUIPRule *e2 = [NUIPRule ruleWithName:@"e" rightHandSideElements:[NSArray arrayWithObjects:[NUIPGrammarSymbol nonTerminalWithName:@"e"], [NUIPGrammarSymbol terminalWithName:@"+"], [NUIPGrammarSymbol nonTerminalWithName:@"t"], nil] tag:1];
    
    NUIPRule *t1 = [NUIPRule ruleWithName:@"t" rightHandSideElements:[NSArray arrayWithObjects:[NUIPGrammarSymbol nonTerminalWithName:@"f"], nil] tag:2];
    NUIPRule *t2 = [NUIPRule ruleWithName:@"t" rightHandSideElements:[NSArray arrayWithObjects:[NUIPGrammarSymbol nonTerminalWithName:@"t"], [NUIPGrammarSymbol terminalWithName:@"*"], [NUIPGrammarSymbol nonTerminalWithName:@"f"], nil] tag:3];
    
    NUIPRule *f1 = [NUIPRule ruleWithName:@"f" rightHandSideElements:[NSArray arrayWithObjects:[NUIPGrammarSymbol terminalWithName:@"Number"], nil] tag:4];
    NUIPRule *f2 = [NUIPRule ruleWithName:@"f" rightHandSideElements:[NSArray arrayWithObjects:[NUIPGrammarSymbol terminalWithName:@"("], [NUIPGrammarSymbol nonTerminalWithName:@"e"], [NUIPGrammarSymbol terminalWithName:@")"], nil] tag:5];
    
    NUIPGrammar *grammar = [NUIPGrammar grammarWithStart:@"e" rules:[NSArray arrayWithObjects:e1,e2,t1,t2,f1,f2, nil]];
    NSString *testGrammar =
        @"0 e ::= <t>;"
        @"1 e ::= <e> '+' <t>;"
        @"2 t ::= <f>;"
        @"3 t ::= <t> '*' <f>;"
        @"4 f ::= 'Number';"
        @"5 f ::= '(' <e> ')';";
    NUIPGrammar *grammar1 = [NUIPGrammar grammarWithStart:@"e" backusNaurForm:testGrammar error:NULL];
    
    STAssertEqualObjects(grammar, grammar1, @"Crating grammar from BNF failed", nil);
        
    NUIPParser *parser = [NUIPSLRParser parserWithGrammar:grammar];
    [parser setDelegate:[[[NUIPTestEvaluatorDelegate alloc] init] autorelease]];
    NSNumber *result = [parser parse:tokenStream];
    
    STAssertEquals([result intValue], 157, @"Parsed expression had incorrect value", nil);
}

- (void)testSingleQuotesInGrammars
{
    NSString *testGrammar1 =
        @"e ::= <t>;"
        @"e ::= <e> \"+\" <t>;"
        @"t ::= <f>;"
        @"t ::= <t> \"*\" <f>;"
        @"f ::= \"Number\";"
        @"f ::= \"(\" <e> \")\";";
    NSString *testGrammar2 =
        @"e ::= <t>;"
        @"e ::= <e> '+' <t>;"
        @"t ::= <f>;"
        @"t ::= <t> '*' <f>;"
        @"f ::= \"Number\";"
        @"f ::= '(' <e> ')';";
    
    STAssertEqualObjects([NUIPGrammar grammarWithStart:@"e" backusNaurForm:testGrammar1 error:NULL], [NUIPGrammar grammarWithStart:@"e" backusNaurForm:testGrammar2 error:NULL], @"Grammars using double and single quotes were not equal", nil);
}

- (void)testMapCSSTokenisationPt
{
    [self setUpMapCSS];
    NUIPTokenStream *t1 = [mapCssTokeniser tokenise:@"way { jam: 0.0 pt; }"];
    NUIPTokenStream *t2 = [NUIPTokenStream tokenStreamWithTokens:[NSArray arrayWithObjects:
                                                              [NUIPKeywordToken tokenWithKeyword:@"way"],
                                                              [NUIPWhiteSpaceToken whiteSpace:@" "],
                                                              [NUIPKeywordToken tokenWithKeyword:@"{"],
                                                              [NUIPIdentifierToken tokenWithIdentifier:@"jam"],
                                                              [NUIPKeywordToken tokenWithKeyword:@":"],
                                                              [NUIPNumberToken tokenWithNumber:[NSNumber numberWithFloat:0.0f]],
                                                              [NUIPKeywordToken tokenWithKeyword:@"pt"],
                                                              [NUIPKeywordToken tokenWithKeyword:@";"],
                                                              [NUIPKeywordToken tokenWithKeyword:@"}"],
                                                              [NUIPEOFToken eof],
                                                              nil]];
    STAssertEqualObjects(t1, t2, @"Tokenised MapCSS with size specifier incorrectly", nil);
    
    [self tearDownMapCSS];
}

- (void)testMapCSSParsing
{
    [self setUpMapCSS];
    NUIPSyntaxTree *tree = [mapCssParser parse:[mapCssTokeniser tokenise:mapCssInput]];
    
    STAssertNotNil(tree, @"Failed to parse MapCSS", nil);
    
    [self tearDownMapCSS];
}

- (void)testParallelParsing
{
    [self setUpMapCSS];
    NUIPTokenStream *stream = [[[NUIPTokenStream alloc] init] autorelease];
    [NSThread detachNewThreadSelector:@selector(runMapCSSTokeniser:) toTarget:self withObject:stream];
    NUIPSyntaxTree *tree1 = [mapCssParser parse:stream];
    NUIPSyntaxTree *tree2 = [mapCssParser parse:[mapCssTokeniser tokenise:mapCssInput]];
    
    STAssertEqualObjects(tree1, tree2, @"Parallel parse of MapCSS failed", nil);
    
    [self tearDownMapCSS];
}

- (void)testParseResultParsing
{
    NUIPTokeniser *tokeniser = [[[NUIPTokeniser alloc] init] autorelease];
    [tokeniser addTokenRecogniser:[NUIPNumberRecogniser integerRecogniser]];
    [tokeniser addTokenRecogniser:[NUIPWhiteSpaceRecogniser whiteSpaceRecogniser]];
    [tokeniser addTokenRecogniser:[NUIPKeywordRecogniser recogniserForKeyword:@"+"]];
    [tokeniser setDelegate:[[[NUIPTestWhiteSpaceIgnoringDelegate alloc] init] autorelease]];
    NUIPTokenStream *tokenStream = [tokeniser tokenise:@"5 + 9 + 2 + 7"];
    
    NSString *testGrammar =
        @"Expression ::= <Term> | <Expression> '+' <Term>;"
        @"Term       ::= 'Number';";
    NUIPGrammar *grammar = [NUIPGrammar grammarWithStart:@"Expression" backusNaurForm:testGrammar error:NULL];
    NUIPParser *parser = [NUIPSLRParser parserWithGrammar:grammar];
    Expression *e = [parser parse:tokenStream];
    
    STAssertEquals([e value], 23.0f, @"Parsing with ParseResult protocol produced incorrect result: %f", [e value]);
}

- (void)runMapCSSTokeniser:(NUIPTokenStream *)result
{
    @autoreleasepool
    {
        [mapCssTokeniser tokenise:mapCssInput into:result];
    }
}

- (void)testJSONParsing
{
    NUIPJSONParser *jsonParser = [[[NUIPJSONParser alloc] init] autorelease];
    id<NSObject> result = [jsonParser parse:@"{\"a\":\"b\", \"c\":true, \"d\":5.93, \"e\":[1,2,3], \"f\":null}"];
    
    NSDictionary *expectedResult = [NSDictionary dictionaryWithObjectsAndKeys:
                                    @"b"                             , @"a",
                                    [NSNumber numberWithBool:YES]    , @"c",
                                    [NSNumber numberWithDouble:5.93] , @"d",
                                    [NSArray arrayWithObjects:
                                     [NSNumber numberWithDouble:1],
                                     [NSNumber numberWithDouble:2],
                                     [NSNumber numberWithDouble:3],
                                     nil]                            , @"e",
                                    [NSNull null]                    , @"f",
                                    nil];
    STAssertEqualObjects(result, expectedResult, @"Failed to parse JSON", nil);
}

- (void)testEBNFStar
{
    NSError *err = nil;
    NUIPTokeniser *tokeniser = [[[NUIPTokeniser alloc] init] autorelease];
    [tokeniser addTokenRecogniser:[NUIPKeywordRecogniser recogniserForKeyword:@"a"]];
    [tokeniser addTokenRecogniser:[NUIPKeywordRecogniser recogniserForKeyword:@"b"]];
    NUIPTokenStream *tokenStream = [tokeniser tokenise:@"baaa"];
    NSString *starGrammarString = @"A ::= 'b''a'*;";
    NUIPGrammar *starGrammar = [NUIPGrammar grammarWithStart:@"A" backusNaurForm:starGrammarString error:&err];
    STAssertNil(err, @"Error was not nil after creating valid grammar.");
    NUIPParser *starParser = [NUIPLALR1Parser parserWithGrammar:starGrammar];
    NUIPSyntaxTree *starTree = [starParser parse:tokenStream];
    
    STAssertNotNil(starTree, @"EBNF star parser produced nil result", nil);
    NSArray *as = [[starTree children] objectAtIndex:1];
    if (![[(NUIPKeywordToken *)[[starTree children] objectAtIndex:0] keyword] isEqualToString:@"b"] ||
        [as count] != 3 ||
        ![[(NUIPKeywordToken *)[as objectAtIndex:0] keyword] isEqualToString:@"a"] ||
        ![[(NUIPKeywordToken *)[as objectAtIndex:1] keyword] isEqualToString:@"a"] ||
        ![[(NUIPKeywordToken *)[as objectAtIndex:2] keyword] isEqualToString:@"a"])
    {
        STFail(@"EBNF star parser did not correctly parse its result", nil);
    }
}

- (void)testEBNFTaggedStar
{
    NSError *err = nil;
    NUIPTokeniser *tokeniser = [[[NUIPTokeniser alloc] init] autorelease];
    [tokeniser addTokenRecogniser:[NUIPKeywordRecogniser recogniserForKeyword:@"a"]];
    [tokeniser addTokenRecogniser:[NUIPKeywordRecogniser recogniserForKeyword:@"b"]];
    NUIPTokenStream *tokenStream = [tokeniser tokenise:@"baaa"];
    NSString *taggedStarGrammarString = @"A ::= c@b@'b' a@'a'*;";
    NUIPGrammar *taggedStarGrammar = [NUIPGrammar grammarWithStart:@"A" backusNaurForm:taggedStarGrammarString error:&err];
    STAssertNil(err, @"Error was not nil after creating valid grammar.");
    NUIPParser *taggedStarParser = [NUIPLALR1Parser parserWithGrammar:taggedStarGrammar];
    NUIPSyntaxTree *taggedStarTree = [taggedStarParser parse:tokenStream];
    STAssertNotNil(taggedStarTree, @"EBNF tagged star parser produced nil result", nil);
    NSArray *as = [[taggedStarTree children] objectAtIndex:1];
    if (![[(NUIPKeywordToken *)[[taggedStarTree children] objectAtIndex:0] keyword] isEqualToString:@"b"] ||
        [as count] != 3 ||
        ![[(NUIPKeywordToken *)[as objectAtIndex:0] keyword] isEqualToString:@"a"] ||
        ![[(NUIPKeywordToken *)[as objectAtIndex:1] keyword] isEqualToString:@"a"] ||
        ![[(NUIPKeywordToken *)[as objectAtIndex:2] keyword] isEqualToString:@"a"] ||
        ![[[taggedStarTree valueForTag:@"b"] keyword] isEqualToString:@"b"] ||
        ![[[taggedStarTree valueForTag:@"c"] keyword] isEqualToString:@"b"] ||
        ![[taggedStarTree valueForTag:@"a"] isEqualToArray:as])
    {
        STFail(@"EBNF tagged star parser did not correctly parse its result", nil);
    }
}

- (void)testEBNFPlus
{
    NSError *err = nil;
    NUIPTokeniser *tokeniser = [[[NUIPTokeniser alloc] init] autorelease];
    [tokeniser addTokenRecogniser:[NUIPKeywordRecogniser recogniserForKeyword:@"a"]];
    [tokeniser addTokenRecogniser:[NUIPKeywordRecogniser recogniserForKeyword:@"b"]];
    NUIPTokenStream *tokenStream = [tokeniser tokenise:@"baaa"];
    NSString *plusGrammarString = @"A ::= 'b''a'+;";
    NUIPGrammar *plusGrammar = [NUIPGrammar grammarWithStart:@"A" backusNaurForm:plusGrammarString error:&err];
    STAssertNil(err, @"Error was not nil after creating valid grammar.");
    NUIPParser *plusParser = [NUIPLALR1Parser parserWithGrammar:plusGrammar];
    NUIPSyntaxTree *plusTree = [plusParser parse:tokenStream];
    STAssertNotNil(plusTree, @"EBNF plus parser produced nil result", nil);
    NSArray *as = [[plusTree children] objectAtIndex:1];
    if (![[(NUIPKeywordToken *)[[plusTree children] objectAtIndex:0] keyword] isEqualToString:@"b"] ||
        [as count] != 3 ||
        ![[(NUIPKeywordToken *)[as objectAtIndex:0] keyword] isEqualToString:@"a"] ||
        ![[(NUIPKeywordToken *)[as objectAtIndex:1] keyword] isEqualToString:@"a"] ||
        ![[(NUIPKeywordToken *)[as objectAtIndex:2] keyword] isEqualToString:@"a"])
    {
        STFail(@"EBNF plus parser did not correctly parse its result", nil);
    }
}

- (void)testEBNFQuery
{
    NSError *err = nil;
    NUIPTokeniser *tokeniser = [[[NUIPTokeniser alloc] init] autorelease];
    [tokeniser addTokenRecogniser:[NUIPKeywordRecogniser recogniserForKeyword:@"a"]];
    [tokeniser addTokenRecogniser:[NUIPKeywordRecogniser recogniserForKeyword:@"b"]];
    NUIPTokenStream *tokenStream = [tokeniser tokenise:@"baaa"];
    NSString *queryGrammarString = @"A ::= 'b''a''a''a''a'?;";
    NUIPGrammar *queryGrammar = [NUIPGrammar grammarWithStart:@"A" backusNaurForm:queryGrammarString error:&err];
    STAssertNil(err, @"Error was not nil after creating valid grammar.");
    NUIPParser *queryParser = [NUIPLALR1Parser parserWithGrammar:queryGrammar];
    NUIPSyntaxTree *queryTree = [queryParser parse:tokenStream];
    STAssertNotNil(queryTree, @"EBNF query parser produced nil result", nil);
    NSArray *as = [[queryTree children] objectAtIndex:4];
    if (![[(NUIPKeywordToken *)[[queryTree children] objectAtIndex:0] keyword] isEqualToString:@"b"] ||
        ![[(NUIPKeywordToken *)[[queryTree children] objectAtIndex:1] keyword] isEqualToString:@"a"] ||
        ![[(NUIPKeywordToken *)[[queryTree children] objectAtIndex:2] keyword] isEqualToString:@"a"] ||
        ![[(NUIPKeywordToken *)[[queryTree children] objectAtIndex:3] keyword] isEqualToString:@"a"] ||
        [as count] != 0)
    {
        STFail(@"EBNF query parser did not correctly parse its result", nil);
    }
}

- (void)testEBNFParentheses
{
    NSError *err = nil;
    NUIPTokeniser *tokeniser = [[[NUIPTokeniser alloc] init] autorelease];
    [tokeniser addTokenRecogniser:[NUIPKeywordRecogniser recogniserForKeyword:@"a"]];
    [tokeniser addTokenRecogniser:[NUIPKeywordRecogniser recogniserForKeyword:@"b"]];
    NUIPTokenStream *tokenStream = [tokeniser tokenise:@"baaab"];
    NSString *parenGrammarString = @"A ::= 'b'('a')*'b';";
    NUIPGrammar *parenGrammar = [NUIPGrammar grammarWithStart:@"A" backusNaurForm:parenGrammarString error:&err];
    STAssertNil(err, @"Error was not nil after creating valid grammar.");
    NUIPParser *parenParser = [NUIPLALR1Parser parserWithGrammar:parenGrammar];
    NUIPSyntaxTree *parenTree = [parenParser parse:tokenStream];
    STAssertNotNil(parenTree, @"EBNF paren parser produced nil result", nil);
    NSArray *as = [[parenTree children] objectAtIndex:1];
    if (![[(NUIPKeywordToken *)[[parenTree children] objectAtIndex:0] keyword] isEqualToString:@"b"] ||
        [as count] != 3 ||
        ![[(NUIPKeywordToken *)[(NSArray *)[as objectAtIndex:0] objectAtIndex:0] keyword] isEqualToString:@"a"] ||
        ![[(NUIPKeywordToken *)[(NSArray *)[as objectAtIndex:1] objectAtIndex:0] keyword] isEqualToString:@"a"] ||
        ![[(NUIPKeywordToken *)[(NSArray *)[as objectAtIndex:2] objectAtIndex:0] keyword] isEqualToString:@"a"])
    {
        STFail(@"EBNF paren parser did not correctly parse its result", nil);
    }
}

- (void)testEBNFParenthesesWithOr
{
    NSError *err = nil;
    NUIPTokeniser *tokeniser = [[[NUIPTokeniser alloc] init] autorelease];
    [tokeniser addTokenRecogniser:[NUIPKeywordRecogniser recogniserForKeyword:@"a"]];
    [tokeniser addTokenRecogniser:[NUIPKeywordRecogniser recogniserForKeyword:@"b"]];
    [tokeniser addTokenRecogniser:[NUIPKeywordRecogniser recogniserForKeyword:@"c"]];
    NSString *parenWithOrGrammarString = @"A ::= 'b'('a' | 'c')*'b';";
    NUIPGrammar *parenWithOrGrammar = [NUIPGrammar grammarWithStart:@"A" backusNaurForm:parenWithOrGrammarString error:&err];
    STAssertNil(err, @"Error was not nil after creating valid grammar.");
    NUIPParser *parenWithOrParser = [NUIPLALR1Parser parserWithGrammar:parenWithOrGrammar];
    NUIPTokenStream *tokenStream = [tokeniser tokenise:@"bacab"];
    NUIPSyntaxTree *parenWithOrTree = [parenWithOrParser parse:tokenStream];
    STAssertNotNil(parenWithOrTree, @"EBNF paran parser with or produced nil result", nil);
    NSArray *as = [[parenWithOrTree children] objectAtIndex:1];
    if (![[(NUIPKeywordToken *)[[parenWithOrTree children] objectAtIndex:0] keyword] isEqualToString:@"b"] ||
        [as count] != 3 ||
        ![[(NUIPKeywordToken *)[(NSArray *)[as objectAtIndex:0] objectAtIndex:0] keyword] isEqualToString:@"a"] ||
        ![[(NUIPKeywordToken *)[(NSArray *)[as objectAtIndex:1] objectAtIndex:0] keyword] isEqualToString:@"c"] ||
        ![[(NUIPKeywordToken *)[(NSArray *)[as objectAtIndex:2] objectAtIndex:0] keyword] isEqualToString:@"a"])
    {
        STFail(@"EBNF paren parser with or did not correctly parse its result", nil);
    }
}

- (void)testEBNFFaultyGrammars
{
    NSError *err = nil;
    NSString *faultyGrammar = @"A ::= ::= )( ::=;";
    NUIPGrammar *errorTestGrammar = [NUIPGrammar grammarWithStart:@"A" backusNaurForm:faultyGrammar error:&err];
    STAssertNotNil(err, @"Error was nil after trying to create faulty grammar.");
    STAssertNil(errorTestGrammar, @"Error test grammar was not nil despite being faulty.");
    
    faultyGrammar = @"A ::= b@'b' b@'a'*;";
    errorTestGrammar = [NUIPGrammar grammarWithStart:@"A" backusNaurForm:faultyGrammar error:&err];
    STAssertNotNil(err, @"Error was nil after using the same tag twice in a grammar rule.");
    faultyGrammar = @"A ::= b@'b' (a@'a')*;";
    errorTestGrammar = [NUIPGrammar grammarWithStart:@"A" backusNaurForm:faultyGrammar error:&err];
    STAssertNotNil(err, @"Error was nil after using a tag within a repeating section of a grammar rule.");
}

- (void)testEncodingAndDecodingOfParsers
{
    [self setUpMapCSS];
    
    NSData *d = [NSKeyedArchiver archivedDataWithRootObject:mapCssTokeniser];
    NUIPTokeniser *mapCssTokeniser2 = [NSKeyedUnarchiver unarchiveObjectWithData:d];
    [mapCssTokeniser2 setDelegate:[mapCssTokeniser delegate]];
    NUIPTokenStream *tokenStream = [mapCssTokeniser tokenise:mapCssInput];
    NUIPTokenStream *tokenStream2 = [mapCssTokeniser2 tokenise:mapCssInput];
    
    STAssertEqualObjects(tokenStream, tokenStream2, @"Failed to encode and decode MapCSSTokeniser", nil);
    
    d = [NSKeyedArchiver archivedDataWithRootObject:mapCssParser];
    NUIPParser *mapCssParser2 = [NSKeyedUnarchiver unarchiveObjectWithData:d];
    NUIPSyntaxTree *tree = [mapCssParser2 parse:tokenStream];
    
    STAssertNotNil(tree, @"Failed to encode and decode MapCSSParser", nil);
    
    [self tearDownMapCSS];
}

- (void)testParserErrors
{
    NUIPTokeniser *tokeniser = [[[NUIPTokeniser alloc] init] autorelease];
    [tokeniser addTokenRecogniser:[NUIPKeywordRecogniser recogniserForKeyword:@"a"]];
    [tokeniser addTokenRecogniser:[NUIPKeywordRecogniser recogniserForKeyword:@"b"]];
    NSString *starGrammarString = @"A ::= 'b''a'*;";
    NUIPGrammar *starGrammar = [NUIPGrammar grammarWithStart:@"A" backusNaurForm:starGrammarString error:NULL];
    NUIPParser *starParser = [NUIPLALR1Parser parserWithGrammar:starGrammar];
    
    NUIPTokenStream *faultyTokenStream = [tokeniser tokenise:@"baab"];
    NUIPTokenStream *corretTokenStream = [tokeniser tokenise:@"baa"];
    NUIPTestErrorHandlingDelegate *errorDelegate = [[[NUIPTestErrorHandlingDelegate alloc] init] autorelease];
    [starParser setDelegate:errorDelegate];
    NUIPSyntaxTree *faultyTree = [starParser parse:faultyTokenStream];
    STAssertTrue([errorDelegate hasEncounteredError], @"Error did not get reported to delegate", nil);
    
    NUIPSyntaxTree *correctTree = [starParser parse:corretTokenStream];
    STAssertEqualObjects(faultyTree, correctTree, @"Error in input stream was not correctly dealt with", nil);
}

- (void)testErrorRecovery
{
    NUIPTokeniser *tokeniser = [[[NUIPTokeniser alloc] init] autorelease];
    [tokeniser addTokenRecogniser:[NUIPNumberRecogniser integerRecogniser]];
    [tokeniser addTokenRecogniser:[NUIPWhiteSpaceRecogniser whiteSpaceRecogniser]];
    [tokeniser addTokenRecogniser:[NUIPKeywordRecogniser recogniserForKeyword:@"+"]];
    [tokeniser addTokenRecogniser:[NUIPKeywordRecogniser recogniserForKeyword:@"*"]];
    [tokeniser addTokenRecogniser:[NUIPKeywordRecogniser recogniserForKeyword:@"("]];
    [tokeniser addTokenRecogniser:[NUIPKeywordRecogniser recogniserForKeyword:@")"]];
    [tokeniser setDelegate:[[[NUIPTestWhiteSpaceIgnoringDelegate alloc] init] autorelease]];
    NUIPTokenStream *tokenStream = [tokeniser tokenise:@"5 + + (2 * error + 3) * 8"];
    
    NSString *testGrammar =
      @"0 e ::= <t>;"
      @"1 e ::= <e> '+' <t>;"
      @"1 e ::= 'Error' '+' <t>;"
      @"1 e ::= <e> '+' 'Error';"
      @"2 t ::= <f>;"
      @"3 t ::= <t> '*' <f>;"
      @"3 t ::= 'Error' '*' <f>;"
      @"3 t ::= <t> '*' 'Error';"
      @"4 f ::= 'Number';"
      @"5 f ::= '(' <e> ')';";
    NUIPGrammar *grammar = [NUIPGrammar grammarWithStart:@"e" backusNaurForm:testGrammar error:NULL];
    
    NUIPParser *parser = [NUIPSLRParser parserWithGrammar:grammar];
    [parser setDelegate:[[[NUIPTestErrorEvaluatorDelegate alloc] init] autorelease]];
    NSNumber *result = [parser parse:tokenStream];
    
    STAssertEquals([result intValue], 45, @"Parsed expression had incorrect value", nil);
}

- (void)testConformsToProtocol
{
    NUIPTokeniser *tokeniser = [[[NUIPTokeniser alloc] init] autorelease];
    [tokeniser addTokenRecogniser:[NUIPNumberRecogniser integerRecogniser]];
    [tokeniser addTokenRecogniser:[NUIPWhiteSpaceRecogniser whiteSpaceRecogniser]];
    [tokeniser addTokenRecogniser:[NUIPKeywordRecogniser recogniserForKeyword:@"+"]];
    [tokeniser setDelegate:[[[NUIPTestWhiteSpaceIgnoringDelegate alloc] init] autorelease]];
    NUIPTokenStream *tokenStream = [tokeniser tokenise:@"5 + 9 + 2 + 7"];
    
    NSString *testGrammar =
    @"Expression2 ::= <Term2> | <Expression2> '+' <Term2>;"
    @"Term2      ::= 'Number';";
    NUIPGrammar *grammar = [NUIPGrammar grammarWithStart:@"Expression2" backusNaurForm:testGrammar error:NULL];
    NUIPParser *parser = [NUIPSLRParser parserWithGrammar:grammar];
    Expression *e = [parser parse:tokenStream];
    
    STAssertEquals([e value], 23.0f, @"'conformToProtocol' failed", [e value]);
}

- (void)testValidGrammar
{
    NSString *bnf =
      @"A ::= <B> <C>;"
      @"B ::= 'B';";
    NSError *err = nil;
    NUIPGrammar *grammar = [NUIPGrammar grammarWithStart:@"A" backusNaurForm:bnf error:&err];
    STAssertNil(grammar, @"Grammar returned for invalid BNF");
    STAssertNotNil(err, @"No error returned for creating a grammar with invalid BNF");
}

@end
