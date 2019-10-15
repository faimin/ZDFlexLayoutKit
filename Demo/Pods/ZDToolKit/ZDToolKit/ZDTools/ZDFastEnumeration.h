//
//  ZDFastEnumeration.h
//  ZDToolKit
//
//  Created by Zero.D.Saber on 2018/2/6.
//

#ifndef ZDFastEnumeration_h
#define ZDFastEnumeration_h

// https://gist.github.com/steipete/7e3c69b985165dc23c5ec169b857ff42
@protocol ZDFastEnumeration <NSFastEnumeration>
- (id)zd_enumeratedType;
@end

// Usage: foreach (s, strings) { ... }
#define foreach(element, collection) for (typeof((collection).zd_enumeratedType) element in (collection))

@interface NSArray <ElementType> (ZDFastEnumeration)
<ZDFastEnumeration>

- (ElementType)zd_enumeratedType;

@end

@interface NSSet <ElementType> (ZDFastEnumeration)
<ZDFastEnumeration>

- (ElementType)zd_enumeratedType;

@end

@interface NSDictionary <KeyType, ValueType> (ZDFastEnumeration)
<ZDFastEnumeration>

- (KeyType)zd_enumeratedType;

@end

@interface NSOrderedSet <ElementType> (ZDFastEnumeration)
<ZDFastEnumeration>

- (ElementType)zd_enumeratedType;

@end

@interface NSPointerArray (ZDFastEnumeration) <ZDFastEnumeration>

- (void *)zd_enumeratedType;

@end

@interface NSHashTable <ElementType> (ZDFastEnumeration)
<ZDFastEnumeration>

- (ElementType)zd_enumeratedType;

@end

@interface NSMapTable <KeyType, ValueType> (ZDFastEnumeration)
<ZDFastEnumeration>

- (KeyType)zd_enumeratedType;

@end

@interface NSEnumerator <ElementType> (ZDFastEnumeration)
<ZDFastEnumeration>

- (ElementType)zd_enumeratedType;

@end

#endif /* ZDFastEnumeration_h */

