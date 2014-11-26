/*!
 * MCTWebAppNativeFile.m
 * MCTWebApp
 *
 * Copyright (c) 2014 Ministry Centered Technology
 *
 * Created by Skylar Schipper on 11/25/14
 */

#import "MCTWebAppNativeFile.h"

@interface MCTWebAppNativeFile ()

@property (nonatomic, strong) NSURLSession *session;

@end

@implementation MCTWebAppNativeFile

+ (instancetype)shared {
    static MCTWebAppNativeFile *file;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        file = [[MCTWebAppNativeFile alloc] init];
    });
    return file;
}
- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillTerminate:) name:UIApplicationWillTerminateNotification object:nil];
    }
    return self;
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// MARK: - Cleanup
- (void)applicationWillTerminate:(NSNotification *)notif {
    [[NSFileManager defaultManager] removeItemAtPath:[self directory] error:nil];
}

// MARK: - Setup
- (NSString *)directory {
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:@"mct-app-1000"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    return path;
}

// MARK: - Session
- (NSURLSession *)session {
    return [NSURLSession sharedSession];
}

// MARK: - Download
+ (void)downloadFile:(NSURL *)fileURL completion:(void(^)(NSURL *location, NSError *error))completion {
    [[self shared] downloadFile:fileURL completion:completion];
}

- (void)downloadFile:(NSURL *)fileURL completion:(void(^)(NSURL *location, NSError *error))completion {
    NSString __block *fileName = [[fileURL pathComponents] lastObject];
    
    NSURLSessionDownloadTask *download = [self.session downloadTaskWithRequest:[NSURLRequest requestWithURL:fileURL] completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        if (error) {
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(nil, error);
                });
            }
            return;
        }
        if (fileName.length == 0) {
            fileName = @"file.dat";
        }
        NSString *path = [[self directory] stringByAppendingPathComponent:fileName];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:location.path]) {
            if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
                NSError *removeError = nil;
                if (![[NSFileManager defaultManager] removeItemAtPath:path error:&removeError]) {
                    if (completion) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completion(nil, removeError);
                        });
                    }
                    return;
                }
            }
            NSError *moveError = nil;
            if (![[NSFileManager defaultManager] copyItemAtPath:location.path toPath:path error:&moveError]) {
                if (completion) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(nil, moveError);
                    });
                }
                return;
            }
            
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion([NSURL fileURLWithPath:path], nil);
                });
            }
            return;
        }
        
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil, [NSError errorWithDomain:MCTWebAppNativeFileErrorDomain code:MCTWebAppNativeFileErrorNoFile userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"File couldn't be downloaded.", nil)}]);
            });
        }
    }];
    [download resume];
}

@end

NSString *const MCTWebAppNativeFileErrorDomain = @"MCTWebAppNativeFileErrorDomain";
