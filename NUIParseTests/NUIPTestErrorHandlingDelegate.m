//
//  NUIPTestErrorHandlingDelegate.m
//  NUIParse
//
//  Created by Thomas Davie on 05/02/2012.
//  Copyright (c) 2012 In The Beginning... All rights reserved.
//

#import "NUIPTestErrorHandlingDelegate.h"

@implementation NUIPTestErrorHandlingDelegate

@synthesize hasEncounteredError;

- (BOOL)tokeniser:(NUIPTokeniser *)tokeniser shouldConsumeToken:(NUIPToken *)token
{
    return YES;
}

- (NSArray *)tokeniser:(NUIPTokeniser *)tokeniser willProduceToken:(NUIPToken *)token
{
    return [NSArray arrayWithObject:token];
}

- (NSUInteger)tokeniser:(NUIPTokeniser *)tokeniser didNotFindTokenOnInput:(NSString *)input position:(NSUInteger)position error:(NSString **)errorMessage
{
    *errorMessage = @"Found something that wasn't a comment";
    NSRange nextSlashStar = [input rangeOfString:@"/*" options:NSLiteralSearch range:NSMakeRange(position, [input length] - position)];
    return nextSlashStar.location;
}

- (id)parser:(NUIPParser *)parser didProduceSyntaxTree:(NUIPSyntaxTree *)syntaxTree
{
    return syntaxTree;
}

- (NUIPRecoveryAction *)parser:(NUIPParser *)parser didEncounterErrorOnInput:(NUIPTokenStream *)inputStream expecting:(NSSet *)acceptableTokens
{
    hasEncounteredError = YES;
    return [NUIPRecoveryAction recoveryActionDeletingCurrentToken];
}

@end
