# PDFSolid Conversion SDK for Mac (Objective-C)

A high-performance Objective-C library for extracting and transforming PDF content — text, images, tables, links, and annotations — into various file formats while preserving the original document layout.

## Supported Conversions

| Output Format | Extension |
| ------------- | --------- |
| Word | .docx |
| Excel | .xlsx |
| PowerPoint | .pptx |
| HTML | .html |
| CSV | .csv |
| Image | .png, .jpg, .jpeg, .jpeg2000, .bmp, .tiff, .tga, .gif, .webp |
| Plain Text | .txt |
| Rich Text Format | .rtf |
| Searchable PDF | .pdf |
| OFD | .ofd |
| Structured Data | .json |
| Markdown | .md |

## AI-Powered Document Tools

- **Optical Character Recognition (OCR)** — Recognize text from scanned documents and images.
- **Layout Analysis** — AI-based document structure parsing (paragraphs, tables, figures, etc.).
- **Table Recognition** — Reconstruct table structure including merged cells and borderless tables.
- **Custom AI Engine** — Plug in your own OCR/Layout/Table model via callbacks (SDK v4.1.0+).

## Requirements

| Platform | System Requirements | Development Environment |
| -------- | ------------------- | ----------------------- |
| macOS | macOS 10.14+ (Intel, Apple Silicon) | Xcode 13.0 or higher |
| iOS | iOS 13.0+ | Xcode 13.0+ and iOS SDK 13.0+ |

## Quick Start

### 1. Apply License

```objective-c
#import "conversion.h"
#import "common.h"

ErrorCode code = [LibraryManager licenseVerify:@"LICENSE_KEY"];
if (code != ErrorCodeSuccess) {
    return;
}
```

### 2. Initialize the SDK

```objective-c
[LibraryManager initialize:@"PDFSolid_Conversion_SDK/resource"];
```

### 3. Convert PDF to Word

```objective-c
WordOptions *options = [[WordOptions alloc] init];
options.pageLayoutMode = PageLayoutModeFlow;
options.containImage = YES;
options.containAnnotation = YES;

[CPDFConversion startPDFToWord:@"input.pdf"
                      password:@""
                    outputPath:@"output.docx"
                       options:options];
```

### 4. Convert PDF to Excel

```objective-c
ExcelOptions *options = [[ExcelOptions alloc] init];
options.excelWorksheetOption = ExcelWorksheetForTable;

[CPDFConversion startPDFToExcel:@"input.pdf"
                       password:@""
                     outputPath:@"output.xlsx"
                        options:options];
```

### 5. Convert PDF with OCR

```objective-c
[LibraryManager setDocumentAIModel:@"path/documentai.model"];

WordOptions *options = [[WordOptions alloc] init];
options.enableOCR = YES;
options.languages = @[@(OCRLanguageEnglish)];

[CPDFConversion startPDFToWord:@"scanned.pdf"
                      password:@""
                    outputPath:@"output.docx"
                       options:options];
```

### 6. Release Resources

```objective-c
[LibraryManager releaseDocumentAIModel];
[LibraryManager release];
```

## Running the Demo

### Mac

```shell
cd samples
./RunDemo.sh
```

Output files will be generated in the `samples/output_files` folder.

### iOS

1. Open `samples/IOS_demo.xcodeproj` in Xcode.
2. Connect an iOS device and select the target device.
3. Click Build and Run.

## Package Structure

```
├── doc/           # API reference and developer guide
├── lib/           # SDK dynamic libraries / frameworks
├── samples/       # Sample projects
├── resource/      # DocumentAI model resources
├── legal.txt      # Legal and copyright information
└── release_notes.txt
```

## Key Conversion Options

| Option | Description | Applies To |
| ------ | ----------- | ---------- |
| `containImage` | Include images in output | Word, Excel, PPT, HTML, RTF, JSON, Markdown |
| `containAnnotation` | Retain PDF annotations | Word, Excel, PPT, HTML, RTF, JSON, Markdown |
| `pageLayoutMode` | Flow or Box layout | Word, HTML |
| `enableOCR` | Enable OCR for scanned documents | All text-based formats |
| `enableAILayout` | Enable AI layout analysis | All text-based formats |
| `enableAITableRecognition` | Enable AI table recognition | All text-based formats |
| `pageRanges` | Select specific pages (e.g. "1-3,5,7-9") | All formats |
| `output_document_per_page` | Output one file per PDF page | All formats |
| `fontName` | Set preferred output font | Word, Excel, PPT, Searchable PDF, OFD |
| `formulaToImage` | Convert formulas to images | Word |

## Documentation

- [Developer Guide](doc/developer_guide_objectivec.md) — Comprehensive guide covering all APIs and options.
- [API Reference](doc/api_reference_objectivec.html) — Full API reference documentation.

## License

PDFSolid Conversion SDK is a commercial SDK. A license is required for development and distribution. Contact [support@pdfsolid.com](mailto:support@pdfsolid.com) for licensing information.

## Support

- Website: [https://www.pdfsolid.com](https://www.pdfsolid.com/)
- Email: [support@pdfsolid.com](mailto:support@pdfsolid.com)
