#import <Foundation/Foundation.h>
#import <PDFSolid/PDFSolid.h>

#include <cstdio>
#include <cstring>

int main(int argc, const char *argv[]) {
    @autoreleasepool {
        NSString *version = [LibraryManager getVersion];
        printf("PDFSolid SDK version: %s\n", [version UTF8String]);
        if (![version isEqualToString:@"1.2.0"]) {
            fprintf(stderr, "Expected PDFSolid SDK 1.2.0\n");
            return 1;
        }
        if (argc == 2 && strcmp(argv[1], "--version") == 0) {
            return 0;
        }
        if (argc != 5) {
            fprintf(stderr, "Usage: demo <license.xml> <resource-dir> <input.pdf> <output.docx>\n");
            return 2;
        }

        NSString *licensePath = [NSString stringWithUTF8String:argv[1]];
        NSString *resourcePath = [NSString stringWithUTF8String:argv[2]];
        NSString *inputPath = [NSString stringWithUTF8String:argv[3]];
        NSString *outputPath = [NSString stringWithUTF8String:argv[4]];
        NSFileManager *files = [NSFileManager defaultManager];
        NSString *modelPath = [resourcePath stringByAppendingPathComponent:@"models/documentai.model"];
        if (![files fileExistsAtPath:licensePath] || ![files fileExistsAtPath:modelPath] ||
            ![files fileExistsAtPath:inputPath] || [files fileExistsAtPath:outputPath]) {
            fprintf(stderr, "Inputs must exist and output must be a new file\n");
            return 2;
        }

        ErrorCode licenseCode = [LibraryManager licenseVerify:licensePath];
        printf("license_return_code=%ld\n", (long)licenseCode);
        if (licenseCode != ErrorCodeSuccess) {
            [LibraryManager release];
            return 3;
        }

        @try {
            [LibraryManager initialize:resourcePath];
            ErrorCode modelCode = [LibraryManager setDocumentAIModel:modelPath gpuId:-1];
            printf("model_return_code=%ld\n", (long)modelCode);
            if (modelCode != ErrorCodeSuccess) {
                return 4;
            }
            WordOptions *options = [[WordOptions alloc] init];
            ErrorCode conversionCode = [CPDFConversion startPDFToWord:inputPath
                password:@"" outputPath:outputPath options:options];
            printf("conversion_return_code=%ld\n", (long)conversionCode);
            if (conversionCode != ErrorCodeSuccess) {
                return 5;
            }
            NSDictionary *attributes = [files attributesOfItemAtPath:outputPath error:nil];
            unsigned long long size = [attributes fileSize];
            printf("output_bytes=%llu\n", size);
            return size > 0 ? 0 : 6;
        } @finally {
            [LibraryManager release];
        }
    }
}
