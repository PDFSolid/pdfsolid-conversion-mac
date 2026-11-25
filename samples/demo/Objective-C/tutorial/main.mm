#import <Foundation/Foundation.h>
#import <PDFSolid/PDFSolid.h>
#include <stdio.h>

static void printResult(const char *name, ErrorCode err) {
    printf("%s: %ld\n", name, (long)err);
}

int main(int argc, const char *argv[]) {
    @autoreleasepool {
        NSString *licensePath = (argc > 1 && argv[1][0] != '\0')
            ? [NSString stringWithUTF8String:argv[1]]
            : @"../../../resource/license/license.xml";
        NSString *resourcePath = @"../../../resource";
        NSString *modelPath = @"../../../resource/models/documentai.model";
        NSString *inputDir = @"../../input_files";
        NSString *outputDir = @"../../output_files";

        NSString *version = [LibraryManager getVersion];
        printf("pdfsolid conversion sdk version: %s\n", version.UTF8String ?: "");

        ErrorCode licErr = [LibraryManager licenseVerify:licensePath];
        printResult("pdfsolid conversion sdk license verify", licErr);
        if (licErr != ErrorCodeSuccess) {
            return 3;
        }

        [LibraryManager initialize:resourcePath scanOfficeFonts:NO];
        [LibraryManager setLogger:NO enableWarning:NO];

        ErrorCode modelErr = [LibraryManager setDocumentAIModel:modelPath gpuId:-1];
        printResult("set document ai model", modelErr);
        if (modelErr != ErrorCodeSuccess) {
            [LibraryManager release];
            return 4;
        }

        int failures = 0;
        COMProgressBlock progress = ^(int current, int total) {
            printf("convert rate: %d/%d\n", current, total);
        };
        COMCancelBlock cancel = ^BOOL(void) { return NO; };

        auto check = [&](const char *label, ErrorCode err, BOOL allowUnsupported = NO) {
            printResult(label, err);
            if (err != ErrorCodeSuccess && !(allowUnsupported && err == ErrorCodeUnsupportedFeature)) {
                failures++;
            }
        };

        NSString *wordPdf = [inputDir stringByAppendingPathComponent:@"word.pdf"];
        NSString *excelPdf = [inputDir stringByAppendingPathComponent:@"excel.pdf"];
        NSString *pptPdf = [inputDir stringByAppendingPathComponent:@"powerpoint.pdf"];
        NSString *wordDocx = [inputDir stringByAppendingPathComponent:@"word.docx"];

        check("pdf to word", [CPDFConversion startPDFToWord:wordPdf password:@"" outputPath:[outputDir stringByAppendingPathComponent:@"word.docx"] options:[[WordOptions alloc] init] progress:progress cancel:cancel]);
        check("pdf to excel", [CPDFConversion startPDFToExcel:excelPdf password:@"" outputPath:[outputDir stringByAppendingPathComponent:@"excel.xlsx"] options:[[ExcelOptions alloc] init] progress:progress cancel:cancel]);
        check("pdf to ppt", [CPDFConversion startPDFToPpt:pptPdf password:@"" outputPath:[outputDir stringByAppendingPathComponent:@"powerpoint.pptx"] options:[[PptOptions alloc] init] progress:progress cancel:cancel]);
        ExcelOptions *csvOpt = [[ExcelOptions alloc] init];
        csvOpt.CSVFormat = YES;
        check("pdf to csv", [CPDFConversion startPDFToExcel:excelPdf password:@"" outputPath:outputDir options:csvOpt progress:progress cancel:cancel]);
        check("pdf to html", [CPDFConversion startPDFToHtml:wordPdf password:@"" outputPath:[outputDir stringByAppendingPathComponent:@"html.html"] options:[[HtmlOptions alloc] init] progress:progress cancel:cancel]);
        check("pdf to rtf", [CPDFConversion startPDFToRtf:wordPdf password:@"" outputPath:[outputDir stringByAppendingPathComponent:@"rtf.rtf"] options:[[RtfOptions alloc] init] progress:progress cancel:cancel]);
        check("pdf to image", [CPDFConversion startPDFToImage:wordPdf password:@"" outputPath:outputDir options:[[ImageOptions alloc] init] progress:progress cancel:cancel]);
        check("pdf to txt", [CPDFConversion startPDFToTxt:wordPdf password:@"" outputPath:[outputDir stringByAppendingPathComponent:@"txt.txt"] options:[[TxtOptions alloc] init] progress:progress cancel:cancel]);
        check("pdf to json", [CPDFConversion startPDFToJson:wordPdf password:@"" outputPath:[outputDir stringByAppendingPathComponent:@"json.json"] options:[[JsonOptions alloc] init] progress:progress cancel:cancel]);
        check("pdf to markdown", [CPDFConversion startPDFToMarkdown:wordPdf password:@"" outputPath:[outputDir stringByAppendingPathComponent:@"markdown.md"] options:[[MarkdownOptions alloc] init] progress:progress cancel:cancel]);

        SearchablePdfOptions *spdfOpt = [[SearchablePdfOptions alloc] init];
        spdfOpt.languages = @[@(OCRLanguageEnglish)];
        check("pdf to searchable pdf", [CPDFConversion startPDFToSearchablePDF:wordPdf password:@"" outputPath:[outputDir stringByAppendingPathComponent:@"pdf.pdf"] options:spdfOpt progress:progress cancel:cancel]);

        OfdOptions *ofdOpt = [[OfdOptions alloc] init];
        ofdOpt.languages = @[@(OCRLanguageEnglish)];
        check("pdf to ofd", [CPDFConversion startPDFToOFD:wordPdf password:@"" outputPath:[outputDir stringByAppendingPathComponent:@"pdf.ofd"] options:ofdOpt progress:progress cancel:cancel]);

        WordOptions *w2pDefault = [[WordOptions alloc] init];
        check("word to pdf", [CPDFConversion startWordToPDF:wordDocx outputPath:[outputDir stringByAppendingPathComponent:@"word_to_pdf.pdf"] options:w2pDefault progress:progress cancel:cancel], YES);

        WordOptions *w2pOpt = [[WordOptions alloc] init];
        w2pOpt.wordPdfBookmarkMode = WordPdfBookmarkModeHeadings;
        w2pOpt.pageRanges = @"1-2";
        NSString *diagnostics = nil;
        check("word to pdf with options", [CPDFConversion startWordToPDF:wordDocx outputPath:[outputDir stringByAppendingPathComponent:@"word_to_pdf_bookmarks.pdf"] options:w2pOpt progress:progress cancel:cancel diagnostics:&diagnostics], YES);
        if (diagnostics.length > 0) {
            printf("word to pdf diagnostics:\n%s\n", diagnostics.UTF8String);
        }

        [LibraryManager releaseDocumentAIModel];
        [LibraryManager release];
        return failures == 0 ? 0 : 5;
    }
}
