---
layout: post
title:  "Developing a VSCode Extension for LLVM IR analysis"
date:   2021-05-15 15:49:19 +0800
tags: llvm VSCode
description: \!dbg \!42
---
This is a plan. I'll update as I go :)

As a compiler engineer, I have to dive into LLVM IR details to figure out what's wrong with our magical compiler. Sometimes the IR file (`.ll`) is extremely compilcated (up to 100k lines), especially when I'm dealing with Debug Info. A common scenario is that the content of a [metadata] node attached to an instruction, locates at the very end of the `.ll` file. I have to jump back and forth frequently in the editor to know what exactly each metadata means, which is super annoying :(

Ah, I use VSCode as the editor bascially because <del>I can't figure out how to exit vim</del> of its remote developement feature. So this is the initial motivation of developing a VSCode Extension to ease the analysis effort on LLVM IR.

The first feature of my VSCode Extension would be showing up a tooltip expanding the metadata definition.

## Detailed plan

1. Build llvm-project on my laptop
2. Create a hello-world VSCode Extension
3. ...

[metadata]: https://llvm.org/docs/LangRef.html#metadata
