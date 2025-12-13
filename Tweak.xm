#import <Foundation/Foundation.h>
#import <substrate.h>
#import <objc/runtime.h>

// File logger
static NSString *logPath = @"/var/mobile/logappstorethinning.log";

static void LogToFile(NSString *format, ...) {
    va_list args;
    va_start(args, format);
    NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    NSString *timestamp = [NSDateFormatter localizedStringFromDate:[NSDate date]
                                                         dateStyle:NSDateFormatterShortStyle
                                                         timeStyle:NSDateFormatterMediumStyle];
    NSString *logMessage = [NSString stringWithFormat:@"[%@] %@\n", timestamp, message];
    
    // Append to file
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:logPath];
    if (fileHandle) {
        [fileHandle seekToEndOfFile];
        [fileHandle writeData:[logMessage dataUsingEncoding:NSUTF8StringEncoding]];
        [fileHandle closeFile];
    } else {
        // Create file if doesn't exist
        [logMessage writeToFile:logPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
}

#define LOG(FORMAT, ...) LogToFile(FORMAT, ##__VA_ARGS__)

// Spoof target
NSString *spoofedDevice = @"iPad8,6";

// Hook existing suspects
%hook SSDevice
- (NSString *)productType {
    NSString *result = %orig;
    LOG(@"SSDevice productType called, returning: %@ (original: %@)", spoofedDevice, result);
    return spoofedDevice;
}
- (NSString *)compatibleProductType {
    NSString *result = %orig;
    LOG(@"SSDevice compatibleProductType called, returning: %@ (original: %@)", spoofedDevice, result);
    return spoofedDevice;
}
%end

%hook AMSDevice
+ (NSString *)productType {
    NSString *result = %orig;
    LOG(@"AMSDevice productType called, returning: %@ (original: %@)", spoofedDevice, result);
    return spoofedDevice;
}
+ (NSString *)compatibleProductType {
    NSString *result = %orig;
    LOG(@"AMSDevice compatibleProductType called, returning: %@ (original: %@)", spoofedDevice, result);
    return spoofedDevice;
}
%end

// Log download attempts
%hook SSDownloadQueue
- (void)addDownload:(id)download {
    LOG(@"SSDownloadQueue addDownload: %@", download);
    %orig;
}
%end

%hook SSPurchase
- (instancetype)initWithBuyParameters:(id)params {
    LOG(@"SSPurchase initWithBuyParameters: %@", params);
    return %orig;
}
- (NSString *)buyParameters {
    NSString *result = %orig;
    LOG(@"SSPurchase buyParameters: %@", result);
    return result;
}
%end

%hook SSPurchaseRequest
- (void)startWithPurchaseResponseBlock:(id)block {
    LOG(@"SSPurchaseRequest starting...");
    %orig;
}
%end

// Network request logging
%hook NSMutableURLRequest
- (void)setValue:(NSString *)value forHTTPHeaderField:(NSString *)field {
    if ([field containsString:@"Device"] || 
        [field containsString:@"Product"] ||
        [field containsString:@"User-Agent"]) {
        LOG(@"Header set: %@ = %@", field, value);
    }
    %orig;
}
- (void)setURL:(NSURL *)url {
    if ([[url absoluteString] containsString:@"apple.com"]) {
        LOG(@"Request URL: %@", [url absoluteString]);
    }
    %orig;
}
%end

// Runtime class discovery
%ctor {
    LOG(@"===== NoAppThinning Loaded =====");
    LOG(@"Spoofing as: %@", spoofedDevice);
    
    // List all relevant classes
    unsigned int classCount;
    Class *classes = objc_copyClassList(&classCount);
    
    LOG(@"Scanning for relevant classes...");
    for (unsigned int i = 0; i < classCount; i++) {
        const char *className = class_getName(classes[i]);
        NSString *name = [NSString stringWithUTF8String:className];
        
        if ([name containsString:@"Download"] || 
            [name containsString:@"Purchase"] ||
            [name containsString:@"SSDevice"] ||
            [name containsString:@"AMSDevice"] ||
            [name containsString:@"StoreKit"]) {
            LOG(@"Found class: %@", name);
            
            // List methods for interesting classes
            if ([name isEqualToString:@"SSDevice"] || [name isEqualToString:@"AMSDevice"]) {
                unsigned int methodCount;
                Method *methods = class_copyMethodList(classes[i], &methodCount);
                for (unsigned int j = 0; j < methodCount; j++) {
                    SEL selector = method_getName(methods[j]);
                    LOG(@"  Method: %@", NSStringFromSelector(selector));
                }
                free(methods);
            }
        }
    }
    free(classes);
    
    LOG(@"===== Initialization Complete =====");
}
