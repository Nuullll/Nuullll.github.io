---
layout: post
title: "Building llvm-project with Ninja on MacOS"
date: 2021-05-15 22:01:14 +0800
tags: llvm ninja MacOS
description: ninja
---
## Building clang
I just follow the llvm official guide: [Getting the source code and building llvm](https://llvm.org/docs/GettingStarted.html#getting-the-source-code-and-building-llvm).

1. Checking out `llvm-project` using `git clone` is trivial.
2. Configure with CMake
```bash
cd llvm-project && mkdir build && cd build
cmake -G Ninja -DLLVM_ENABLE_PROJECTS='clang' -DCMAKE_BUILD_TYPE=Release ../llvm
```
I enable only the `clang` target and build a `Release` version, to minimize both the code size and build time (takes me ~60 mins), since my laptop is a really old one :P
1. Build with Ninja
```bash
ninja
```
4. Run the test suite
```bash
ninja check-all
# ...
# Testing Time: 1881.93s
#   Unsupported      :  1670
#   Passed           : 69905
#   Expectedly Failed:   180
```
Seems good.

But something unexpected will always happen: the built clang (in `llvm-project/build/bin`) couldn't compile the simple hello world cpp program.
```c++
// test.cpp
#include <iostream>
int main() {
    std::cout << "Hello world" << std::endl;
    return 0;
}
```

The error log:
```bash
clang++ -v
# clang version 13.0.0 (https://github.com/llvm/llvm-project.git 6418bab6f8827960b9d161f5c9c2b8f9702c80e0)
# Target: x86_64-apple-darwin20.4.0
# Thread model: posix
# InstalledDir: /Users/nuullll/Projects/llvm-project/build/bin

clang++ test.cpp
# In file included from test.cpp:1:
# In file included from /usr/local/bin/../include/c++/v1/iostream:37:
# In file included from /usr/local/bin/../include/c++/v1/ios:214:
# In file included from /usr/local/bin/../include/c++/v1/iosfwd:98:
# /usr/local/bin/../include/c++/v1/wchar.h:119:15: fatal error: 'wchar.h' file not found
# #include_next <wchar.h>
#               ^~~~~~~~~
# Assertion failed: (!CodeSynthesisContexts.empty() && "Cannot perform an instantiation without some context on the " "instantiation stack"), function SubstType, file /Users/nuullll/Projects/llvm-project/clang/lib/Sema/SemaTemplateInstantiate.cpp, line 2071.
# PLEASE submit a bug report to https://bugs.llvm.org/ and include the crash backtrace, preprocessed source, and associated run script.
# Stack dump:
# 0.      Program arguments: /usr/local/bin/clang-13 -cc1 -triple x86_64-apple-macosx11.0.0 -Wundef-prefix=TARGET_OS_ -Werror=undef-prefix -Wdeprecated-objc-isa-usage -Werror=deprecated-objc-isa-usage -emit-obj -mrelax-all --mrelax-relocations -disable-free -main-file-name test.cpp -mrelocation-model pic -pic-level 2 -mframe-pointer=all -fno-rounding-math -munwind-tables -fcompatibility-qualified-id-block-type-checking -fvisibility-inlines-hidden-static-local-var -target-cpu penryn -tune-cpu generic -debugger-tuning=lldb -target-linker-version 556.6 -fcoverage-compilation-dir=/Users/nuullll/Projects/playground/cpp -resource-dir /usr/local/lib/clang/13.0.0 -stdlib=libc++ -internal-isystem /usr/local/bin/../include/c++/v1 -internal-isystem /usr/local/include -internal-isystem /usr/local/lib/clang/13.0.0/include -internal-externc-isystem /usr/include -fdeprecated-macro -fdebug-compilation-dir=/Users/nuullll/Projects/playground/cpp -ferror-limit 19 -stack-protector 1 -fblocks -fencode-extended-block-signature -fregister-global-dtors-with-atexit -fgnuc-version=4.2.1 -fcxx-exceptions -fexceptions -fmax-type-align=16 -fcolor-diagnostics -D__GCC_HAVE_DWARF2_CFI_ASM=1 -o /var/folders/33/3kb7_j8x61q5l57tn2wk4xl80000gn/T/test-25fb8d.o -x c++ test.cpp
# 1.      /usr/local/bin/../include/c++/v1/type_traits:1693:4: current parser token ':'
# 2.      /usr/local/bin/../include/c++/v1/type_traits:427:1 <Spelling=/usr/local/bin/../include/c++/v1/__config:789:37>: parsing namespace 'std'
# 3.      /usr/local/bin/../include/c++/v1/type_traits:427:1 <Spelling=/usr/local/bin/../include/c++/v1/__config:789:60>: parsing namespace 'std::__1'
# Stack dump without symbol names (ensure you have llvm-symbolizer in your PATH or set the environment var `LLVM_SYMBOLIZER_PATH` to point to it):
# 0  clang-13                 0x000000010491bbdb llvm::sys::PrintStackTrace(llvm::raw_ostream&, int) + 43
# 1  clang-13                 0x000000010491a858 llvm::sys::RunSignalHandlers() + 248
# 2  clang-13                 0x000000010491c247 SignalHandler(int) + 295
# 3  libsystem_platform.dylib 0x00007fff20525d7d _sigtramp + 29
# 4  libsystem_platform.dylib 0x0000000000000001 _sigtramp + 18446603339973894817
# 5  libsystem_c.dylib        0x00007fff20435411 abort + 120
# 6  libsystem_c.dylib        0x00007fff204347e8 err + 0
# 7  clang-13                 0x000000010895ce43 clang::Sema::SubstType(clang::TypeSourceInfo*, clang::MultiLevelTemplateArgumentList const&, clang::SourceLocation, clang::DeclarationName, bool) (.cold.1) + 35
# 8  clang-13                 0x0000000106a458b1 clang::Sema::SubstType(clang::TypeSourceInfo*, clang::MultiLevelTemplateArgumentList const&, clang::SourceLocation, clang::DeclarationName, bool) + 161
# 9  clang-13                 0x0000000106a4ceef clang::Sema::SubstParmVarDecl(clang::ParmVarDecl*, clang::MultiLevelTemplateArgumentList const&, int, llvm::Optional<unsigned int>, bool) + 367
# 10 clang-13                 0x0000000106a4e21a clang::TreeTransform<(anonymous namespace)::TemplateInstantiator>::TransformFunctionTypeParams(clang::SourceLocation, llvm::ArrayRef<clang::ParmVarDecl*>, clang::QualType const*, clang::FunctionType::ExtParameterInfo const*, llvm::SmallVectorImpl<clang::QualType>&, llvm::SmallVectorImpl<clang::ParmVarDecl*>*, clang::Sema::ExtParameterInfoBuilder&) + 1098
# 11 clang-13                 0x0000000106a74809 clang::QualType clang::TreeTransform<(anonymous namespace)::TemplateInstantiator>::TransformFunctionProtoType<clang::TreeTransform<(anonymous namespace)::TemplateInstantiator>::TransformFunctionProtoType(clang::TypeLocBuilder&, clang::FunctionProtoTypeLoc)::'lambda'(clang::FunctionProtoType::ExceptionSpecInfo&, bool&)>(clang::TypeLocBuilder&, clang::FunctionProtoTypeLoc, clang::CXXRecordDecl*, clang::Qualifiers, clang::TreeTransform<(anonymous namespace)::TemplateInstantiator>::TransformFunctionProtoType(clang::TypeLocBuilder&, clang::FunctionProtoTypeLoc)::'lambda'(clang::FunctionProtoType::ExceptionSpecInfo&, bool&)) + 1097
# 12 clang-13                 0x0000000106a48b7c clang::TreeTransform<(anonymous namespace)::TemplateInstantiator>::TransformType(clang::TypeLocBuilder&, clang::TypeLoc) + 11340
# 13 clang-13                 0x0000000106a4655c clang::TreeTransform<(anonymous namespace)::TemplateInstantiator>::TransformType(clang::TypeLocBuilder&, clang::TypeLoc) + 1580
# 14 clang-13                 0x0000000106a4640b clang::TreeTransform<(anonymous namespace)::TemplateInstantiator>::TransformType(clang::TypeLocBuilder&, clang::TypeLoc) + 1243
# 15 clang-13                 0x0000000106a45c17 clang::TreeTransform<(anonymous namespace)::TemplateInstantiator>::TransformType(clang::TypeSourceInfo*) + 199
# 16 clang-13                 0x0000000106a6bcce clang::TreeTransform<(anonymous namespace)::TemplateInstantiator>::TransformCXXNamedCastExpr(clang::CXXNamedCastExpr*) + 30
# 17 clang-13                 0x0000000106a5edd7 clang::TreeTransform<(anonymous namespace)::TemplateInstantiator>::TransformCallExpr(clang::CallExpr*) + 71
# 18 clang-13                 0x0000000106a469ef clang::TreeTransform<(anonymous namespace)::TemplateInstantiator>::TransformType(clang::TypeLocBuilder&, clang::TypeLoc) + 2751
# 19 clang-13                 0x0000000106a45c17 clang::TreeTransform<(anonymous namespace)::TemplateInstantiator>::TransformType(clang::TypeSourceInfo*) + 199
# 20 clang-13                 0x0000000106a6a9fe clang::TreeTransform<(anonymous namespace)::TemplateInstantiator>::TransformTemplateArgument(clang::TemplateArgumentLoc const&, clang::TemplateArgumentLoc&, bool) + 270
# 21 clang-13                 0x0000000106a53b57 bool clang::TreeTransform<(anonymous namespace)::TemplateInstantiator>::TransformTemplateArguments<clang::TemplateArgumentLoc const*>(clang::TemplateArgumentLoc const*, clang::TemplateArgumentLoc const*, clang::TemplateArgumentListInfo&, bool) + 583
# 22 clang-13                 0x0000000106a4d861 clang::Sema::Subst(clang::TemplateArgumentLoc const*, unsigned int, clang::TemplateArgumentListInfo&, clang::MultiLevelTemplateArgumentList const&) + 81
# 23 clang-13                 0x0000000106a3c2cf std::__1::enable_if<IsPartialSpecialization<clang::ClassTemplatePartialSpecializationDecl>::value, clang::Sema::TemplateDeductionResult>::type FinishTemplateArgumentDeduction<clang::ClassTemplatePartialSpecializationDecl>(clang::Sema&, clang::ClassTemplatePartialSpecializationDecl*, bool, clang::TemplateArgumentList const&, llvm::SmallVectorImpl<clang::DeducedTemplateArgument>&, clang::sema::TemplateDeductionInfo&) + 1695
# 24 clang-13                 0x0000000106a3f382 void llvm::function_ref<void ()>::callback_fn<bool isAtLeastAsSpecializedAs<clang::ClassTemplatePartialSpecializationDecl>(clang::Sema&, clang::QualType, clang::QualType, clang::ClassTemplatePartialSpecializationDecl*, clang::sema::TemplateDeductionInfo&)::'lambda'()>(long) + 66
# 25 clang-13                 0x000000010634f96e clang::Sema::runWithSufficientStackSpace(clang::SourceLocation, llvm::function_ref<void ()>) + 46
# 26 clang-13                 0x00000001069f1f4c bool isAtLeastAsSpecializedAs<clang::ClassTemplatePartialSpecializationDecl>(clang::Sema&, clang::QualType, clang::QualType, clang::ClassTemplatePartialSpecializationDecl*, clang::sema::TemplateDeductionInfo&) + 844
# 27 clang-13                 0x00000001069f23b1 clang::Sema::isMoreSpecializedThanPrimary(clang::ClassTemplatePartialSpecializationDecl*, clang::sema::TemplateDeductionInfo&) + 1009
# 28 clang-13                 0x0000000106958cf3 clang::Sema::CheckTemplatePartialSpecialization(clang::ClassTemplatePartialSpecializationDecl*) + 323
# 29 clang-13                 0x0000000106965ea3 clang::Sema::ActOnClassTemplateSpecialization(clang::Scope*, unsigned int, clang::Sema::TagUseKind, clang::SourceLocation, clang::SourceLocation, clang::CXXScopeSpec&, clang::TemplateIdAnnotation&, clang::ParsedAttributesView const&, llvm::MutableArrayRef<clang::TemplateParameterList*>, clang::Sema::SkipBodyInfo*) + 4435
# 30 clang-13                 0x0000000106241078 clang::Parser::ParseClassSpecifier(clang::tok::TokenKind, clang::SourceLocation, clang::DeclSpec&, clang::Parser::ParsedTemplateInfo const&, clang::AccessSpecifier, bool, clang::Parser::DeclSpecContext, clang::ParsedAttributesWithRange&) + 9352
# 31 clang-13                 0x000000010621b08f clang::Parser::ParseDeclarationSpecifiers(clang::DeclSpec&, clang::Parser::ParsedTemplateInfo const&, clang::AccessSpecifier, clang::Parser::DeclSpecContext, clang::Parser::LateParsedAttrList*) + 991
# 32 clang-13                 0x00000001062cfbc0 clang::Parser::ParseSingleDeclarationAfterTemplate(clang::DeclaratorContext, clang::Parser::ParsedTemplateInfo const&, clang::ParsingDeclRAIIObject&, clang::SourceLocation&, clang::ParsedAttributes&, clang::AccessSpecifier) + 928
# 33 clang-13                 0x00000001062ceee1 clang::Parser::ParseTemplateDeclarationOrSpecialization(clang::DeclaratorContext, clang::SourceLocation&, clang::ParsedAttributes&, clang::AccessSpecifier) + 2161
# 34 clang-13                 0x00000001062ce4a9 clang::Parser::ParseDeclarationStartingWithTemplate(clang::DeclaratorContext, clang::SourceLocation&, clang::ParsedAttributes&, clang::AccessSpecifier) + 329
# 35 clang-13                 0x000000010621a566 clang::Parser::ParseDeclaration(clang::DeclaratorContext, clang::SourceLocation&, clang::ParsedAttributesWithRange&, clang::SourceLocation*) + 694
# 36 clang-13                 0x00000001062e2c6e clang::Parser::ParseExternalDeclaration(clang::ParsedAttributesWithRange&, clang::ParsingDeclSpec*) + 190
# 37 clang-13                 0x000000010623911a clang::Parser::ParseInnerNamespace(llvm::SmallVector<clang::Parser::InnerNamespaceInfo, 4u> const&, unsigned int, clang::SourceLocation&, clang::ParsedAttributes&, clang::BalancedDelimiterTracker&) + 186
# 38 clang-13                 0x0000000106238aa8 clang::Parser::ParseNamespace(clang::DeclaratorContext, clang::SourceLocation&, clang::SourceLocation) + 7912
# 39 clang-13                 0x000000010621a630 clang::Parser::ParseDeclaration(clang::DeclaratorContext, clang::SourceLocation&, clang::ParsedAttributesWithRange&, clang::SourceLocation*) + 896
# 40 clang-13                 0x00000001062e2c6e clang::Parser::ParseExternalDeclaration(clang::ParsedAttributesWithRange&, clang::ParsingDeclSpec*) + 190
# 41 clang-13                 0x000000010623911a clang::Parser::ParseInnerNamespace(llvm::SmallVector<clang::Parser::InnerNamespaceInfo, 4u> const&, unsigned int, clang::SourceLocation&, clang::ParsedAttributes&, clang::BalancedDelimiterTracker&) + 186
# 42 clang-13                 0x0000000106238aa8 clang::Parser::ParseNamespace(clang::DeclaratorContext, clang::SourceLocation&, clang::SourceLocation) + 7912
# 43 clang-13                 0x000000010621a630 clang::Parser::ParseDeclaration(clang::DeclaratorContext, clang::SourceLocation&, clang::ParsedAttributesWithRange&, clang::SourceLocation*) + 896
# 44 clang-13                 0x00000001062e2c6e clang::Parser::ParseExternalDeclaration(clang::ParsedAttributesWithRange&, clang::ParsingDeclSpec*) + 190
# 45 clang-13                 0x00000001062e1421 clang::Parser::ParseTopLevelDecl(clang::OpaquePtr<clang::DeclGroupRef>&, bool) + 2113
# 46 clang-13                 0x00000001062075dd clang::ParseAST(clang::Sema&, bool, bool) + 509
# 47 clang-13                 0x000000010528add9 clang::FrontendAction::Execute() + 169
# 48 clang-13                 0x00000001051f4de4 clang::CompilerInstance::ExecuteAction(clang::FrontendAction&) + 948
# 49 clang-13                 0x000000010530a193 clang::ExecuteCompilerInvocation(clang::CompilerInstance*) + 1731
# 50 clang-13                 0x0000000102593cc3 cc1_main(llvm::ArrayRef<char const*>, char const*, void*) + 2531
# 51 clang-13                 0x000000010259154b ExecuteCC1Tool(llvm::SmallVectorImpl<char const*>&) + 379
# 52 clang-13                 0x000000010259109e main + 12126
# 53 libdyld.dylib            0x00007fff204fbf3d start + 1
# 54 libdyld.dylib            0x000000000000003e start + 18446603339974066434
# clang-13: error: unable to execute command: Abort trap: 6
# clang-13: error: clang frontend command failed due to signal (use -v to see invocation)
# clang version 13.0.0 (https://github.com/llvm/llvm-project.git aab81c2f40d2098f9014473a1e7c8fb7b074360b)
# Target: x86_64-apple-darwin20.4.0
# Thread model: posix
# InstalledDir: /usr/local/bin
# clang-13: note: diagnostic msg: Error generating preprocessed source(s).
```

## "Missing" headers on MacOS

The error log above means:
1. clang doesn't find `wchar.h` in my enironment: either there's no `wchar.h` on my laptop (which is very unlikely), or the searching path is wrong.
2. And clang crashes because of the missing of `wchar.h`, which should be a clang bug, as the compiler should NOT crash anyway.

After googling a bit, I find out the MacOS system headers are no longer placed at `/usr/include`, after Xcode 10 ([release note](https://developer.apple.com/documentation/xcode-release-notes/xcode-10-release-notes#3035624)):

> The command line tools will search the SDK for system headers by default. However, some software may fail to build correctly against the SDK and require macOS headers to be installed in the base system under /usr/include. If you are the maintainer of such software, we encourage you to update your project to work with the SDK or file a bug report for issues that are preventing you from doing so. As a workaround, an extra package is provided which will install the headers to the base system. In a future release, this package will no longer be provided. You can find this package at:
>
> /Library/Developer/CommandLineTools/Packages/macOS_SDK_headers_for_macOS_10.14.pkg
>
> To make sure that you’re using the intended version of the command line tools, run xcode-select -s or xcode select -s /Library/Developer/CommandLineTools after installing.

Xcode provides with a work around package to install the headers to the base system, however as it says, this package will not be provided in future releases.

I'm surprised that the llvm-trunk version clang won't work natively on the latest MacOS. So I take a look at how the system-bundled clang (`/usr/bin/c++`) would behave to find the header files.

```bash
c++ -v
# Apple clang version 12.0.0 (clang-1200.0.32.29)
# Target: x86_64-apple-darwin20.4.0
# Thread model: posix
# InstalledDir: /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin

c++ test.cpp && ./a.out
# Hello world
```

Alright, it works (it is an "Apple clang", instead of a normal "clang"). Take another look at the detailed compilation flags:
```bash
c++ test.cpp -v
# Apple clang version 12.0.0 (clang-1200.0.32.29)
# Target: x86_64-apple-darwin20.4.0
# Thread model: posix
# InstalledDir: /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin
#  "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang" -cc1 -triple x86_64-apple-macosx11.0.0 -Wdeprecated-objc-isa-usage -Werror=deprecated-objc-isa-usage -Werror=implicit-function-declaration -emit-obj -mrelax-all -disable-free -disable-llvm-verifier -discard-value-names -main-file-name test.cpp -mrelocation-model pic -pic-level 2 -mthread-model posix -mframe-pointer=all -fno-strict-return -masm-verbose -munwind-tables -target-sdk-version=11.3 -target-cpu penryn -dwarf-column-info -debugger-tuning=lldb -target-linker-version 609.8 -v -resource-dir /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/clang/12.0.0 -isysroot /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk -I/usr/local/include -stdlib=libc++ -internal-isystem /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/include/c++/v1 -internal-isystem /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/local/include -internal-isystem /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/clang/12.0.0/include -internal-externc-isystem /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/include -internal-externc-isystem /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/include -Wno-reorder-init-list -Wno-implicit-int-float-conversion -Wno-c99-designator -Wno-final-dtor-non-final-class -Wno-extra-semi-stmt -Wno-misleading-indentation -Wno-quoted-include-in-framework-header -Wno-implicit-fallthrough -Wno-enum-enum-conversion -Wno-enum-float-conversion -fdeprecated-macro -fdebug-compilation-dir /Users/nuullll/Projects/playground/cpp -ferror-limit 19 -fmessage-length 183 -stack-protector 1 -fstack-check -mdarwin-stkchk-strong-link -fblocks -fencode-extended-block-signature -fregister-global-dtors-with-atexit -fgnuc-version=4.2.1 -fobjc-runtime=macosx-11.0.0 -fcxx-exceptions -fexceptions -fmax-type-align=16 -fdiagnostics-show-option -fcolor-diagnostics -o /var/folders/33/3kb7_j8x61q5l57tn2wk4xl80000gn/T/test-d859b9.o -x c++ test.cpp
# clang -cc1 version 12.0.0 (clang-1200.0.32.29) default target x86_64-apple-darwin20.4.0
# ignoring nonexistent directory "/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/local/include"
# ignoring nonexistent directory "/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/Library/Frameworks"
# #include "..." search starts here:
# #include <...> search starts here:
#  /usr/local/include
#  /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/include/c++/v1
#  /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/clang/12.0.0/include
#  /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/include
#  /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/include
#  /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/System/Library/Frameworks (framework directory)
# End of search list.
#  "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/ld" -demangle -lto_library /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/libLTO.dylib -no_deduplicate -dynamic -arch x86_64 -platform_version macos 11.0.0 11.3 -syslibroot /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk -o a.out -L/usr/local/lib /var/folders/33/3kb7_j8x61q5l57tn2wk4xl80000gn/T/test-d859b9.o -lc++ -lSystem /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/clang/12.0.0/lib/darwin/libclang_rt.osx.a
```

Now it starts to make sense. The system clang searches the CommandLineTools/Xcode.app paths because the driver passes a bunch of "-isysroot"/"-internal-isystem" flags to the compiler. Adding the "-isysroot" argument makes the built clang work again!

```bash
clang++ test.cpp -isysroot /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk
```

But it is too wordy for compiling a hello-world cpp program, right? Finally, I notice something useful when doing `ninja check-all`:

```bash
[724/725] Running all regression tests
llvm-lit: /Users/nuullll/Projects/llvm-project/llvm/utils/lit/lit/llvm/config.py:428: note: using clang: /Users/nuullll/Projects/llvm-project/build/bin/clang
llvm-lit: /Users/nuullll/Projects/llvm-project/llvm/utils/lit/lit/util.py:399: note: using SDKROOT: '/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX11.1.sdk'
llvm-lit: /Users/nuullll/Projects/llvm-project/build/utils/lit/tests/lit.cfg:89: warning: Setting a timeout per test not supported. Requires the Python psutil module but it could not be found. Try installing it via pip or via your operating system's package manager.
 Some tests will be skipped and the --timeout command line argument will not work.
```

`llvm-lit` is using `SDKROOT` for this! Let's see what happens in `util.py:399`:

```py
def usePlatformSdkOnDarwin(config, lit_config):
    # On Darwin, support relocatable SDKs by providing Clang with a
    # default system root path.
    if 'darwin' in config.target_triple:
        try:
            cmd = subprocess.Popen(['xcrun', '--show-sdk-path', '--sdk', 'macosx'],
                                   stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            out, err = cmd.communicate()
            out = out.strip()
            res = cmd.wait()
        except OSError:
            res = -1
        if res == 0 and out:
            sdk_path = out.decode()
            lit_config.note('using SDKROOT: %r' % sdk_path)
            config.environment['SDKROOT'] = sdk_path
```

TBC...