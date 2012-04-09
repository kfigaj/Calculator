 //
//  CalculatorBrain.h
//  Calculator
//
//  Created by Krzysztof Figaj on 2/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CalculatorBrain : NSObject

- (void)pushOperand:(double)operand;
- (void)pushVariable:(NSString *)variable;
- (void)pushOperation:(NSString *)operation;
- (void)removeLastElement;
- (void)clear;
@property (nonatomic, readonly) id program;

+ (NSString *)descriptionOfProgram:(id)program;
+ (id)runProgram:(id)program;
+ (id)runProgram:(id)program usingVariableValues:(NSDictionary *)variableValues;
+ (BOOL)isOperation:(NSString *)programElement;
+ (NSSet *)variablesUsedInProgram:(id)program;

@end
