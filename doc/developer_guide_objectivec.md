# PDFSolid Conversion SDK 1.2.0 for macOS

## Requirements

- Apple Silicon or Intel running macOS 11.0+, required by bundled AI libraries.
- Xcode command line tools and CMake 3.20+ for the command-line example.
- A valid PDFSolid license. The supplied license is in
  `resource/license/license.xml`; online verification requires network access.

## Package Layout

- `lib/PDFSolid.framework`: Objective-C API, universal arm64/x86_64.
- `lib/*.dylib`: native PDFSolid, DocumentAI, OpenCV and ONNX Runtime.
- `resource/models/documentai.model`: model required by the macOS sample.
- `samples/demo`: runnable PDF-to-Word command-line example.
- `doc/html/index.html`: API reference generated from this framework's headers.

## Run the Example

From the package root:

```sh
bash samples/demo/RunDemo.sh
```

The example verifies SDK version 1.2.0, validates the license, initializes
the resource directory, loads the model and converts `samples/input_files/word.pdf`.
It reports license, model and conversion results separately. A failed license
or model load stops conversion. Each run creates a new DOCX in `samples/output_files`.

For explicit paths:

```sh
bash samples/demo/RunDemo.sh /path/license.xml /path/resource /path/input.pdf /path/new-output.docx
```

## Integrate

Import `<PDFSolid/PDFSolid.h>` and link `PDFSolid.framework`, Foundation and AppKit.
Keep all four dylibs together beside the framework. For an application bundle,
copy the framework and dylibs into `Contents/Frameworks`, add
`@executable_path/../Frameworks` to the application's runpath search paths,
and sign embedded code with your application's identity after copying.

The framework module is `PDFSolid`. The public classes retain the names
`LibraryManager`, `CPDFConversion`, `WordOptions`, `ExcelOptions` and other
format-specific option classes. Renaming the product does not rename these APIs.

```objc
#import <PDFSolid/PDFSolid.h>

ErrorCode code = [LibraryManager licenseVerify:licensePath];
if (code == ErrorCodeSuccess) {
    [LibraryManager initialize:resourcePath];
    code = [LibraryManager setDocumentAIModel:modelPath gpuId:-1];
    if (code == ErrorCodeSuccess) {
        WordOptions *options = [[WordOptions alloc] init];
        code = [CPDFConversion startPDFToWord:inputPath password:@""
                                 outputPath:outputPath options:options];
    }
}
[LibraryManager release];
```

Use the API reference for format-specific options, OCR, page ranges, orientation
correction and dewarping. Do not overwrite an input document with output.
Library release must run after conversion work has completed.

## Distribution Notes

The binaries carry local ad-hoc signatures, not Developer ID notarization.
Sign and notarize your own application as required by your distribution channel.
iOS is supplied in a separate package; do not use these macOS binaries on iOS.
