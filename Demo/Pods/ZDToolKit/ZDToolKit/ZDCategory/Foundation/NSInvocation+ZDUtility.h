//
//  NSInvocation+ZDUtility.h
//  ZDToolKit
//
//  Created by Zero.D.Saber on 2018/3/30.
//
//  Excerpt from ReactiveObjC

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSInvocation (ZDUtility)

// Arguments tuple for the invocation.
//
// The arguments tuple excludes implicit variables `self` and `_cmd`.
//
// See -zd_argumentAtIndex: and -zd_setArgumentAtIndex: for further
// description of the underlying behavior.
@property (nonatomic, copy) NSArray *zd_arguments;

// Sets the argument for the invocation at the given index by unboxing the given
// object based on the type signature of the argument.
//
// This does not support C arrays or unions.
//
// Note that calling this on a char * or const char * argument can cause all
// arguments to be retained.
//
// object - The object to unbox and set as the argument.
// index  - The index of the argument to set.
- (void)zd_setArgument:(id)object atIndex:(NSUInteger)index;

// Gets the argument for the invocation at the given index based on the
// invocation's method signature. The value is then wrapped in the appropriate
// object type.
//
// This does not support C arrays or unions.
//
// index  - The index of the argument to get.
//
// Returns the argument of the invocation, wrapped in an object.
- (id)zd_argumentAtIndex:(NSUInteger)index;

// Gets the return value from the invocation based on the invocation's method
// signature. The value is then wrapped in the appropriate object type.
//
// This does not support C arrays or unions.
//
// Returns the return value of the invocation, wrapped in an object. Voids are
// returned as `nil`.
- (nullable id)zd_returnValue;

@end

NS_ASSUME_NONNULL_END
