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

[Dotty][dotty_examples], [GraalSqueak][graalsqueak_examples], [GraalVM][graalvm_examples], [Kotlin][kotlin_examples] and [LLVM][llvm_examples] are other topics we are currently investigating.

## <span id="section_01">Project dependencies</span>

This project depends on several external software for the **Microsoft Windows** platform:

- [Apache Maven 3.6][maven_downloads] ([requires Java 7][maven_history])  ([*release notes*][maven_relnotes]
- [GraalVM Community Edition 19.3 LTS][graalvm_releases] <sup id="anchor_01">[[1]](#footnote_01)</sup> ([*release notes*][graalvm_relnotes])
- [Microsoft Visual Studio 10][vs2010_downloads] ([*release notes*][vs2010_relnotes])
- [Microsoft Windows SDK for Windows 7 and .NET Framework 4][windows_sdk] <sup id="anchor_02a">[[2]](#footnote_02)</sup>
<!--
- [Microsoft Visual C++ 2010 Service Pack 1 Compiler Update for the Windows SDK 7.1](https://www.microsoft.com/en-us/download/details.aspx?displaylang=en&id=4422) <sup id="anchor_02b">[[2]](#footnote_02)</sup>
-->

Optionally one may also install the following software:

- [ANTLR 4.7 tool][antlr_downloads] ([*release notes*][antlr_relnotes]) <sup id="anchor_03">[[3]](#footnote_03)</sup>
- [Git 2.24][git_downloads] ([*release notes*][git_relnotes])

> **:mag_right:** Git for Windows provides a BASH emulation used to run [**`git`**][git_cli] from the command line (as well as over 250 Unix commands like [**`awk`**][man1_awk], [**`diff`**][man1_diff], [**`file`**][man1_file], [**`grep`**][man1_grep], [**`more`**][man1_more], [**`mv`**][man1_mv], [**`rmdir`**][man1_rmdir], [**`sed`**][man1_sed] and [**`wc`**][man1_wc].

For instance our development environment looks as follows (*December 2019*) <sup id="anchor_04">[[4]](#footnote_04)</sup> :

<pre style="font-size:80%;">
C:\opt\apache-maven-3.6.3\                            <i>( 10 MB)</i>
C:\opt\graalvm-ce-java8-19.3.0\                       <i>(361 MB)</i>
C:\opt\Git-2.24.1\                                    <i>(277 MB)</i>
C:\Program Files\Microsoft SDKs\Windows\v7.1\         <i>(333 MB)</i>
C:\Program Files (x86)\Microsoft Visual Studio 10.0\  <i>(555 MB)</i>
</pre>

> **&#9755;** ***Installation policy***<br/>
> When possible we install software from a [Zip archive][zip_archive] rather than via a Windows installer. In our case we defined **`C:\opt\`** as the installation directory for optional software tools (*in reference to* the [`/opt/`][linux_opt] directory on Unix).


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
> <b>&gt; subst S: %USERPROFILE%\workspace\simplelanguage-examples</b>
> </pre>

In the next section we give a brief description of the batch files present in this project.

## Batch/Bash commands

We distinguish different sets of batch commands:

1. [**`setenv.bat`**](setenv.bat) - This batch command makes external tools such as [**`javac.exe`**][javac_exe], [**`mvn.cmd`**][maven_cli] or [**`cl.exe`**](vs2010_cl) directly available from the command prompt (see section [**Project dependencies**](#section_01)).

   <pre style="font-size:80%;">
   <b>&gt; setenv help</b>
   Usage: setenv { &lt;option&gt; | &lt;subcommand&gt; }
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
   <b>&gt; build help</b>
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

Command [**`setenv`**](setenv.bat) is executed once to setup our development environment; it makes external tools such as [**`mvn.cmd`**][mvn_cmd], [**`git.exe`**][git_cli] and [**`cl.exe`**][windows_cl] directly available from the command prompt:

<pre style="font-size:80%;">
<b>&gt; setenv</b>
Tool versions:
   javac 1.8.0_232, mvn 3.6.3, cl 16.00.40219.01 for x64
   dumpbin 10.00.40219.01, link 10.00.40219.01, uuidgen v1.01
   git 2.24.1.windows.2, diff 3.7 bash 4.4.23(1)-release

<b>&gt; where javac mvn</b>
C:\opt\graalvm-ce-java8-19.3.0\bin\javac.exe
C:\opt\apache-maven-3.6.3\bin\mvn
C:\opt\apache-maven-3.6.3\bin\mvn.cmd
</pre>

Command [**`setenv -verbose`**](setenv.bat) also displays the tool paths:

<pre style="font-size:80%;">
<b>&gt; setenv -verbose</b>
Tool versions:
   javac 1.8.0_232, mvn 3.6.3, cl 16.00.40219.01 for x64
   dumpbin 10.00.40219.01, link 10.00.40219.01, uuidgen v1.01
   git 2.24.1.windows.2, diff 3.7 bash 4.4.23(1)-release
Tool paths:
   C:\opt\graalvm-ce-java8-19.3.0\bin\javac.exe
   C:\opt\apache-maven-3.6.3\bin\mvn.cmd
   C:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\bin\amd64\cl.exe
   C:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\bin\amd64\dumpbin.exe
   C:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\bin\amd64\link.exe
   C:\opt\Git-2.24.1\usr\bin\link.exe
   C:\Program Files\Microsoft SDKs\Windows\v7.1\Bin\x64\Uuidgen.Exe
   C:\opt\Git-2.24.1\bin\git.exe
   C:\opt\Git-2.24.1\mingw64\bin\git.exe
   C:\opt\Git-2.24.1\usr\bin\diff.exe
   C:\opt\Git-2.24.1\bin\bash.exe
</pre>

Command [**`setenv -sdk`**](setenv.bat) is aimed to users who prefer to rely on the *"Windows SDK 7.1 Command Prompt"* shortcut (target **`C:\Program Files\Microsoft SDKs\Windows\v7.1\Bin\SetEnv.cmd`**) to setup their development environment.

#### `simplelanguage\build.bat`

Usage of batch file [**`build.bat`**](bin/simplelanguage/build.bat) and bash script [**`build`**](bin/simplelanguage/build) is presented in document [BUILD.md](BUILD.md).

#### `simplelanguage\generate_parser.bat`

Batch file [**`generate_parser.bat`**](bin/simplelanguage/generate_parser.bat) is functionally equivalent to the bash script [**`generate_parser`**](bin/simplelanguage/generate_parser).

Usage of batch file [**`generate_parser.bat`**](bin/simplelanguage/generate_parser.bat) is presented in document [BUILD.md](BUILD.md).

#### `simplelanguage\sl.bat`

Batch file [**`sl.bat`**](bin/simplelanguage/sl.bat) is functionally equivalent to the bash script [**`sl`**](bin/simplelanguage/sl).

Usage of batch file [**`sl.bat`**](bin/simplelanguage/sl.bat) is presented in document [BUILD.md](BUILD.md).

## Footnotes

<a name="footnote_01">[1]</a> ***2 GraalVM editions*** [↩](#anchor_01)

<p style="margin:0 0 1em 20px;">
<a href="https://www.graalvm.org/docs/getting-started/">GraalVM</a> is available as Community Edition (CE) and Enterprise Edition (EE):
</p>
<ul><li>GraalVM CE is based either on the <a href="https://adoptopenjdk.net/?variant=openjdk8&jvmVariant=hotspot">OpenJDK 8</a> or on <a href="https://adoptopenjdk.net/?variant=openjdk11&jvmVariant=hotspot">OpenJDK 11</a> and</li>
<li><a href="https://www.oracle.com/technetwork/graalvm/downloads/index.html">GraalVM EE</a> is developed on top of the <a href="https://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html">Oracle Java SE 1.8.0_231</a> respectively on Oracle Java SE 11.</li>
</ul>

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
<a href="https://archive.apache.org/dist/ant/binaries/">apache-maven-3.6.3-bin.zip</a>                <i>(  8 MB)</i>
<a href="https://github.com/graalvm/graalvm-ce-builds/releases/tag/vm-19.3.0">graalvm-ce-java8-windows-amd64-19.3.0.zip</a> <i>(154 MB)</i>
<a href="https://www.microsoft.com/en-us/download/details.aspx?id=8442">GRMSDKX_EN_DVD.iso</a>                        <i>(570 MB)</i>
<a href="https://git-scm.com/download/win">PortableGit-2.24.1-64-bit.7z.exe</a>    <i>      ( 41 MB)</i>
<a href="https://www.microsoft.com/en-us/download/details.aspx?displaylang=en&id=4422">VC-Compiler-KB2519277.exe</a>                 <i>(121 MB)</i>
</pre>

***

*[mics](http://lampwww.epfl.ch/~michelou/)/December 2019* [**&#9650;**](#top)
<span id="bottom">&nbsp;</span>

<!-- link refs -->

[antlr_downloads]: https://www.antlr.org/download.html
[antlr_relnotes]: https://github.com/antlr/antlr4/releases/tag/4.7.2
[dotty_examples]: https://github.com/michelou/dotty-examples
[git_downloads]: https://git-scm.com/download/win
[git_cli]: https://git-scm.com/docs/git
[git_relnotes]: https://raw.githubusercontent.com/git/git/master/Documentation/RelNotes/2.24.1.txt
[github_michelou_sl]: https://github.com/michelou/simplelanguage
[github_graalvm_sl]: https://github.com/graalvm/simplelanguage
[github_markdown]: https://github.github.com/gfm/
[graalsqueak_examples]: https://github.com/michelou/graalsqueak-examples
[graalvm_examples]: https://github.com/michelou/graalvm-examples
[graalvm_releases]: https://github.com/oracle/graal/releases
[graalvm_relnotes]: https://www.graalvm.org/docs/release-notes/19_3/
[javac_exe]: https://docs.oracle.com/javase/8/docs/technotes/tools/windows/javac.html
[kotlin_examples]: https://github.com/michelou/kotlin-examples
[linux_opt]: http://tldp.org/LDP/Linux-Filesystem-Hierarchy/html/opt.html
[llvm_examples]: https://github.com/michelou/llvm-examples
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
[maven_downloads]: http://maven.apache.org/download.cgi
[maven_history]: http://maven.apache.org/docs/history.html
[maven_relnotes]: http://maven.apache.org/docs/3.6.3/release-notes.html
[mvn_cmd]: https://maven.apache.org/guides/introduction/introduction-to-the-lifecycle.html
[vs2010_cl]: https://docs.microsoft.com/en-us/cpp/build/reference/compiler-command-line-syntax?view=vs-2019
[vs2010_downloads]: https://visualstudio.microsoft.com/vs/older-downloads/
[vs2010_relnotes]: https://docs.microsoft.com/en-us/visualstudio/releasenotes/vs2010-version-history
[windows_cl]: https://docs.microsoft.com/en-us/cpp/build/reference/compiling-a-c-cpp-program?view=vs-2019
[windows_limitation]: https://support.microsoft.com/en-gb/help/830473/command-prompt-cmd-exe-command-line-string-limitation
[windows_sdk]: https://www.microsoft.com/en-us/download/details.aspx?id=8442
[windows_subst]: https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/subst
[zip_archive]: https://www.howtogeek.com/178146/htg-explains-everything-you-need-to-know-about-zipped-files/
