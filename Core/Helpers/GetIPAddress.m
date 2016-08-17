//
//  GetIPAddress.m
//  Package
//
//  Created by Whirlwind on 16/4/18.
//  Copyright © 2016年 taobao. All rights reserved.
//

#import "GetIPAddress.h"
#import <ifaddrs.h>
#import <netinet/in.h>
#import <arpa/inet.h>

NSString *IPAddress() {
    NSString       *address    = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr  = NULL;
    int            success     = 0;

    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            if (temp_addr->ifa_addr->sa_family == AF_INET) {
                // Get NSString from C String
                address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
            }
            temp_addr = temp_addr->ifa_next;
        }
    }

    // Free memory
    freeifaddrs(interfaces);
    return address;
}

