# PDFSolid Conversion SDK for Objective-C 1.3.0 Upgrade Warnings

This document lists the considerations that developers should be aware of when upgrading from previous versions to PDFSolid Conversion SDK for Objective-C 1.3.0. Some interfaces and default behaviors have changed, so changes to your code or deployment files may be necessary to make sure your project compiles and produces the expected results with the new version.

**Upgrading to version 1.3.0 from version 1.2.0**

If you are upgrading from version 1.2.0 to version 1.3.0, please note the following changes between 1.2.0 and 1.3.0.

Replace the Objective-C framework and the dynamic libraries in the SDK package with the 1.3.0 versions together and rebuild your project. Existing code keeps compiling: the option classes only gained new properties, and every new property keeps the previous behavior as its default except the table recognition model profile described below.

**Important: The default table recognition model profile has changed.** 1.2.0 used the high-accuracy model by default, while 1.3.0 uses the balanced model by default. After upgrading, even without any code change, table recognition results and resource usage will differ from 1.2.0. If you want to keep the same behavior as 1.2.0, explicitly select the high-accuracy profile and load the table extension package `table_legacy.model` (see the description of the `tableRecognitionAccuracy` option below).

**Important: Upgrade the model file together with the SDK.** The `documentai.model` of 1.2.0 and earlier does not contain the resources required by the balanced profile, while the 1.3.0 model file keeps the same name, so **continuing to use the old file causes model loading to fail. Overwrite the old file in your deployment directory with the `documentai.model` bundled in the 1.3.0 SDK package.** The SDK package bundles the base model `documentai.model` by default, so the default configuration needs no extra download; download the corresponding extension model packages only when you need extended capabilities such as high-accuracy tables, high-accuracy OCR, or orientation correction. For the contents and purposes of the model packages, see "Model Package Reference" in the "Set DocumentAI Model" chapter of the Developer Guide.

In the LibraryManager class:

1. `setDocumentAIModel` now supports incremental loading of model packages. The base package `documentai.model` provides layout analysis, balanced-profile table recognition, and basic OCR; capabilities such as high-accuracy tables, high-accuracy OCR, and orientation correction are provided by extension packages. Each call loads only the capabilities contained in that file and merges them with the capabilities already loaded, without replacing them. Sample code:

   ```objective-c
   // Load the base package.
   [LibraryManager setDocumentAIModel:@"path/documentai.model"];
   // Load an extension package when you need the extended capability.
   // Capabilities that are already loaded are kept.
   [LibraryManager setDocumentAIModel:@"path/table_legacy.model"];
   ```

   If a package fails to load, the capabilities already loaded are kept and a specific error code is returned.

2. The timing of release and configuration has changed. If synchronous conversion tasks are still running when `[LibraryManager release]` is called, the release is deferred until the last task returns, and new tasks are refused in the meantime; `releaseDocumentAIModel` likewise waits for running tasks to return before cleaning up. While tasks are running or a release is still pending, reconfiguring the DocumentAI model is refused and `ErrorCodeConverting` is returned, and `[LibraryManager getPageCount:password:]` returns `-1` while library resources are being released or configured. Unload the SDK only after all conversion calls have returned, and load or reload models only after all conversion tasks have finished.

3. The new `[LibraryManager getLicenseType]` interface returns the type of the currently verified license: `LicenseTypeUnknown`, `LicenseTypeTrial`, or `LicenseTypeFormal`. It does not verify the license again and does not consume page quota. Sample code:

   ```objective-c
   LicenseType type = [LibraryManager getLicenseType];
   if (type == LicenseTypeTrial) {
       // Trial license.
   }
   ```

4. The new `[LibraryManager initialize:scanOfficeFonts:]` interface controls whether initialization scans the font directories of Microsoft Office (the fonts inside Word's application bundle and the Office cloud-font cache). On macOS the cloud-font cache lives in another app's container, and reading it makes macOS 15 and later ask the user to allow access to other apps' data; pass `NO` to skip these directories and avoid the prompt. The existing initialization interface keeps the previous behavior and scans them.

In the CPDFConversion class:

1. Word to PDF is added: `CPDFConversion` provides `startWordToPDF` methods with default options, with `WordOptions`, with progress and cancel blocks, and with a `ConvertCallback` object, plus a method with an `NSString **diagnostics` parameter that returns diagnostic information about features that may affect fidelity. Sample code:

   ```objective-c
   NSString *diagnostics = nil;
   ErrorCode code = [CPDFConversion startWordToPDF:@"input.docx"
                                        outputPath:@"output.pdf"
                                           options:[[WordOptions alloc] init]
                                          progress:nil
                                            cancel:nil
                                       diagnostics:&diagnostics];
   ```

   When the document contains features that may affect fidelity, `ErrorCodeUnsupportedFeature` (95) is returned. The PDF is usually still produced in this case, so **do not assume that no output file exists just because 95 is returned**; check `output=produced` or `output=not_produced` on the first line of the diagnostic text instead. If the conversion itself fails, the real error code is returned and takes precedence over 95; if the diagnostics buffer cannot hold the complete diagnostics, `ErrorCodeOutOfMemory` is returned.

2. Word to PDF reuses `WordOptions` and uses only its `wordPdfBookmarkMode` and `pageRanges`; the other properties are ignored. `wordPdfBookmarkMode` is `WordPdfBookmarkModeNone` (default, no bookmarks), `WordPdfBookmarkModeHeadings` (one bookmark per heading), or `WordPdfBookmarkModeWordBookmarks` (one bookmark per Word bookmark); `pageRanges` specifies the pages to output, e.g. `"1-3,5,7-9"`, and an empty value outputs every page. Sample code:

   ```objective-c
   WordOptions *options = [[WordOptions alloc] init];
   options.wordPdfBookmarkMode = WordPdfBookmarkModeHeadings;
   options.pageRanges = @"1-3,5,7-9";
   [CPDFConversion startWordToPDF:@"input.docx" outputPath:@"output.pdf" options:options callback:callback];
   ```

3. The conversion behavior for image input has changed:
   - When an image is converted to TXT or CSV-format Excel and OCR is not enabled, `ErrorCodeUnsupportedFeature` (95) is now returned; enable `enableOCR`.
   - With OCR off (the default), an image converted to a format that can carry images produces an output document that contains the complete source image and no recognized text.
   - `[CPDFConversion startPDFToImage:password:outputPath:options:]` accepts both PDF and supported image input. Image-to-image conversion does not run OCR or layout analysis and does not depend on any model; multi-page TIFF is converted frame by frame, each selected frame produces one image, and `pageRanges` selects the frames.

In the conversion option classes (such as WordOptions and ExcelOptions):

1. New option `tableRecognitionAccuracy` selects the table recognition model profile. **The default is `TableRecognitionAccuracyBalanced`, which differs from 1.2.0, where the high-accuracy profile was the default.** Selecting `TableRecognitionAccuracyHighAccuracy` requires `table_legacy.model` to be loaded; if it is not loaded, the conversion still succeeds, but tables are recognized with the rule-based method instead, so the result differs from the high-accuracy result. To keep the same behavior as 1.2.0, change the original:

   ```objective-c
   WordOptions *options = [[WordOptions alloc] init];
   [CPDFConversion startPDFToWord:@"input_file" password:@"password" outputPath:@"output_path.docx" options:options];
   ```

   to:

   ```objective-c
   [LibraryManager setDocumentAIModel:@"path/documentai.model"];
   [LibraryManager setDocumentAIModel:@"path/table_legacy.model"];

   WordOptions *options = [[WordOptions alloc] init];
   options.tableRecognitionAccuracy = TableRecognitionAccuracyHighAccuracy;
   [CPDFConversion startPDFToWord:@"input_file" password:@"password" outputPath:@"output_path.docx" options:options];
   ```

   The property is available on every option class that supports table recognition: `WordOptions`, `ExcelOptions`, `PptOptions`, `HtmlOptions`, `RtfOptions`, `TxtOptions`, `JsonOptions`, `MarkdownOptions`, `SearchablePdfOptions` and `OfdOptions`.

2. New option `enableAutoPageSize`: when enabled, the output page size of image conversion is matched to the nearest standard paper size based on the image resolution; when disabled, one image pixel becomes one page point. It only takes effect for image input; the default is `NO`.

3. New options `customPageWidth` and `customPageHeight`, in points (1 point = 1/72 inch). When both are set, they specify the output page size directly and take precedence over `enableAutoPageSize`; the image is scaled proportionally to fit inside the page without cropping. They only take effect for image input; the default is `0`. Sample code:

   ```objective-c
   WordOptions *options = [[WordOptions alloc] init];
   // Option 1: match the nearest standard paper size from the image resolution.
   options.enableAutoPageSize = YES;
   [CPDFConversion startPDFToWord:@"input.png" password:@"" outputPath:@"path/output.docx" options:options];

   // Option 2: specify the page size as A4 (takes precedence over enableAutoPageSize).
   options.customPageWidth = 595.28f;
   options.customPageHeight = 841.89f;
   [CPDFConversion startPDFToWord:@"input.png" password:@"" outputPath:@"path/output_a4.docx" options:options];
   ```
