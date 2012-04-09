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

+ (id)popOperandOffProgramStack:(NSMutableArray *)stack withParentOperand:(NSString *)parentOperand{
    NSNumber *result = [[NSNumber alloc] initWithDouble:0];
    
    id topOfStack = [stack lastObject];
    if (topOfStack) [stack removeLastObject];
    else if([self.class isOperation:parentOperand]) return @"Insufficient number of operands."; 
    
    if ([topOfStack isKindOfClass:[NSNumber class]]){
        result = topOfStack;
    }
    else if ([topOfStack isKindOfClass:[NSString class]]) // this must be operation
    {
        NSString *operation = topOfStack;
        int argumentsNumber = [self numberOfArguments:operation];
        if(argumentsNumber == 2){  
            id secArg = [self popOperandOffProgramStack:stack withParentOperand:operation];
            if ([secArg isKindOfClass:[NSString class]]) return secArg; // pass Error
            double secArgAsDouble = [secArg doubleValue];
            id firstArg = [self popOperandOffProgramStack:stack withParentOperand:operation];
            if ([firstArg isKindOfClass:[NSString class]]) return firstArg;
            double firstArgAsDouble = [firstArg doubleValue];
            
            if([operation isEqualToString:@"+"]){
                result = [[NSNumber alloc ] initWithDouble:(firstArgAsDouble + secArgAsDouble)];
            }else if([@"*" isEqualToString:operation]){
                result = [[NSNumber alloc] initWithDouble:(firstArgAsDouble * secArgAsDouble)];
            }else if([@"-" isEqualToString:operation]) {
                result = [[NSNumber alloc] initWithDouble:(firstArgAsDouble - secArgAsDouble)];
            }else if([@"/" isEqualToString:operation]){
                if (secArgAsDouble == 0.0) return @"Division by zero.";
                result = [[NSNumber alloc] initWithDouble:(firstArgAsDouble / secArgAsDouble)];
            }
        } else if(argumentsNumber == 1) {
            id firstArg = [self popOperandOffProgramStack:stack withParentOperand:operation];
            if ([firstArg isKindOfClass:[NSString class]]) return firstArg;
            double firstArgAsDouble = [firstArg doubleValue];
            
            if([@"+/-" isEqualToString:operation]){
                result = [[NSNumber alloc] initWithDouble:(-firstArgAsDouble)];
            }else if([@"sin" isEqualToString:operation]){
                result = [[NSNumber alloc] initWithDouble:sin(firstArgAsDouble)];
            }else if([@"cos" isEqualToString:operation]){
                result = [[NSNumber alloc] initWithDouble:cos(firstArgAsDouble)];
            }else if([@"sqrt" isEqualToString:operation]){
                if (firstArgAsDouble < 0) return @"Square root of a negative number.";
                result = [[NSNumber alloc] initWithDouble:sqrt(firstArgAsDouble)];
            }
        }else if([@"π" isEqualToString:operation]){
            result = [[NSNumber alloc] initWithDouble:M_PI];
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

+ (id)runProgram:(id)program{
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

+ (id) runProgram:(id)program usingVariableValues:(NSDictionary *)variableValues{
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
    
    return [self popOperandOffProgramStack:stack withParentOperand:nil];
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

+ (NSString *)descriptionOfTopOfTheStack:(NSMutableArray *)stack withParentOperand:(NSString *) parentOperand{
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
                if([self isOperator:parentOperand preceding:topElement]) format = @"(%@ %@ %@)"; // we need to add parantheses
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
