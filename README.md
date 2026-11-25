# PDFSolid Conversion SDK for macOS (Objective-C)

High-performance Objective-C SDK for converting PDF to Word, Excel, PowerPoint, HTML, Image, TXT, RTF, CSV, JSON, Markdown, Searchable PDF, and OFD with AI-powered OCR, layout analysis, and table recognition. SDK v1.3.0 also converts Word documents (`.docx`) to PDF.

## Features

- **PDF to Word** (.docx) — Flow and Box layout modes
- **Word to PDF** (.docx → .pdf) — optional page ranges and PDF bookmarks
- **PDF to Excel** (.xlsx) — per-table, per-page, or per-document worksheet options
- **PDF to PowerPoint** (.pptx)
- **PDF to HTML** (.html) — single/multi-page with optional bookmark navigation
- **PDF to CSV** (.csv)
- **PDF to Image** (.png, .jpg, .jpeg, .jpeg2000, .bmp, .tiff, .tga, .gif, .webp) — color/grayscale/binary, configurable scaling
- **Image to Image** — supported image inputs, including individual frames of multi-page TIFF files
- **PDF to Plain Text** (.txt) — optional table format preservation
- **PDF to RTF** (.rtf)
- **PDF to Searchable PDF** (.pdf) — OCR with transparent text layer
- **PDF to OFD** (.ofd) — OCR, page background preservation, transparent text layer
- **PDF to JSON** (.json) — structured data with table extraction
- **PDF to Markdown** (.md)

### AI-Powered Document Tools

- **OCR** — Optical Character Recognition for scanned documents and images
- **Layout Analysis** — AI-based document structure parsing
- **Table Recognition** — AI-based table structure reconstruction
- **Custom AI Models** — plug in your own OCR, layout, or table engine via callbacks (SDK v1.1.0+)

## Requirements

| Platform | System Requirements | Development Environment |
| -------- | ------------------- | ----------------------- |
| macOS | macOS 11.0+ (Intel x86_64, Apple Silicon arm64) | Xcode 13.0+ |
| iOS | iOS 13.0+ (arm64 device; separate iOS SDK package, no simulator slice) | Xcode 13.0+ |

## Quick Start

### 1. Get a License

Contact [sales@pdfsolid.com](mailto:sales@pdfsolid.com) for a 30-day free trial or commercial license.

### 2. Apply License and Initialize

```objective-c
#import "conversion.h"
#import "common.h"

ErrorCode code = [LibraryManager licenseVerify:@"LICENSE_KEY"];
if (code != ErrorCodeSuccess) {
    return;
}
[LibraryManager initialize:@"PDFSolid_Conversion_SDK/resource"];
```

### 3. Convert

```objective-c
WordOptions *options = [[WordOptions alloc] init];
[CPDFConversion startPDFToWord:@"input.pdf"
                      password:@""
                    outputPath:@"output.docx"
                       options:options];
```

### Release Resources

```objective-c
[LibraryManager releaseDocumentAIModel];
[LibraryManager release];
```

## Conversion Examples

### Word (DOCX) to PDF

After applying the license and initializing the SDK, pass the input `.docx` path and a writable output `.pdf` path.

```objective-c
#import "conversion.h"

ErrorCode result = [CPDFConversion startWordToPDF:@"input.docx" outputPath:@"output.pdf"];
```

The default converts all pages without PDF bookmarks. With the `startWordToPDF:outputPath:options:` overload, set `WordOptions.pageRanges` to select pages (for example, `1-2`) and `WordOptions.wordPdfBookmarkMode` to generate bookmarks from headings or Word bookmarks. Check the returned status before using the PDF. `ErrorCodeUnsupportedFeature` means the input contains features that may affect fidelity; a PDF may still have been written.

For the diagnostics overload, see the [public header](include/conversion.h). Use the macOS framework on macOS and the separate iOS SDK framework on physical iOS devices.

### PDF to Excel

```objective-c
ExcelOptions *options = [[ExcelOptions alloc] init];
options.excelWorksheetOption = ExcelWorksheetForTable;
[CPDFConversion startPDFToExcel:@"input.pdf"
                       password:@""
                     outputPath:@"output.xlsx"
                        options:options];
```

### PDF to Image

```objective-c
ImageOptions *options = [[ImageOptions alloc] init];
options.imageType = ImageTypePNG;
options.imageScaling = 2.0;
[CPDFConversion startPDFToImage:@"input.pdf"
                       password:@""
                     outputPath:@"output"
                        options:options];
```

### PDF to Searchable PDF (OCR)

```objective-c
[LibraryManager setDocumentAIModel:@"path/model"];

SearchablePdfOptions *options = [[SearchablePdfOptions alloc] init];
options.enableOCR = YES;
options.languages = @[@(OCRLanguageEnglish)];
options.transparentText = YES;
[CPDFConversion startPDFToSearchablePDF:@"scan.pdf"
                               password:@""
                             outputPath:@"output.pdf"
                                options:options];
```

### PDF to JSON with Table Extraction

```objective-c
JsonOptions *options = [[JsonOptions alloc] init];
options.containTable = YES;
[CPDFConversion startPDFToJson:@"input.pdf"
                      password:@""
                    outputPath:@"output.json"
                       options:options];
```

### Custom AI Engine (SDK v1.1.0+)

```objective-c
// Implement ConvertCallback protocol with custom OCR/Layout/Table handlers
// and pass the callback object to the conversion API.

WordOptions *options = [[WordOptions alloc] init];
options.enableOCR = YES;
options.enableAILayout = YES;
[CPDFConversion startPDFToWord:@"input.pdf"
                      password:@""
                    outputPath:@"output.docx"
                       options:options
                      callback:customCallback];
```

## Documentation

- [Developer Guide](doc/developer_guide_objectivec.md)
- [API Reference](doc/api_reference_objectivec.html)

## Contact

- Website: [https://www.pdfsolid.com](https://www.pdfsolid.com/)
- Sales: [sales@pdfsolid.com](mailto:sales@pdfsolid.com)
- Support: [support@pdfsolid.com](mailto:support@pdfsolid.com)
