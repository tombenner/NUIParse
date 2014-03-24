//
//  NUIPTestWhiteSpaceIgnoringDelegate.m
//  NUIParse
//
//  Created by Tom Davie on 15/03/2011.
//  Copyright 2011 In The Beginning... All rights reserved.
//

#import "NUIPTestWhiteSpaceIgnoringDelegate.h"

@implementation NUIPTestWhiteSpaceIgnoringDelegate

- (BOOL)tokeniser:(NUIPTokeniser *)tokeniser shouldConsumeToken:(NUIPToken *)token
{
    return YES;
}

- (void)tokeniser:(NUIPTokeniser *)tokeniser requestsToken:(NUIPToken *)token pushedOntoStream:(NUIPTokenStream *)stream
{
    if (![token isWhiteSpaceToken])
    {
        [stream pushToken:token];
    }
}

- (NSUInteger)tokeniser:(NUIPTokeniser *)tokeniser didNotFindTokenOnInput:(NSString *)input position:(NSUInteger)position error:(NSString **)errorMessage
{
    *errorMessage = @"Found something that wasn't a numeric expression";
    NSRange nextSafeStuff = [input rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"1234567890+*()"] options:NSLiteralSearch range:NSMakeRange(position, [input length] - position)];
    return nextSafeStuff.location;
}

@end
