# <span id="top">SimpleLanguage on Microsoft Windows</span>

<table style="font-family:Helvetica,Arial;font-size:14px;line-height:1.6;">
  <tr>
  <td style="border:0;padding:0 10px 0 0;min-width:60px;max-width:100px;">
    <a href="https://www.graalvm.org/" rel="external"><img style="border:0;" src="docs/images/GraalVM-rgb.svg" alt="GraalVM project"/></a>
  </td>
  <td style="border:0;padding:0;vertical-align:text-top;">
    In the following we describe how to modify the <b><code><a href="https://github.com/graalvm/simplelanguage" rel="external">SimpleLanguage</a></code></b> (aka SL) example project on a Windows machine.<br/>In particular we show how to add new builtins, extend the SL parser.
  </td>
  </tr>
</table>

[Ada][ada_examples], [Akka][akka_examples], [Deno][deno_examples], [Golang][golang_examples], [GraalVM][graalvm_examples], [Haskell][haskell_examples], [Kotlin][kotlin_examples], [LLVM][llvm_examples], [Node.js][nodejs_examples], [Rust][rust_examples], [Scala 3][scala3_examples], [Spring][spring_examples] and [TruffleSqueak][trufflesqueak_examples] are other topics we are currently investigating.

## <span id="section_01">Project dependencies</span>

This project depends on several external software for the **Microsoft Windows** platform:

- [Apache Maven 3.8][maven_downloads] ([requires Java 7][maven_history])  ([*release notes*][maven_relnotes])
- [GraalVM Community Edition 22 LTS][graalvm_releases] <sup id="anchor_01">[[1]](#footnote_01)</sup> ([*release notes*][graalvm_relnotes])
- [Microsoft Visual Studio 10][vs2010_downloads] ([*release notes*][vs2010_relnotes])
- [Microsoft Windows SDK for Windows 7 and .NET Framework 4][windows_sdk] <sup id="anchor_02a">[[2]](#footnote_02)</sup>
<!--
- [Microsoft Visual C++ 2010 Service Pack 1 Compiler Update for the Windows SDK 7.1](https://www.microsoft.com/en-us/download/details.aspx?displaylang=en&id=4422) <sup id="anchor_02b">[[2]](#footnote_02)</sup>
-->

Optionally one may also install the following software:

- [ANTLR 4.9 tool][antlr_downloads] ([*release notes*][antlr_relnotes]) <sup id="anchor_03">[[3]](#footnote_03)</sup>
- [Git 2.35][git_downloads] ([*release notes*][git_relnotes])

> **:mag_right:** Git for Windows provides a BASH emulation used to run [**`git`**][git_cli] from the command line (as well as over 250 Unix commands like [**`awk`**][man1_awk], [**`diff`**][man1_diff], [**`file`**][man1_file], [**`grep`**][man1_grep], [**`more`**][man1_more], [**`mv`**][man1_mv], [**`rmdir`**][man1_rmdir], [**`sed`**][man1_sed] and [**`wc`**][man1_wc].

For instance our development environment looks as follows (*February 2022*) <sup id="anchor_04">[[4]](#footnote_04)</sup> :

<pre style="font-size:80%;">
C:\opt\apache-maven-3.8.4\                            <i>( 10 MB)</i>
C:\opt\graalvm-ce-java11-22.0.0.2\                    <i>(869 MB)</i>
C:\opt\graalvm-ce-java17-22.0.0.2\                    <i>(937 MB)</i>
C:\opt\Git-2.35.1\                                    <i>(279 MB)</i>
C:\Program Files\Microsoft SDKs\Windows\v7.1\         <i>(333 MB)</i>
C:\Program Files (x86)\Microsoft Visual Studio 10.0\  <i>(555 MB)</i>
</pre>
<!-- 19.3.1 = 360 MB, 20.0.0 -> 670 MB, 20.3.0 -> 696 MB, 21.2.0 -> 845 MB -->

> **&#9755;** ***Installation policy***<br/>
> When possible we install software from a [Zip archive][zip_archive] rather than via a Windows installer. In our case we defined **`C:\opt\`** as the installation directory for optional software tools (*in reference to* the [`/opt/`][linux_opt] directory on Unix).

## Directory structure

This project is organized as follows:

<pre style="font-size:80%;">
bin\simplelanguage\
docs\
simplelanguage\  <i>(<a href=".gitmodules">Git submodule</a>)</i>
<a href="BUILD.md">BUILD.md</a>
README.md
<a href="setenv.bat">setenv.bat</a>
</pre>

where

- directory [**`bin\simplelanguage\`**](bin/simplelanguage/) contains several batch files and bash scripts for generating/running the SL parser on a Windows machine.
- directory [**`docs\`**](docs/) contains SL related documentation.
- directory [**`simplelanguage\`**](simplelanguage/) contains our [fork][github_michelou_sl] of the [graalvm/simplelanguage][github_graalvm_sl] repository as a [Github submodule](.gitmodules).
- file [**`BUILD.md`**](BUILD.md) is the [Markdown][github_markdown] document for generating the SL component.
- file [**`README.md`**](README.md) is the [Markdown][github_markdown] document of this page.
- file [**`setenv.bat`**](setenv.bat) is the batch script for setting up our environment.

We also define a virtual drive **`S:`** in our working environment in order to reduce/hide the real path of our project directory (see article ["Windows command prompt limitation"][windows_limitation] from Microsoft Support).

> **:mag_right:** We use the Windows external command [**`subst`**][windows_subst] to create virtual drives; for instance:
>
> <pre style="font-size:80%;">
> <b>&gt; <a href="https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/subst">subst</a> S: <a href="https://en.wikipedia.org/wiki/Environment_variable#Default_values">%USERPROFILE%</a>\workspace\simplelanguage-examples</b>
> </pre>

In the next section we give a brief description of the batch files present in this project.

## Batch/Bash commands

We distinguish different sets of batch commands:

1. [**`setenv.bat`**](setenv.bat) - This batch command makes external tools such as [**`javac.exe`**][javac_exe], [**`mvn.cmd`**][maven_cli] or [**`cl.exe`**](vs2010_cl) directly available from the command prompt (see section [**Project dependencies**](#section_01)).

   <pre style="font-size:80%;">
   <b>&gt; <a href="setenv.bat">setenv</a> help</b>
   Usage: <a href="setenv.bat">setenv</a> { &lt;option&gt; | &lt;subcommand&gt; }
   &nbsp;
     Options:
       -bash       start Git bash shell instead of Windows command prompt
       -debug      show commands executed by this script
       -java11     use Java 11 installation of GraalVM (instead of Java 8)
       -sdk        setup Windows SDK environment (SetEnv.cmd)
       -verbose    display progress messages
   &nbsp;
     Subcommands:
       help        display this help message
   </pre>

2. [**`bin\simplelanguage\build.bat`**](bin/simplelanguage/build.bat) - This batch command generates the SL component.

   <pre style="font-size:80%;">
   <b>&gt; <a href="bin/simplelanguage/build.bat">build</a> help</b>
   Usage: build { &lt;option&gt; | &lt;subcommand&gt; }
   &nbsp;
     Options:
       -debug      show commands executed by this script
       -native     generate native executable (native-image)
       -timer      display total elapsed time
       -verbose    display progress messages
   &nbsp;
    Subcommands:
       clean       delete generated files
       dist        generate binary distribution
       help        display this help message
       parser      generate ANTLR parser for SL
   </pre>

3. [**`bin\simplelanguage\build`**](bin/simplelanguage/build) - This bash script is functionally equivalent to the batch file [**`build.bat`**](bin/simplelanguage/build.bat).

## <span id="section_04">Usage examples</span>

#### `setenv.bat`

Command [**`setenv`**](setenv.bat) is run once to setup our development environment; it makes external tools such as [**`mvn.cmd`**][mvn_cmd], [**`git.exe`**][git_cli] and [**`cl.exe`**][windows_cl] directly available from the command prompt:

<pre style="font-size:80%;">
<b>&gt; <a href="setenv.bat">setenv</a></b>
Tool versions:
   javac 1.8.0_322, mvn 3.8.4,
   git 2.35.1.windows.1, diff 3.8, bash 4.4.23(1)-release

<b>&gt; <a href="https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/where">where</a> javac mvn</b>
C:\opt\graalvm-ce-java11-21.3.0\bin\javac.exe
C:\opt\apache-maven-3.8.4\bin\mvn
C:\opt\apache-maven-3.8.4\bin\mvn.cmd
</pre>

Command [**`setenv -verbose`**](setenv.bat) also displays the tool paths:

<pre style="font-size:80%;">
<b>&gt; <a href="setenv.bat">setenv</a> -verbose</b>
Tool versions:
   javac 1.8.0_302, mvn 3.8.4,
   git 2.35.1.windows.1, diff 3.7 bash 4.4.23(1)-release
Tool paths:
   C:\opt\graalvm-ce-java11-21.2.0\bin\javac.exe
   C:\opt\apache-maven-3.8.4\bin\mvn.cmd
   C:\opt\Git-2.35.1\bin\git.exe
   C:\opt\Git-2.35.1\mingw64\bin\git.exe
   C:\opt\Git-2.35.1\usr\bin\diff.exe
   C:\opt\Git-2.35.1\bin\bash.exe
Environment variables:
   "GIT_HOME=C:\opt\Git-2.35.1"
   "JAVA_HOME=C:\opt\graalvm-ce-java11-21.2.0"
   "MAVEN_HOME=C:\opt\apache-maven-3.8.4"
   "MSVC_HOME=C:\Program Files (x86)\Microsoft Visual Studio 10.0\VC"
   "MSVS_HOME=C:\Program Files (x86)\Microsoft Visual Studio 10.0"
</pre>

Command [**`setenv -sdk`**](setenv.bat) is aimed to users who prefer to rely on the *"Windows SDK 7.1 Command Prompt"* shortcut (target **`C:\Program Files\Microsoft SDKs\Windows\v7.1\Bin\SetEnv.cmd`**) to setup their development environment.

#### `simplelanguage\build.bat`

Usage of batch file [**`build.bat`**](bin/simplelanguage/build.bat) and bash script [**`build`**](bin/simplelanguage/build) is presented in document [BUILD.md](BUILD.md).

#### `simplelanguage\generate_parser.bat`

Batch file [**`generate_parser.bat`**](bin/simplelanguage/generate_parser.bat) is functionally equivalent to the bash script [**`generate_parser`**](https://github.com/michelou/simplelanguage/blob/master/generate_parser.sh).

Usage of batch file [**`generate_parser.bat`**](bin/simplelanguage/generate_parser.bat) is presented in document [BUILD.md](BUILD.md).

#### `simplelanguage\sl.bat`

Batch file [**`sl.bat`**](bin/simplelanguage/sl.bat) is functionally equivalent to the bash script [**`sl`**](https://github.com/michelou/simplelanguage/blob/master/sl).

Usage of batch file [**`sl.bat`**](bin/simplelanguage/sl.bat) is presented in document [BUILD.md](BUILD.md).

## Footnotes

<span id="footnote_01">[1]</span> ***2 GraalVM editions*** [↩](#anchor_01)

<dl><dd>
The <a href="https://www.graalvm.org/docs/getting-started/">GraalVM</a> software is available as Community Edition (CE) and Enterprise Edition (EE).
</dd>
<dd>
Starting with version 22, <a href="https://www.graalvm.org/docs/getting-started/">GraalVM</a> is based on <a href="https://adoptium.net/?variant=openjdk11&jvmVariant=hotspot">OpenJDK 11</a> or on <a href="https://adoptium.net/?variant=openjdk17&jvmVariant=hotspot">OpenJDK 17</a> (previous versions are based on <a href="https://adoptium.net/?variant=openjdk8&jvmVariant=hotspot">OpenJDK 8</a> or on <a href="https://adoptium.net/?variant=openjdk11&jvmVariant=hotspot">OpenJDK 11</a>).
</dd></dl>

<span id="footnote_02">[2]</span> ***2018-09-24*** [↩](#anchor_02a)

<dl><dd>
The two Microsoft software are listed in the <a href="https://github.com/oracle/graal/blob/master/compiler/README.md#windows-specifics-1">Windows Specifics</a> section of the <a href="https://github.com/oracle/graal/blob/master/compiler/README.md">oracle/graal README</a> file. That's fine but... what version should we download ?! We found the <a href="https://stackoverflow.com/questions/20115186/what-sdk-version-to-download/22987999#22987999">answer</a> (April 2014 !) on <a href="https://stackoverflow.com/">StackOverflow</a>:
</dd>
<dd>
<pre style="font-size:80%;">
GRMSDK_EN_DVD.iso is a version for x86 environment.
GRMSDKX_EN_DVD.iso is a version for x64 environment.
GRMSDKIAI_EN_DVD.iso is a version for Itanium environment.
</pre>
</dd></dl>

<span id="footnote_03">[3]</span> ***ANTLR distributions*** [↩](#anchor_03)

<dl><dd>
There exists two binary distributions of <a href="https://www.antlr.org/download/">ANTLR 4</a>: ANTLR tool and ANTLR runtime (with bindings to Java, JavaScript, C# and C++). Batch command <a href="generate_parser.bat"</a><b><code>generate_parser</code></b></a> requires ANTLR tool (<i>and</i> will download it if not present in output directory <b><code>target\parser\libs\</code></b>). 
</dd>
<dd>
<pre style="font-size:80%;">
<b>&gt; <a href="https://docs.oracle.com/en/java/javase/11/tools/java.html">java</a> -cp target\parser\libs\antlr-4.9.3-complete.jar org.antlr.v4.Tool | <a href="https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/findstr">findstr</a> Version</b>
ANTLR Parser Generator  Version 4.9.3
</pre>
</dd></dl>

<span id="footnote_04">[4]</span> ***Downloads*** [↩](#anchor_04)

<dl><dd>
In our case we downloaded the following installation files (see section <a href="#section_01"><b>Project dependencies</b></a>):
</dd>
<dd>
<pre style="font-size:80%;">
<a href="https://archive.apache.org/dist/ant/binaries/">apache-maven-3.8.4-bin.zip</a>                  <i>(  8 MB)</i>
<a href="https://github.com/graalvm/graalvm-ce-builds/releases/tag/vm-21.23.0">graalvm-ce-java11-windows-amd64-21.3.0.zip</a>  <i>(268 MB)</i>
<a href="https://www.microsoft.com/en-us/download/details.aspx?id=8442">GRMSDKX_EN_DVD.iso</a>                          <i>(570 MB)</i>
<a href="https://git-scm.com/download/win">PortableGit-2.35.1-64-bit.7z.exe</a>            <i>( 41 MB)</i>
<a href="https://www.microsoft.com/en-us/download/details.aspx?displaylang=en&id=4422">VC-Compiler-KB2519277.exe</a>                   <i>(121 MB)</i>
</pre>
</dd></dl>

***

*[mics](https://lampwww.epfl.ch/~michelou/)/March 2022* [**&#9650;**](#top)
<span id="bottom">&nbsp;</span>

<!-- link refs -->

[ada_examples]: https://github.com/michelou/ada-examples
[akka_examples]: https://github.com/michelou/akka-examples
[antlr_downloads]: https://www.antlr.org/download.html
[antlr_relnotes]: https://github.com/antlr/antlr4/releases/tag/4.9.3
[deno_examples]: https://github.com/michelou/deno-examples
[git_downloads]: https://git-scm.com/download/win
[git_cli]: https://git-scm.com/docs/git
[git_relnotes]: https://raw.githubusercontent.com/git/git/master/Documentation/RelNotes/2.35.1.txt
[github_michelou_sl]: https://github.com/michelou/simplelanguage
[github_graalvm_sl]: https://github.com/graalvm/simplelanguage
[github_markdown]: https://github.github.com/gfm/
[golang_examples]: https://github.com/michelou/golang-examples
[graalvm_examples]: https://github.com/michelou/graalvm-examples
[graalvm_releases]: https://github.com/graalvm/graalvm-ce-builds/releases/tag/vm-21.3.0
[graalvm_relnotes]: https://www.graalvm.org/release-notes/21_3/
[haskell_examples]: https://github.com/michelou/haskell-examples
[javac_exe]: https://docs.oracle.com/javase/8/docs/technotes/tools/windows/javac.html
[kotlin_examples]: https://github.com/michelou/kotlin-examples
[linux_opt]: https://tldp.org/LDP/Linux-Filesystem-Hierarchy/html/opt.html
[llvm_examples]: https://github.com/michelou/llvm-examples
[nodejs_examples]: https://github.com/michelou/nodejs-examples
[man1_awk]: https://www.linux.org/docs/man1/awk.html
[man1_diff]: https://www.linux.org/docs/man1/diff.html
[man1_file]: https://www.linux.org/docs/man1/file.html
[man1_grep]: https://www.linux.org/docs/man1/grep.html
[man1_more]: https://www.linux.org/docs/man1/more.html
[man1_mv]: https://www.linux.org/docs/man1/mv.html
[man1_rmdir]: https://www.linux.org/docs/man1/rmdir.html
[man1_sed]: https://www.linux.org/docs/man1/sed.html
[man1_wc]: https://www.linux.org/docs/man1/wc.html
[maven_cli]: https://maven.apache.org/guides/introduction/introduction-to-the-lifecycle.html
[maven_downloads]: https://maven.apache.org/download.cgi
[maven_history]: https://maven.apache.org/docs/history.html
[maven_relnotes]: https://maven.apache.org/docs/3.8.4/release-notes.html
[mvn_cmd]: https://maven.apache.org/guides/introduction/introduction-to-the-lifecycle.html
[rust_examples]: https://github.com/michelou/rust-examples
[scala3_examples]: https://github.com/michelou/dotty-examples
[spring_examples]: https://github.com/michelou/spring-examples
[trufflesqueak_examples]: https://github.com/michelou/trufflesqueak-examples
[vs2010_cl]: https://docs.microsoft.com/en-us/cpp/build/reference/compiler-command-line-syntax?view=vs-2019
[vs2010_downloads]: https://visualstudio.microsoft.com/vs/older-downloads/
[vs2010_relnotes]: https://docs.microsoft.com/en-us/visualstudio/releasenotes/vs2010-version-history
[windows_cl]: https://docs.microsoft.com/en-us/cpp/build/reference/compiling-a-c-cpp-program?view=vs-2019
[windows_limitation]: https://support.microsoft.com/en-gb/help/830473/command-prompt-cmd-exe-command-line-string-limitation
[windows_sdk]: https://www.microsoft.com/en-us/download/details.aspx?id=8442
[windows_subst]: https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/subst
[zip_archive]: https://www.howtogeek.com/178146/htg-explains-everything-you-need-to-know-about-zipped-files/
