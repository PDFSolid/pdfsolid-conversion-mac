#import <Foundation/Foundation.h>
#import "base_type.h"



typedef void (^COMProgressBlock)(int current_page, int total_page);

/// Cancellation callback for long-running operations.
/// Return YES to request cancel; NO to continue.
typedef BOOL (^COMCancelBlock)(void);

@protocol ConvertCallback <NSObject>
@optional
- (void)onProgress:(int)currentPage totalPage:(int)totalPage;
- (BOOL)isCancelled;

- (BOOL)onOcr:(NSString *)imagePath;
- (BOOL)onLayout:(NSString *)imagePath;
- (BOOL)onTable:(NSString *)imagePath;

- (NSString *)getOcrResult;
- (NSString *)getLayoutResult;
- (NSString *)getTableResult;
@end

@interface LibraryManager : NSObject

+ (void)initialize:(NSString *)resourcePath;
+ (ErrorCode)licenseVerify:(NSString *)license;
+ (void)setLogger:(BOOL)enableInfo enableWarning:(BOOL)enableWarning;
+ (ErrorCode)setDocumentAIModel:(NSString *)modelPath;
+ (ErrorCode)setDocumentAIModel:(NSString *)modelPath gpuId:(int)gpuId;
+ (void)setDocumentAIModelCount:(int)layoutModelCount tableModelCount:(int)tableModelCount;
+ (int)getPageCount:(NSString *)filePath 
                password:(NSString *)password;
+ (int)getRemainingPageQuota;
+ (NSString *)getVersion;
+ (void)release;
+ (void)releaseDocumentAIModel;

@end