//
//  CalculatorBrain.m
//  Calculator
//
//  Created by Krzysztof Figaj on 2/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CalculatorBrain.h"

@interface CalculatorBrain()

@property (nonatomic, strong) NSMutableArray *programStack;
@end

@implementation CalculatorBrain
@synthesize programStack = _programStack;

- (NSMutableArray *)programStack{
    if(!_programStack){
        _programStack = [[NSMutableArray alloc] init];
    }
    return _programStack;
}

- (id)program
{
    return [self.programStack copy];
}

+ (NSString *)descriptionOfProgram:(id)program
{
    return @"Implement this in Homework #2";
}

- (void)pushOperand:(double)operand{
    [self.programStack addObject:[NSNumber numberWithDouble:operand]];
}

- (double)performOperation:(NSString *)operation{
    [self.programStack addObject:operation];
    return [[self class] runProgram:self.program];
}

+ (double)popOperandOffProgramStack:(NSMutableArray *)stack{

    double result = 0;
    
    id topOfStack = [stack lastObject];
    if (topOfStack) [stack removeLastObject];
    
    if ([topOfStack isKindOfClass:[NSNumber class]])
    {
        result = [topOfStack doubleValue];
    }
    else if ([topOfStack isKindOfClass:[NSString class]])
    {
        NSString *operation = topOfStack;
        if([operation isEqualToString:@"+"]){
            result = [self popOperandOffProgramStack:stack] + [self popOperandOffProgramStack:stack];
        }else if([@"*" isEqualToString:operation]){
            result = [self popOperandOffProgramStack:stack] * [self popOperandOffProgramStack:stack];
        }else if([@"-" isEqualToString:operation]){
            double secArg = [self popOperandOffProgramStack:stack];
            result = [self popOperandOffProgramStack:stack] - secArg;
        }else if([@"/" isEqualToString:operation]){
            double secArg = [self popOperandOffProgramStack:stack];
            if(secArg) result = [self popOperandOffProgramStack:stack] / secArg;
        }else if([@"+/-" isEqualToString:operation]){
            result = -[self popOperandOffProgramStack:stack];
        }else if([@"sin" isEqualToString:operation]){
            result = sin([self popOperandOffProgramStack:stack]);
        }else if([@"cos" isEqualToString:operation]){
            result = cos([self popOperandOffProgramStack:stack]);
        }else if([@"sqrt" isEqualToString:operation]){
            result = sqrt([self popOperandOffProgramStack:stack]);
        }else if([@"π" isEqualToString:operation]){
            result = M_PI;
        }
    }
    
    return result;
}

- (void)clear{
    [self.programStack removeAllObjects];
}

+ (double)runProgram:(id)program
{
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    return [self popOperandOffProgramStack:stack];
}

@end
