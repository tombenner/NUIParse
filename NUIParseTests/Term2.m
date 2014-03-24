//
//  Term2.m
//  NUIParse
//
//  Created by Ayal Spitz on 10/4/12.
//  Copyright (c) 2012 In The Beginning... All rights reserved.
//

#import "Term2.h"

@implementation Term2

@synthesize value;

- (id)initWithSyntaxTree:(NUIPSyntaxTree *)syntaxTree{
    self = [super init];
    if (nil != self){
        [self setValue:[[(NUIPNumberToken *)[[syntaxTree children] objectAtIndex:0] number] floatValue]];
    }
    
    return self;
}

@end
