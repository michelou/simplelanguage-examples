# <span id="top">SimpleLanguage on Microsoft Windows</span>

<table style="font-family:Helvetica,Arial;font-size:14px;line-height:1.6;">
  <tr>
  <td style="border:0;padding:0 10px 0 0;min-width:60px;max-width:100px;">
    <a href="https://www.graalvm.org/"><img style="border:0;" src="https://www.graalvm.org/resources/img/graalvm.png" alt="GraalVM"/></a>
  </td>
  <td style="border:0;padding:0;vertical-align:text-top;">
    In the following we describe how to modify the <b><code><a href="https://github.com/graalvm/simplelanguage" alt="SimpleLanguage">SimpleLanguage</a></code></b> (aka SL) example project on a Windows machine.<br/>In particular we show how to add new builtins, extend the SL parser.
  </td>
  </tr>
</table>

[Dotty](https://github.com/michelou/dotty-examples), [GraalVM](https://github.com/michelou/graalvm-examples) and [LLVM](https://github.com/michelou/llvm-examples) are other topics we are currently investigating.

## <span id="section_01">Project dependencies</span>

This project depends on several external software for the **Microsoft Windows** platform:

- [Apache Maven 3.6](http://maven.apache.org/download.cgi) ([requires Java 7](http://maven.apache.org/docs/history.html))  ([*release notes*](http://maven.apache.org/docs/3.6.2/release-notes.html))
- [GraalVM Community Edition 19.2](https://github.com/oracle/graal/releases) <sup id="anchor_01">[[1]](#footnote_01)</sup> ([*release notes*](https://www.graalvm.org/docs/release-notes/19_2/))
- [Microsoft Windows SDK for Windows 7 and .NET Framework 4](https://www.microsoft.com/en-us/download/details.aspx?id=8442) <sup id="anchor_02a">[[2]](#footnote_02)</sup>
- [Microsoft Visual C++ 2010 Service Pack 1 Compiler Update for the Windows SDK 7.1](https://www.microsoft.com/en-us/download/details.aspx?displaylang=en&id=4422) <sup id="anchor_02b">[[2]](#footnote_02)</sup>

Optionally one may also install the following software:

- [ANTLR 4.7 tool](https://www.antlr.org/download.html) ([*release notes*](https://github.com/antlr/antlr4/releases/tag/4.7.2)) <sup id="anchor_03">[[3]](#footnote_03)</sup>
- [Git 2.24](https://git-scm.com/download/win) ([*release notes*](https://raw.githubusercontent.com/git/git/master/Documentation/RelNotes/2.24.0.txt))

> **:mag_right:** Git for Windows provides a BASH emulation used to run [**`git`**](https://git-scm.com/docs/git) from the command line (as well as over 250 Unix commands like [**`awk`**](https://www.linux.org/docs/man1/awk.html), [**`diff`**](https://www.linux.org/docs/man1/diff.html), [**`file`**](https://www.linux.org/docs/man1/file.html), [**`grep`**](https://www.linux.org/docs/man1/grep.html), [**`more`**](https://www.linux.org/docs/man1/more.html), [**`mv`**](https://www.linux.org/docs/man1/mv.html), [**`rmdir`**](https://www.linux.org/docs/man1/rmdir.html), [**`sed`**](https://www.linux.org/docs/man1/sed.html) and [**`wc`**](https://www.linux.org/docs/man1/wc.html)).

For instance our development environment looks as follows (*November 2019*) <sup id="anchor_04">[[4]](#footnote_04)</sup> :

<pre style="font-size:80%;">
C:\opt\apache-maven-3.6.2\                            <i>( 10 MB)</i>
C:\opt\graalvm-ce-19.2.1\                             <i>(361 MB)</i>
C:\opt\Git-2.24.0\                                    <i>(271 MB)</i>
C:\Program Files\Microsoft SDKs\Windows\v7.1\         <i>(333 MB)</i>
C:\Program Files (x86)\Microsoft Visual Studio 10.0\  <i>(555 MB)</i>
</pre>

> **&#9755;** ***Installation policy***<br/>
> When possible we install software from a [Zip archive](https://www.howtogeek.com/178146/htg-explains-everything-you-need-to-know-about-zipped-files/) rather than via a Windows installer. In our case we defined **`C:\opt\`** as the installation directory for optional software tools (*in reference to* the [`/opt/`](http://tldp.org/LDP/Linux-Filesystem-Hierarchy/html/opt.html) directory on Unix).


## Directory structure

This project is organized as follows:

<pre style="font-size:80%;">
bin\simplelanguage\
docs\
simplelanguage\  <i>(Git submodule)</i>
BUILD.md
README.md
setenv.bat
</pre>

where

- directory [**`bin\simplelanguage\`**](bin/simplelanguage/) contains several batch scripts for generating/running the SL parser on a Windows machine.
- directory [**`docs\`**](docs/) contains SL related documentation.
- directory [**`simplelanguage\`**](simplelanguage/) contains our [fork](https://github.com/michelou/simplelanguage) of the [graalvm/simplelanguage](https://github.com/graalvm/simplelanguage) repository as a [Github submodule](.gitmodules).
- file [**`BUILD.md`**](BUILD.md) is the [Markdown](https://guides.github.com/features/mastering-markdown/) document for generating the SL component.
- file [**`README.md`**](README.md) is the [Markdown](https://guides.github.com/features/mastering-markdown/) document of this page.
- file [**`setenv.bat`**](setenv.bat) is the batch script for setting up our environment.

We also define a virtual drive **`S:`** in our working environment in order to reduce/hide the real path of our project directory (see article ["Windows command prompt limitation"](https://support.microsoft.com/en-gb/help/830473/command-prompt-cmd-exe-command-line-string-limitation) from Microsoft Support).

> **:mag_right:** We use the Windows external command [**`subst`**](https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/subst) to create virtual drives; for instance:
>
> <pre style="font-size:80%;">
> <b>&gt; subst S: %USERPROFILE%\workspace\simplelanguage-examples</b>
> </pre>

In the next section we give a brief description of the batch files present in this project.

## Batch commands

We distinguish different sets of batch commands:

1. [**`setenv.bat`**](setenv.bat) - This batch command makes external tools such as [**`javac.exe`**](https://docs.oracle.com/javase/8/docs/technotes/tools/windows/javac.html), [**`mvn.cmd`**](https://maven.apache.org/guides/introduction/introduction-to-the-lifecycle.html) or [**`cl.exe`**](https://docs.microsoft.com/en-us/cpp/build/reference/compiling-a-c-cpp-program?view=vs-2019) directly available from the command prompt (see section [**Project dependencies**](#section_01)).

   <pre style="font-size:80%;">
   <b>&gt; setenv help</b>
   Usage: setenv { option | subcommand }
   &nbsp;
     Options:
       -usesdk     setup Windows SDK environment (SetEnv.cmd)
       -verbose    display progress messages
   &nbsp;
     Subcommands:
       help        display this help message
   </pre>

2. [**`bin\simplelanguage\build.bat`**](bin/simplelanguage/build.bat) - This batch command generates the SL component.

   <pre style="font-size:80%;">
   <b>&gt; build help</b>
   Usage: build { option | subcommand }
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

## <span id="section_04">Usage examples</span>

#### `setenv.bat`

Command [**`setenv`**](setenv.bat) is executed once to setup our development environment; it makes external tools such as [**`mvn.cmd`**](https://maven.apache.org/guides/introduction/introduction-to-the-lifecycle.html), [**`git.exe`**](https://git-scm.com/docs/git) and [**`cl.exe`**](https://docs.microsoft.com/en-us/cpp/build/reference/compiling-a-c-cpp-program?view=vs-2019) directly available from the command prompt:

<pre style="font-size:80%;">
<b>&gt; setenv</b>
Tool versions:
   javac 1.8.0_232, mvn 3.6.2, git 2.24.0.windows.1, diff 3.7
   cl 16.00.40219.01 for x64, dumpbin 10.00.40219.01, uuidgen v1.01

<b>&gt; where javac mvn</b>
C:\opt\graalvm-ce-19.2.1\bin\javac.exe
C:\opt\apache-maven-3.6.2\bin\mvn
C:\opt\apache-maven-3.6.2\bin\mvn.cmd
</pre>

Command [**`setenv -verbose`**](setenv.bat) also displays the tool paths:

<pre style="font-size:80%;">
<b>&gt; setenv -verbose</b>
Tool versions:
   javac 1.8.0_232, mvn 3.6.2, git 2.24.0.windows.1, diff 3.7
   cl 16.00.40219.01 for x64, dumpbin 10.00.40219.01, uuidgen v1.01
Tool paths:
   C:\opt\graalvm-ce-19.2.1\bin\javac.exe
   C:\opt\apache-maven-3.6.2\bin\mvn.cmd
   C:\opt\Git-2.24.0\bin\git.exe
   C:\opt\Git-2.24.0\usr\bin\diff.exe
   C:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\bin\amd64\cl.exe
   c:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\bin\amd64\dumpbin.exe
   C:\Program Files\Microsoft SDKs\Windows\v7.1\Bin\x64\Uuidgen.Exe
   C:\Program Files\Microsoft SDKs\Windows\v7.1\Bin\Uuidgen.Exe
</pre>

Command [**`setenv -usesdk`**](setenv.bat) is aimed to users who prefer to rely on the *"Windows SDK 7.1 Command Prompt"* shortcut (target **`C:\Program Files\Microsoft SDKs\Windows\v7.1\Bin\SetEnv.cmd`**) to setup their development environment.

#### `simplelanguage\build.bat`

Usage of batch script [**`simplelanguage\build.bat`**](bin/simplelanguage/build.bat) is presented in document [BUILD.md](BUILD.md).

#### `simplelanguage\generate_parser.bat`

Usage of batch script [**`simplelanguage\generate_parser.bat`**](bin/simplelanguage/generate_parser.bat) is presented in document [BUILD.md](BUILD.md).

#### `simplelanguage\sl.bat`

Usage of batch script [**`simplelanguage\sl.bat`**](bin/simplelanguage/sl.bat) is presented in document [BUILD.md](BUILD.md).

## Footnotes

<a name="footnote_01">[1]</a> ***2 GraalVM editions*** [↩](#anchor_01)

<p style="margin:0 0 1em 20px;">
<a href="https://www.graalvm.org/docs/getting-started/">GraalVM</a> is available as Community Edition (CE) and Enterprise Edition (EE): GraalVM CE is based on the <a href="https://adoptopenjdk.net/">OpenJDK 8</a> and <a href="https://www.oracle.com/technetwork/graalvm/downloads/index.html">GraalVM EE</a> is developed on top of the <a href="https://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html">Java SE 1.8.0_221</a>.
</p>

<a name="footnote_02">[2]</a> ***2018-09-24*** [↩](#anchor_02a)

<p style="margin:0 0 1em 20px;">
The two Microsoft software are listed in the <a href="https://github.com/oracle/graal/blob/master/compiler/README.md#windows-specifics-1">Windows Specifics</a> section of the <a href="https://github.com/oracle/graal/blob/master/compiler/README.md">oracle/graal README</a> file. That's fine but... what version should we download ?! We found the <a href="https://stackoverflow.com/questions/20115186/what-sdk-version-to-download/22987999#22987999">answer</a> (April 2014 !) on <a href="https://stackoverflow.com/">StackOverflow</a>:
</p>
<pre style="margin:0 0 1em 20px;font-size:80%;">
GRMSDK_EN_DVD.iso is a version for x86 environment.
GRMSDKX_EN_DVD.iso is a version for x64 environment.
GRMSDKIAI_EN_DVD.iso is a version for Itanium environment.
</pre>

<a name="footnote_03">[3]</a> ***ANTLR distributions*** [↩](#anchor_03)

<p style="margin:0 0 1em 20px;">
There exists two binary distributions of <a href="https://www.antlr.org/download/">ANTLR 4</a>: ANTLR tool and ANTLR runtime (with bindings to Java, JavaScript, C# and C++). Batch command <a href="generate_parser.bat"</a><b><code>generate_parser</code></b></a> requires ANTLR tool (<i>and</i> will download it if not present in output directory <b><code>target\parser\libs\</code></b>). 
</p>
<pre style="margin:0 0 1em 20px; font-size:80%;">
<b>&gt; java -cp target\parser\libs\antlr-4.7.2-complete.jar org.antlr.v4.Tool | findstr Version</b>
ANTLR Parser Generator  Version 4.7.2
</pre>

<a name="footnote_04">[4]</a> ***Downloads*** [↩](#anchor_04)

<p style="margin:0 0 1em 20px;">
In our case we downloaded the following installation files (see section <a href="#section_01"><b>Project dependencies</b></a>):
</p>
<pre style="margin:0 0 1em 20px; font-size:80%;">
<a href="https://archive.apache.org/dist/ant/binaries/">apache-maven-3.6.2-bin.zip</a>          <i>(  8 MB)</i>
<a href="https://github.com/oracle/graal/releases/tag/vm-19.2.0">graalvm-ce-windows-amd64-19.2.1.zip</a> <i>(170 MB)</i>
<a href="https://www.microsoft.com/en-us/download/details.aspx?id=8442">GRMSDKX_EN_DVD.iso</a>                  <i>(570 MB)</i>
<a href="https://git-scm.com/download/win">PortableGit-2.24.0-64-bit.7z.exe</a>    <i>( 41 MB)</i>
<a href="https://www.microsoft.com/en-us/download/details.aspx?displaylang=en&id=4422">VC-Compiler-KB2519277.exe</a>           <i>(121 MB)</i>
</pre>

***

*[mics](http://lampwww.epfl.ch/~michelou/)/November 2019* [**&#9650;**](#top)
<span id="bottom">&nbsp;</span>