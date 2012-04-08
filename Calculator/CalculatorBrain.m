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
+ (NSSet *)implementedOperations;
+ (BOOL)isOperation:(NSString *)programElement;
+ (int)numberOfArguments:(NSString *)operation;
+ (BOOL)isOperator:(NSString*)firstOperator preceding:(NSString *)secondOperator;
@end

static NSSet *operations = nil; // singleton to keep implemented operations

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

- (void)pushOperand:(double)operand{
    [self.programStack addObject:[NSNumber numberWithDouble:operand]];
}

- (void)pushVariable:(NSString *)variable{
    if (![self.class isOperation:variable]) {
        [self.programStack addObject:variable];
    }
}

- (void)pushOperation:(NSString *)operation{
    [self.programStack addObject:operation];
}

- (void)clear{
    [self.programStack removeAllObjects];
}

- (void) removeLastElement {
    [self.programStack removeLastObject];
}

+ (double)popOperandOffProgramStack:(NSMutableArray *)stack{

    double result = 0;
    
    id topOfStack = [stack lastObject];
    if (topOfStack) [stack removeLastObject];
    
    if ([topOfStack isKindOfClass:[NSNumber class]]){
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

+ (NSSet *)implementedOperations{
    if(operations == nil){
        operations = [[NSSet alloc] initWithObjects:@"+", @"-", @"*", @"/", @"+/-", @"sin", @"cos", @"sqrt", @"π", nil];
    }
    return operations;
}

+ (BOOL)isOperation:(NSString *)programElement{
    if ([[self.class implementedOperations] containsObject:programElement])
        return YES;
    else
        return NO;
}

+ (double)runProgram:(id)program{
    return [self runProgram:program usingVariableValues:nil];
}

+ (NSSet *)variablesUsedInProgram:(id)program{
    NSMutableSet *result = [[NSMutableSet alloc] init];
    
    for (id element in program) {
        if([element isKindOfClass:[NSString class]] && ![self isOperation:element]){
            [result addObject:element];  
        }
    }
    
    return [result count] ? result: nil;
}

+ (double) runProgram:(id)program usingVariableValues:(NSDictionary *)variableValues{
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    NSSet *variablesInProgram = [self variablesUsedInProgram:program];
    
    for(int i=0; i<[stack count]; i++){
        id element = [stack objectAtIndex:i];
        if([variablesInProgram containsObject:element]){
            NSNumber *value = [variableValues objectForKey:element];
            //default is 0 if no value is given 
            value = value ? value: [[NSNumber alloc] initWithDouble:0];
            [stack replaceObjectAtIndex:i withObject:value];
        }
    }
    
    return [self popOperandOffProgramStack:stack];
}

+ (int)numberOfArguments:(NSString *)operation{
    // determine how many operand has this opertation
    NSSet *twoOperands = [[NSSet alloc] initWithObjects:@"+", @"-", @"*", @"/", nil];
    NSSet *oneOperands = [[NSSet alloc] initWithObjects:@"+/-", @"sin", @"cos", @"sqrt", nil];
    
    if([twoOperands containsObject:operation])
        return 2;
    else if([oneOperands containsObject:operation])
        return 1;
    else
        return 0;
}

+(BOOL)isOperator:(NSString *)firstOperator preceding:(NSString *)secondOperator{
    // helper function to determine precedence between two oparand operations
    NSSet *highOrder = [[NSSet alloc] initWithObjects:@"*", @"/", nil];
    NSSet *lowOrder = [[NSSet alloc] initWithObjects:@"+", @"-", nil];
    
    if([highOrder containsObject:firstOperator] && [lowOrder containsObject:secondOperator])
        return YES;
    else
        return NO;
}

+ (NSString *)descriptionOfTopOfTheStack:(NSMutableArray *)stack withParentOperand:(NSString *) parentOpernad{
    NSString *result = @"0"; // set default result
    
    id topElement = [stack lastObject];
    if(topElement) [stack removeLastObject];
    
    if([topElement isKindOfClass:[NSNumber class]]){ // plain number
        result = [[NSString alloc]initWithFormat:@"%g", [topElement doubleValue]];
    }
    else if([topElement isKindOfClass:[NSString class]]){
        if([self isOperation:topElement]){ // operation
            int argumentsNumber = [self numberOfArguments:topElement];
            if(argumentsNumber == 2){  
                NSString *format = @"%@ %@ %@";// standard format for 2 arguments operations
                if([self isOperator:parentOpernad preceding:topElement]) format = @"(%@ %@ %@)"; // we need to add parantheses
                NSString *secondOperand = [self descriptionOfTopOfTheStack:stack withParentOperand:topElement];
                result = [[NSString alloc]initWithFormat:format, [self descriptionOfTopOfTheStack:stack withParentOperand:topElement], topElement, secondOperand];
            }else if(argumentsNumber == 1) // functions operator
                result = [[NSString alloc]initWithFormat:@"%@(%@)", topElement, [self descriptionOfTopOfTheStack:stack withParentOperand:topElement]];
            else // operator PI is left
                result = topElement;    
        } 
        else { // variable
            result = topElement;
        }
    }
    return result;
}

+ (NSString *)descriptionOfProgram:(id)program{
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    NSString *result = @"";
    while([stack count]){ // stack has formulas
        result = [result stringByAppendingString:[self descriptionOfTopOfTheStack:stack withParentOperand:nil]];
        if ([stack count]) result = [result stringByAppendingString:@", "]; // append formulas by comma
    }
    
    return result;
}

@end
