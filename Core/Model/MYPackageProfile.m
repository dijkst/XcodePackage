//
//  MYPackageProfile.m
//  Package
//
//  Created by Whirlwind on 2017/2/8.
//  Copyright © 2017年 taobao. All rights reserved.
//

#import "MYPackageProfile.h"

NSString *profileTypeNameForType(MYPackageProfileType type) {
    switch (type) {
        case MYPackageProfileTypeEnterprise:
            return @"enterprise";
        case MYPackageProfileTypeAdhoc:
            return @"ad-hoc";
        case MYPackageProfileTypeAppStore:
            return @"app-store";
        default:
            return @"development";
    }
}

@implementation MYPackageProfile
@synthesize ApplicationIdentifier = _ApplicationIdentifier;

- (NSString *)ApplicationIdentifier {
    if (_ApplicationIdentifier) {
        return _ApplicationIdentifier;
    }
    NSString *identifier = self.Entitlements[@"application-identifier"];
    for (NSString *prefix in self.ApplicationIdentifierPrefix) {
        if ([identifier hasPrefix:prefix]) {
            identifier = [identifier substringFromIndex:[prefix length] + 1];
            break;
        }
    }
    _ApplicationIdentifier = identifier;
    return _ApplicationIdentifier;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {

}

- (BOOL)isMatchAppBundleID:(NSString *)bundleId {
    NSString *expression = [[self.ApplicationIdentifier stringByReplacingOccurrencesOfString:@"." withString:@"\\."] stringByReplacingOccurrencesOfString:@"*" withString:@".*"];
    NSError *error = nil;

    NSRegularExpression *regExpr =
    [NSRegularExpression regularExpressionWithPattern:expression
                                              options:NSRegularExpressionCaseInsensitive
                                                error:&error];

    NSTextCheckingResult *matchResult = [regExpr firstMatchInString:bundleId
                                                            options:0
                                                              range:NSMakeRange(0, [bundleId length])];
    return matchResult ? YES : NO;
}

- (NSString *)SignCertificate {
    for (NSString *uuid in [self DeveloperCertificates]) {
        if (![uuid isKindOfClass:[NSNull class]]) {
            return uuid;
        }
    }
    return nil;
}

- (MYPackageProfileType)type {
    if ([self.Entitlements[@"get-task-allow"] boolValue]) {
        return MYPackageProfileTypeDevelopment;
    }
    if ([self.Entitlements[@"beta-reports-active"] boolValue]) {
        return MYPackageProfileTypeAppStore;
    }
    return MYPackageProfileTypeAdhoc;
}

- (NSString *)typeName {
    return profileTypeNameForType(self.type);
}

- (NSString *)description {
    if ([self.ApplicationIdentifier isEqualToString:@"*"]) {
        return [NSString stringWithFormat:@"%@ (%@)", self.Name, self.TeamName];
    }
    return self.Name;
}

+ (NSArray<MYPackageProfile *> *)arrayWithJSONObject:(NSArray *)json {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:[json count]];
    [json enumerateObjectsUsingBlock:^(NSDictionary *dict, NSUInteger idx, BOOL * _Nonnull stop) {
        MYPackageProfile *profile = [[MYPackageProfile alloc] init];
        [dict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [profile setValue:obj forKey:key];
        }];
        [array addObject:profile];
    }];
    return array;
}

@end
