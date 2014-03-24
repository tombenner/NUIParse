//
//  NUIPSTAssertionsTests.m
//  NUIParse
//
//  Created by Christopher Miller on 5/18/12.
//  Copyright (c) 2012 In The Beginning... All rights reserved.
//

#import "NUIPSTAssertionsTests.h"
#import "NUIParse.h"
#import "NUIPSenTestKitAssertions.h"

@implementation NUIPSTAssertionsTests

#pragma mark Tokenization Tests

- (void)testTokenizerKeywordAssertions
{
    NUIPTokeniser * tk = [[NUIPTokeniser alloc] init];
    [tk addTokenRecogniser:[NUIPKeywordRecogniser recogniserForKeyword:@"{"]];
    [tk addTokenRecogniser:[NUIPKeywordRecogniser recogniserForKeyword:@"}"]];
    
    /* 2012-05-18 11:01:17.780 otest[3862:403] ts: <Keyword: {> <Keyword: }> <EOF> */
    NUIPTokenStream * ts = [tk tokenise:@"{}"];
    NUIPSTAssertKeywordEquals([ts popToken], @"{");
    NUIPSTAssertKeywordEquals([ts popToken], @"}");
    NUIPSTAssertKindOfClass([ts popToken], NUIPEOFToken);
}

- (void)testTokenizerIdentifierAssertion
{
    NUIPIdentifierToken * t = [NUIPIdentifierToken tokenWithIdentifier:@"foobar"];
    NUIPSTAssertIdentifierEquals(t, @"foobar");
}

- (void)testTokenizerNumberAssertions
{
    NUIPTokeniser * qTokenizer = [[NUIPTokeniser alloc] init];
    NUIPTokeniser * dTokenizer = [[NUIPTokeniser alloc] init];
    NUIPTokeniser * russianRoulette = [[NUIPTokeniser alloc] init];
    [qTokenizer addTokenRecogniser:[NUIPNumberRecogniser integerRecogniser]];
    [dTokenizer addTokenRecogniser:[NUIPNumberRecogniser floatRecogniser]];
    [russianRoulette addTokenRecogniser:[NUIPNumberRecogniser numberRecogniser]];
    
    // test basic ideas about how to recognize numbers
    NSString * qs = @"1337", * ds_us = @"13.37", * ds_uk = @"13,37";
    NSInteger q = 1337, qa = 1336, qa_v = 1, qe = 13, qea = 12, qea_v = 1;
    double d = 13.37, da = 12.37, da_v = 1.00f;
    
    NUIPTokenStream * ts = [qTokenizer tokenise:qs];
    NUIPSTAssertIntegerNumberEquals([ts peekToken], q);
    NUIPSTAssertIntegerNumberEqualsWithAccuracy([ts popToken], qa, qa_v);
    NUIPSTAssertKindOfClass([ts popToken], NUIPEOFToken);
    
    ts = [qTokenizer tokenise:ds_us];
    NUIPSTAssertIntegerNumberEquals([ts peekToken], qe);
    NUIPSTAssertIntegerNumberEqualsWithAccuracy([ts popToken], qea, qea_v);
    NUIPSTAssertKindOfClass([ts popToken], NUIPErrorToken);
    
    ts = [qTokenizer tokenise:ds_uk];
    NUIPSTAssertIntegerNumberEquals([ts peekToken], qe);
    NUIPSTAssertIntegerNumberEqualsWithAccuracy([ts popToken], qea, qea_v);
    NUIPSTAssertKindOfClass([ts popToken], NUIPErrorToken);

    // for some reason, the default tokenizer always uses floating point
    ts = [russianRoulette tokenise:qs];
    NUIPSTAssertFloatingNumberEquals([ts peekToken], q);
    NUIPSTAssertFloatingNumberEqualsWithAccuracy([ts popToken], qa, qa_v);
    NUIPSTAssertKindOfClass([ts popToken], NUIPEOFToken);
    
    ts = [russianRoulette tokenise:ds_us];
    NUIPSTAssertFloatingNumberEquals([ts peekToken], d);
    NUIPSTAssertFloatingNumberEqualsWithAccuracy([ts popToken], da, da_v);
    NUIPSTAssertKindOfClass([ts popToken], NUIPEOFToken);
    
    ts = [russianRoulette tokenise:ds_uk];
    NUIPSTAssertFloatingNumberEquals([ts peekToken], qe);
    NUIPSTAssertFloatingNumberEqualsWithAccuracy([ts popToken], qea, qea_v);
    NUIPSTAssertKindOfClass([ts popToken], NUIPErrorToken);
    
    ts = [dTokenizer tokenise:qs];
    NUIPSTAssertKindOfClass([ts popToken], NUIPErrorToken);
    
    ts = [dTokenizer tokenise:ds_us];
    NUIPSTAssertFloatingNumberEquals([ts peekToken], d);
    NUIPSTAssertFloatingNumberEqualsWithAccuracy([ts popToken], da, da_v);
    NUIPSTAssertKindOfClass([ts popToken], NUIPEOFToken);
    
    ts = [dTokenizer tokenise:ds_uk];
    NUIPSTAssertKindOfClass([ts popToken], NUIPErrorToken);
    
}

@end
