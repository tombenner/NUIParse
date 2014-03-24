//
//  NUIPTestErrorEvaluatorDelegate.m
//  NUIParse
//
//  Created by Thomas Davie on 05/02/2012.
//  Copyright (c) 2012 In The Beginning... All rights reserved.
//

#import "NUIPTestErrorEvaluatorDelegate.h"

@implementation NUIPTestErrorEvaluatorDelegate

- (id)parser:(NUIPParser *)parser didProduceSyntaxTree:(NUIPSyntaxTree *)syntaxTree
{
    NUIPRule *r = [syntaxTree rule];
    NSArray *c = [syntaxTree children];
    
    switch ([r tag])
    {
        case 0:
        case 2:
            return [c objectAtIndex:0];
        case 1:
        {
            int v1 = [[c objectAtIndex:0] isErrorToken] ? 0.0 : [[c objectAtIndex:0] intValue];
            int v2 = [[c objectAtIndex:2] isErrorToken] ? 0.0 : [[c objectAtIndex:2] intValue];
            return [NSNumber numberWithInt:v1 + v2];
        }
        case 3:
        {
            int v1 = [[c objectAtIndex:0] isErrorToken] ? 1.0 : [[c objectAtIndex:0] intValue];
            int v2 = [[c objectAtIndex:2] isErrorToken] ? 1.0 : [[c objectAtIndex:2] intValue];
            return [NSNumber numberWithInt:v1 * v2];
        }
        case 4:
            return [(NUIPNumberToken *)[c objectAtIndex:0] number];
        case 5:
            return [c objectAtIndex:1];
        default:
            return syntaxTree;
    }
}

- (NUIPRecoveryAction *)parser:(NUIPParser *)parser didEncounterErrorOnInput:(NUIPTokenStream *)inputStream expecting:(NSSet *)acceptableTokens
{
    return [NUIPRecoveryAction recoveryActionWithAdditionalToken:[NUIPErrorToken errorWithMessage:@"Expected expression"]];
}

@end
