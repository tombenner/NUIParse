//
//  Expression.h
//  NUIParse
//
//  Created by Thomas Davie on 26/06/2011.
//  Copyright 2011 In The Beginning... All rights reserved.
//

#import <Foundation/Foundation.h>

#import <NUIParse/NUIParse.h>

@interface Expression : NSObject <NUIPParseResult>

@property (readwrite,assign) float value;

@end
