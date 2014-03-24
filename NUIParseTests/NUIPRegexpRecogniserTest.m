//
//  NUIPRegexpRecogniserTest.m
//  NUIParse
//
//  Created by Francis Chong on 1/22/14.
//  Copyright (c) 2014 In The Beginning... All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "NUIPRegexpRecogniser.h"
#import "NUIPKeywordToken.h"

@interface NUIPRegexpRecogniserTest : SenTestCase

@end

@implementation NUIPRegexpRecogniserTest

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testRecognizeRegexp
{
    NSUInteger position = 0;
    NUIPRegexpRecogniser* recognizer = [[NUIPRegexpRecogniser alloc] initWithRegexp:[[NSRegularExpression alloc] initWithPattern:@"[a-z]+" options:0 error:nil]
                                                                       matchHandler:^NUIPToken *(NSString *tokenString, NSTextCheckingResult *match) {
                                                                           NSString* matchedString = [tokenString substringWithRange:[match range]];
                                                                           return [NUIPKeywordToken tokenWithKeyword:matchedString];
                                                                       }];
    NUIPKeywordToken* token = (NUIPKeywordToken*) [recognizer recogniseTokenInString:@"hello world" currentTokenPosition:&position];
    STAssertEqualObjects([token class], [NUIPKeywordToken class], @"should be keyword token");
    STAssertEqualObjects(@"hello", [token keyword], @"should match the string hello");
    
    position = 5;
    token = (NUIPKeywordToken*) [recognizer recogniseTokenInString:@"hello world" currentTokenPosition:&position];
    STAssertNil(token, @"should not match space");

    position = 6;
    token = (NUIPKeywordToken*) [recognizer recogniseTokenInString:@"hello world" currentTokenPosition:&position];
    STAssertEqualObjects([token class], [NUIPKeywordToken class], @"should be keyword token");
    STAssertEqualObjects(@"world", [token keyword], @"should match the string world");
}

- (void)testReturnNilFromCallbackWillNotSkipContent
{
    NSUInteger position = 0;
    NUIPRegexpRecogniser* recognizer = [[NUIPRegexpRecogniser alloc] initWithRegexp:[[NSRegularExpression alloc] initWithPattern:@"[a-z]+" options:0 error:nil]
                                                                       matchHandler:^NUIPToken *(NSString *tokenString, NSTextCheckingResult *match) {
                                                                           return nil;
                                                                       }];
    NUIPKeywordToken* token = (NUIPKeywordToken*) [recognizer recogniseTokenInString:@"hello world" currentTokenPosition:&position];
    STAssertNil(token, @"should be nil");
    STAssertTrue(position == 0, @"should not skip content if callback return nil");
}

@end
