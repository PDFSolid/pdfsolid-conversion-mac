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

/// Initializes the SDK. Same as initialize:scanOfficeFonts: with scanOfficeFonts YES.
+ (void)initialize:(NSString *)resourcePath;
/// Initializes the SDK.
/// @param resourcePath Path to the resources needed by the SDK. It is not a font source: the converter
///        only picks fonts the reader of the output can also draw, so fonts are taken from the system
///        font directories only.
/// @param scanOfficeFonts YES to also scan the Microsoft Office font directories (Word's application
///        bundle and the Office cloud-font cache). On macOS that cache lives in another app's container,
///        and reading it makes the system ask the user to allow access to other apps' data; pass NO to
///        skip those directories and avoid the prompt. Has no effect on iOS.
+ (void)initialize:(NSString *)resourcePath scanOfficeFonts:(BOOL)scanOfficeFonts;
+ (ErrorCode)licenseVerify:(NSString *)license;
/// Returns the currently verified license type. Returns LicenseTypeUnknown before verification,
/// after a failed verification, or while the library is releasing. Does not consume quota.
+ (LicenseType)getLicenseType;
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