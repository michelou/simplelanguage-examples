# <span id="top">Building SimpleLanguage on Microsoft Windows</span> <span style="size:30%;"><a href="README.md">↩</a></span>

<table style="font-family:Helvetica,Arial;font-size:14px;line-height:1.6;">
  <tr>
  <td style="border:0;padding:0 10px 0 0;min-width:60px;max-width:100px;">
    <a href="https://www.graalvm.org/" rel="external"><img style="border:0;" src="https://www.graalvm.org/resources/img/graalvm.png" alt="GraalVM"/></a>
  </td>
  <td style="border:0;padding:0;vertical-align:text-top;">
    In the following we describe how to build/run the <b><code><a href="https://github.com/graalvm/simplelanguage" alt="SimpleLanguage">SimpleLanguage</a></code></b> (aka SL) example project on a Windows machine.<br/>In particular we show how to generate both the JVM version and the native version of the SL parser.
  </td>
  </tr>
</table>

## <span id="section_01">Project dependencies</span>

This project depends on several external software for the **Microsoft Windows** platform:

- [Apache Maven 3.6][maven_downloads] ([requires Java 7](http://maven.apache.org/docs/history.html))  ([*release notes*][maven_relnotes])
- [GraalVM Community Edition 20.1 LTS][graalvm_downloads] <sup id="anchor_01">[[1]](#footnote_01)</sup> ([*release notes*][graalvm_relnotes])
- [Microsoft Visual Studio 10][vs2010_downloads] ([*release notes*][vs2010_relnotes])
- [Microsoft Windows SDK for Windows 7 and .NET Framework 4][windows_sdk] <sup id="anchor_02a">[[2]](#footnote_02)</sup>
<!--
- [Microsoft Visual C++ 2010 Service Pack 1 Compiler Update for the Windows SDK 7.1](https://www.microsoft.com/en-us/download/details.aspx?displaylang=en&id=4422) <sup id="anchor_02b">[[2]](#footnote_02)</sup>
-->

Optionally one may also install the following software:

- [ANTLR 4.7 tool][antlr_downloads] ([*release notes*][antlr_relnotes]) <sup id="anchor_03">[[3]](#footnote_03)</sup>
- [Git 2.27][git_downloads] ([*release notes*][git_relnotes])

> **:mag_right:** Git for Windows provides a BASH emulation used to run [**`git`**][git_cli] from the command line (as well as over 250 Unix commands like [**`awk`**][man1_awk], [**`diff`**][man1_diff], [**`file`**][man1_file], [**`grep`**](https://www.linux.org/docs/man1/grep.html), [**`more`**](https://www.linux.org/docs/man1/more.html), [**`mv`**](https://www.linux.org/docs/man1/mv.html), [**`rmdir`**](https://www.linux.org/docs/man1/rmdir.html), [**`sed`**](https://www.linux.org/docs/man1/sed.html) and [**`wc`**][man1_wc].

For instance our development environment looks as follows (*June 2020*):

<pre style="font-size:80%;">
C:\opt\apache-maven-3.6.3\                            <i>( 10 MB)</i>
C:\opt\graalvm-ce-java8-20.1.0\                       <i>(670 MB)</i>
C:\opt\Git-2.27.0\                                    <i>(278 MB)</i>
C:\Program Files\Microsoft SDKs\Windows\v7.1\         <i>(333 MB)</i>
C:\Program Files (x86)\Microsoft Visual Studio 10.0\  <i>(555 MB)</i>
</pre>
<!-- 19.3.1 = 360 MB, 20.9.0 -> 670 MB, 20.1.0 -> MB -->

> **&#9755;** ***Installation policy***<br/>
> When possible we install software from a [Zip archive][zip_archive] rather than via a Windows installer. In our case we defined **`C:\opt\`** as the installation directory for optional software tools (*in reference to* the [`/opt/`][unix_opt] directory on Unix).


## Directory structure

This project is organized as follows:

<pre style="font-size:80%;">
<a href="bin/simplelanguage/build.bat">bin\simplelanguage\build.bat</a>
<a href="bin/simplelanguage/generate_parser.bat">bin\simplelanguage\generate_parser.bat</a>
<a href="bin/simplelanguage/sl.bat">bin\simplelanguage\sl.bat</a>
docs\
simplelanguage\  <i>(Git submodule)</i>
BUILD.md
<a href="README.md">README.md</a>
<a herf="setenv.bat">setenv.bat</a>
</pre>

- file [**`bin\simplelanguage\build.bat`**](bin/simplelanguage/build.bat) is the batch script for running **`mvn package`** both inside or *outside* of the *Windows SDK 7.1 Command Prompt*.
- file [**`bin\simplelanguage\generate_parser.bat`**](bin/simplelanguage/generate_parser.bat) <sup id="anchor_04">[[4]](#footnote_04)</sup> is the batch script for generating the SL parser source files.
- file [**`bin\simplelanguage\sl.bat`**](bin/simplelanguage/sl.bat) is the batch script for executing the generated SL parser.
- directory [**`docs\`**](docs/) contains SL related documentation <sup id="anchor_05">[[5]](#footnote_05)</sup>.
- directory [**`simplelanguage\`**](simplelanguage/) contains our [fork](https://github.com/michelou/simplelanguage) of the [graalvm/simplelanguage][graalvm_simplelanguage] repository as a Github submodule.
- file [**`BUILD.md`**](BUILD.md) is the [Markdown][github_markdown] document of this page.
- file [**`README.md`**](README.md) is the [Markdown][github_markdown] document describing this project.
- file [**`setenv.bat`**](setenv.bat) is the batch script for setting up our environment.

The [**`SimpleLanguage`**][graalvm_simplelanguage] example project is a [Maven project][maven_project] with five POM files (one [main](simplelanguage/pom.xml) project and four subprojects).

We added/modified the following files in the original [graalvm/simpleLanguage][github_graalvm_sl] example project:

<pre style="font-size:80%;">
component\clean_component.bat
component\make_component.bat
component\pom.xml                 <i>(modified)</i>
launcher\src\main\scripts\sl.bat
native\clean_native.bat
native\make_native.bat
native\pom.xml                    <i>(modified)</i>
</pre>

where

- directory [**`component\`**](https://github.com/michelou/simplelanguage/blob/master/component/) contains two additional batch files.
- file [**`launcher\src\main\scripts\sl.bat`**](bin/simplelanguage/sl.bat) is the batch script to be bundled into the SL distribution.
- directory [**`native\`**](https://github.com/michelou/simplelanguage/blob/master/native/) contains two additional batch files.

In the next section we give a brief description of the added batch files.

## Batch commands

We distinguish different sets of batch commands:

1. [**`build.bat`**](bin/simplelanguage/build.bat) - This batch command provides subcommands such as **`clean`** to delete the generated files (**`target`** directories), **`dist`** to generate the binary distributions (JVM and native versions) and **`parser`** to generate the [ANTLR] parser to SL (call to [**`generate_parser.bat`**](bin/simplelanguage/generated_parser.bat)).
    > **:mag_right:** Command [**`build.bat`**](bin/simplelanguage/build.bat) differs in two ways from command **`mvn package`**:<br/>
    > - it can also be executed *outside* of the *Windows SDK 7.1 Command Prompt*.<br/>
    > - it generates a distribution-ready output (see section [**Usage examples**](#section_04)).

    <pre style="font-size:80%;">
    <b>&gt; <a href="bin/simplelanguage/build.bat">build</a> help</b>
    Usage: build { &lt;option&gt; | &lt;subcommand&gt; }
    &nbsp;
      Options:
        -debug      show commands executed by this script
        -native     generate executable (native-image)
        -timer      display total elapsed time
        -verbose    display progress messages
    &nbsp;
      Subcommands:
        clean       delete generated files
        dist        generate binary distribution
        help        display this help message
        parser      generate ANTLR parser for SL
        test        test binary distribution
        update      fetch/merge local directories simplelanguage</pre>

3. [**`generate_parser.bat`**](bin/simplelanguage/generate_parser.bat) - This batch command generates the [ANTLR](https://www.antlr.org/) parser from the grammar file [**`SimpleLanguage.g4`**](./language/src/main/java/com/oracle/truffle/sl/parser/SimpleLanguage.g4). Compared to the corresponding shell script [**`generate_parser`**](generate_parser), it also provides subcommand **`clean`** and subcommand **`test`** to run a single test (same as in file [**`.travis.yml`**](.travis.yml)).

    <pre style="font-size:80%;">
    <b>&gt; <a href="bin/simplelanguage/generate_parser.bat">generate_parser</a> help</b>
    Usage: generate_parser { &lt;option&gt; | &lt;subcommand&gt; }
    &nbsp;
      Options:
        -debug      display commands executed by this script
        -verbose    display progress messages
    &nbsp;
      Subcommands:
        clean       delete generated files
        help        display this help message
        test        perform test with generated ANTLR parser</pre>

4. [**`sl.bat`**](sl.bat) - This batch command performs the same operations as the corresponding shell script [**`sl`**](sl) (called from [Travis job](https://docs.travis-ci.com/user/job-lifecycle/) **`script`** in file [**`.travis.yml`**](.travis.yml)).

5. [**`component\clean_component.bat`**](bin/simplelanguage/component/clean_component.bat) and [**`component\make_component.bat`**](bin/simplelanguage/component/make_component.bat) - These two batch commands are called from the POM file [**`component\pom.xml`**](bin/simplelanguage/component/pom.xml) as their shell equivalents.

6. [**`launcher\src\main\scripts\sl.bat`**](launcher/src/main/scripts/sl.bat) - This batch command is a minimized version of [**`sl.bat`**](sl.bat); command [**`build dist`**](build.bat) does add it to the generated binary distribution (see [**next section**](#section_04)).

7. [**`native\clean_native.bat`**](bin/simplelanguage/native/clean_native.bat) and [**`native\make_native.bat`**](native/make_native.bat) - These two batch commands are called from the POM file [**`native\pom.xml`**](native/pom.xml) as their shell equivalents.


## <span id="section_04">Usage examples</span>

#### `setenv.bat`

Command [**`setenv`**](setenv.bat) is executed once to setup our development environment; it makes external tools such as [**`mvn.cmd`**][mvn_cmd], [**`git.exe`**][git_cli] and [**`cl.exe`**][windows_cl] directly available from the command prompt:

<pre style="font-size:80%;">
<b>&gt; <a href="setenv.bat">setenv</a></b>
Tool versions:
   javac 1.8.0_252, mvn 3.6.3, cl 16.00.40219.01 for x64
   dumpbin 10.00.40219.01, link 10.00.40219.01, uuidgen v1.01
   git 2.27.0.windows.1, diff 3.7 bash 4.4.23(1)-release

<b>&gt; where javac mvn</b>
C:\opt\graalvm-ce-java8-20.1.0\bin\javac.exe
C:\opt\apache-maven-3.6.3\bin\mvn
C:\opt\apache-maven-3.6.3\bin\mvn.cmd
</pre>

Command [**`setenv -verbose`**](setenv.bat) also displays the tool paths:

<pre style="font-size:80%;">
<b>&gt; <a href="setenv.bat">setenv</a> -verbose</b>
Tool versions:
   javac 1.8.0_252, mvn 3.6.3, cl 16.00.40219.01 for x64
   dumpbin 10.00.40219.01, link 10.00.40219.01, uuidgen v1.01
   git 2.27.0.windows.1, diff 3.7 bash 4.4.23(1)-release
Tool paths:
   C:\opt\graalvm-ce-java8-20.1.0\bin\javac.exe
   C:\opt\apache-maven-3.6.3\bin\mvn.cmd
   C:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\bin\amd64\cl.exe
   C:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\bin\amd64\dumpbin.exe
   C:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\bin\amd64\link.exe
   C:\opt\Git-2.27.0\usr\bin\link.exe
   C:\Program Files\Microsoft SDKs\Windows\v7.1\Bin\x64\Uuidgen.Exe
   C:\opt\Git-2.27.0\bin\git.exe
   C:\opt\Git-2.27.0\mingw64\bin\git.exe
   C:\opt\Git-2.27.0\usr\bin\diff.exe
   C:\opt\Git-2.27.0\bin\bash.exe
</pre>


Command [**`setenv -nosdk`**](setenv.bat) is aimed at advanced users; we use option **`-nosdk`** to work with a reduced set of environment variables (4 variables in our case) instead of relying on the *"Windows SDK 7.1 Command Prompt"* shortcut (target **`C:\Program Files\Microsoft SDKs\Windows\v7.1\Bin\SetEnv.cmd`**) to setup our development environment.

#### `simplelanguage\build.bat`

Directory **`simplelanguage\`** contains our fork of the [graalvm/simplelanguage][graalvm_simplelanguage] repository; it is setup as follows:

<pre style="font-size:80%;">
<b>&gt; cp bin\simplelanguage\*.bat simplelanguage</b>
<b>&gt; cd simplelanguage</b>
</pre>

Command [**`build.bat -verbose clean`**](bin/simplelanguage/build.bat) deletes all output directories.

<pre style="font-size:80%;">
<b>&gt; <a hre="bin/simplelanguage/build.bat">build</a> -verbose clean</b>
Delete directory S:\simplelanguage\component\target
Delete directory S:\simplelanguage\language\target
Delete directory S:\simplelanguage\launcher\target
Delete directory S:\simplelanguage\native\target
Delete directory S:\simplelanguage\target
</pre>

> **:mag_right:** Unlike the other shell scripts [**`component\make_component.sh`**](https://github.com/michelou/simplelanguage/component/make_component.sh) generates its output directly into directory **`component\`** instead of **`component\target\`**. We changed that behavior: the corresponding batch file [**`component\make_component.bat`**](bin/simplelanguage/component/make_component.bat) generates its output into directory **`component\target\`**.

Command [**`build.bat -native -verbose dist`**](bin/simplelanguage/build.bat) generates both the JVM version and the native version of our application.

<pre style="font-size:80%;">
<b>&gt; <a hre="bin/simplelanguage/build.bat">build</a> -verbose -native dist</b>
[INFO] Scanning for projects...
[...]
[INFO] ------------------------------------------------------------------------
[INFO] Reactor Build Order:
[INFO]
[INFO] simplelanguage-parent                                              [pom]
[INFO] simplelanguage                                                     [jar]
[INFO] launcher                                                           [jar]
[INFO] simplelanguage-graalvm-native                                      [pom]
[INFO] simplelanguage-graalvm-component                                   [pom]
[INFO]
[INFO] ------------------< com.oracle:simplelanguage-parent >------------------
[INFO] Building simplelanguage-parent 20.1.0                              [1/5]
[INFO] --------------------------------[ pom ]---------------------------------
[...]
[INFO] --------------< com.oracle:simplelanguage-graalvm-native >--------------
[INFO] Building simplelanguage-graalvm-native 20.1.0                      [4/5]
[INFO] --------------------------------[ pom ]---------------------------------
[INFO]
[INFO] --- exec-maven-plugin:1.6.0:exec (make_native) @ simplelanguage-graalvm-native ---
[S:\SIMPLE~3\native\target\slnative:1136]    classlist:   8,658.29 ms,  1.18 GB
[S:\SIMPLE~3\native\target\slnative:1136]        (cap):  10,003.99 ms,  1.18 GB
[S:\SIMPLE~3\native\target\slnative:1136]        setup:  12,775.64 ms,  1.66 GB
[S:\SIMPLE~3\native\target\slnative:1136]   (typeflow):  14,192.54 ms,  2.72 GB
[S:\SIMPLE~3\native\target\slnative:1136]    (objects):   9,993.13 ms,  2.72 GB
[S:\SIMPLE~3\native\target\slnative:1136]   (features):   1,650.79 ms,  2.72 GB
[S:\SIMPLE~3\native\target\slnative:1136]     analysis:  27,173.58 ms,  2.72 GB
[S:\SIMPLE~3\native\target\slnative:1136]     (clinit):     704.98 ms,  3.14 GB
1540 method(s) included for runtime compilation
[S:\SIMPLE~3\native\target\slnative:1136]     universe:   2,130.45 ms,  3.14 GB
[S:\SIMPLE~3\native\target\slnative:1136]      (parse):   2,871.55 ms,  3.14 GB
[S:\SIMPLE~3\native\target\slnative:1136]     (inline):   2,355.13 ms,  3.17 GB
[S:\SIMPLE~3\native\target\slnative:1136]    (compile):  20,474.66 ms,  5.30 GB
[S:\SIMPLE~3\native\target\slnative:1136]      compile:  27,249.08 ms,  5.30 GB
[S:\SIMPLE~3\native\target\slnative:1136]        image:   2,311.41 ms,  5.30 GB
[S:\SIMPLE~3\native\target\slnative:1136]        write:   3,310.33 ms,  5.30 GB
[S:\SIMPLE~3\native\target\slnative:1136]      [total]:  84,987.77 ms,  5.30 GB
[INFO]     
[INFO] ------------< com.oracle:simplelanguage-graalvm-component >-------------
[INFO] Building simplelanguage-graalvm-component 20.1.0                   [5/5]
[INFO] --------------------------------[ pom ]---------------------------------
[INFO]   
[INFO] --- exec-maven-plugin:1.6.0:exec (make_component) @ simplelanguage-graalvm-component ---
[INFO] ------------------------------------------------------------------------
[INFO] Reactor Summary for simplelanguage-parent 20.1.0:
[INFO]
[INFO] simplelanguage-parent .............................. SUCCESS [  0.038 s]
[INFO] simplelanguage ..................................... SUCCESS [ 13.497 s]
[INFO] launcher ........................................... SUCCESS [  1.338 s]
[INFO] simplelanguage-graalvm-native ...................... SUCCESS [05:17 min]
[INFO] simplelanguage-graalvm-component ................... SUCCESS [  2.041 s]
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time:  05:35 min
[INFO] Finished at: 2020-06-13T21:32:24+02:00
[INFO] ------------------------------------------------------------------------
Copy file simplelanguage-20.1.0.jar to directory "target\sl\lib\"
Copy file launcher-20.1.0.jar to directory "target\sl\lib\"
Copy file antlr4-runtime-4.7.2.jar to directory "target\sl\lib\"
Copy file sl.bat to directory "target\sl\bin\"
Copy file slnative.exe to directory "target\sl\bin\"
</pre>

> **:mag_right:** Omitting option **`-native`** (which controls the **`SL_BUILD_NATIVE`** environment variable) will skip step 4:
> <pre style="font-size:80%;">
> [...]
> [INFO] --- exec-maven-plugin:1.6.0:exec (make_native) @ simplelanguage-graalvm-native ---
> Skipping the native image build because SL_BUILD_NATIVE is set to false.
> [...]
> </pre>

Output directory is **`target\sl\`**; its structure looks as follows:

<pre style="font-size:80%;">
<b>&gt; tree /f target | findstr /v /b "[A-Z]"</b>
\---sl
    +---bin
    |       sl.bat
    |       slnative.exe
    |
    \---lib
            antlr4-runtime-4.7.2.jar
            launcher-20.1.0.jar
            simplelanguage-20.1.0.jar
</pre>

> **:mag_right:** As expected the file sizes for the JVM and native versions are very different:
> <pre style="font-size:80%;">
> <b>&gt; where /t /r target\sl\lib *.jar</b>
>    337904   22.07.2019      17:41:46  S:\simplelanguage\target\sl\lib\antlr4-runtime-4.7.2.jar
>      6000   13.06.2020      21:27:04  S:\simplelanguage\target\sl\lib\launcher-20.1.0.jar
>    404099   13.06.2020      21:27:02  S:\simplelanguage\target\sl\lib\simplelanguage-20.1.0.jar
>
> <b>&gt; where /t /r target\sl\bin *.exe</b>
>  27879936   13.06.2020      21:32:21  S:\simplelanguage\target\sl\bin\slnative.exe
> </pre>

We can now execute both versions (JVM and native) of our application:

<pre style="font-size:80%;">
<b>&gt; target\sl\bin\sl.bat language\tests\Add.sl</b>
== running on org.graalvm.polyglot.Engine@3ac42916
7
34
34
34
4000000000003
3000000000004
7000000000000

<b>&gt; target\sl\bin\slnative.exe language\tests\Add.sl</b>
== running on org.graalvm.polyglot.Engine@3d2bb78
7
34
34
34
4000000000003
3000000000004
7000000000000
</pre>

> **:mag_right:** For instance we can use command [**`dumpbin`**][windows_dumpbin] to display the definitions exported from executable **`slnative.exe`** whose name starts with **`graal_`**:
> <pre style="font-size:80%;">
> <b>&gt; dumpbin /exports target\sl\bin\slnative.exe | awk '/[A-F0-9] graal_/ {print $4}'</b>
> graal_attach_thread
> graal_create_isolate
> graal_detach_thread
> graal_detach_threads
> graal_get_current_thread
> graal_get_isolate
> graal_tear_down_isolate
> </pre>


#### `simplelanguage\generate_parser.bat`

Command [**`generate_parser.bat`**](bin/simplelanguage/generate_parser.bat) with no arguments produces the lexer/parser files for the [**`SimpleLanguage`**][graalvm_simplelanguage] example.

Output directory is **`target\parser\`**; its structure looks as follows:

<pre style="font-size:80%;">
<b>&gt; tree /a /f target | findstr /v /b "[A-Z]"</b>
\---parser
    +---libs
    |       antlr-4.7.2-complete.jar
    |
    \---src
            SimpleLanguage.interp
            SimpleLanguage.tokens
            SimpleLanguageLexer.interp
            SimpleLanguageLexer.java
            SimpleLanguageLexer.tokens
            SimpleLanguageParser.java
</pre>

Command [**`generate_parser test`**](bin/simplelanguage/generate_parser.bat) compiles the lexer/parser files from directory **`target\parser\src\`** with source files from [**`language\src\`**](https://github.com/michelou/simplelanguage/language/src/) and executes the SL main class [**`SLMain`**](https://github.com/michelou/simplelanguage/blob/master/launcher/src/main/java/com/oracle/truffle/sl/launcher/SLMain.java). 

Output directory **`target\parser\`** now contains two additional elements:<br/>
- the [argument file](https://docs.oracle.com/javase/7/docs/technotes/tools/windows/javac.html#commandlineargfile) **`source_list.txt`**<br/>
- the subdirectory **`classes\**\*.class`**:

<pre style="font-size:80%;">
<b>&gt; tree /a /f target | findstr /v /b "[A-Z]"</b>
\---parser
    |   source_list.txt
    |
    +---classes
    |   +---com
    |   |   \---oracle
    |   |       \---truffle
    |   |           \---sl
    |   |               |   *.class
    |   |               \   **/*.class
    |   |
    |   \---META-INF
    |       \---truffle
    |               language
    |
    +---libs
    |       antlr-4.7.2-complete.jar
    |
    \---src
            SimpleLanguage.interp
            SimpleLanguage.tokens
            SimpleLanguageLexer.interp
            SimpleLanguageLexer.java
            SimpleLanguageLexer.tokens
            SimpleLanguageParser.java
</pre>

Adding option **`-verbose`** to the above command (i.e. [**`generate_parser -verbose test`**](bin/simplelanguage/generate_parser.bat)) additionally displays progress messages: 

<pre style="font-size:80%;">
<b>&gt; <a href="bin/simplelanguage/generate_parser.bat">generate_parser</a> -verbose test</b>
Generate ANTLR parser files into directory S:\target\parser\src
Compile Java source files to directory S:\target\parser\classes
Execute test with SimpleLangage example tests\Add.sl
== running on org.graalvm.polyglot.Engine@e580929
7
34
34
34
4000000000003
3000000000004
7000000000000
</pre>

Replacing option **`-verbose`** by **`-debug`** in the above command (i.e. [**`generate_parser -debug test`**](bin/simplelanguage/generate_parser.bat)) displays the internally executed commands:

<pre style="font-size:80%;">
<b>&gt; <a href="bin/simplelanguage/generate_parser.bat">generate_parser</a> -debug test</b>
[generate_parser] _DEBUG=1 _TEST=1 _VERBOSE=0
[generate_parser] java.exe -cp S:\target\parser\libs\antlr-4.7.2-complete.jar org.antlr.v4.Tool -package com.oracle.truffle.sl.parser -no-listener S:\language\src\main\java\com\oracle\truffle\sl\parser\SimpleLanguage.g4 -o S:\target\parser\src
[generate_parser] javac.exe -cp ;C:\opt\graalvm-ce-java8-20.1.0\jre\lib\truffle\locator.jar;C:\opt\graalvm-ce-java8-20.1.0\jre\lib\truffle\truffle-api.jar;C:\opt\graalvm-ce-java8-20.1.0\jre\lib\truffle\truffle-dsl-processor.jar;C:\opt\graalvm-ce-java8-20.1.0\jre\lib\truffle\truffle-tck.jar;S:\target\parser\libs\antlr-4.7.2-complete.jar;S:\target\parser\classes -d "S:\target\parser\classes" @"S:\target\parser\source_list.txt"
[generate_parser] java.exe  -Dtruffle.class.path.append=S:\target\parser\libs\antlr-4.7.2-complete.jar;S:\target\parser\classes -cp ;C:\opt\graalvm-ce-java8-20.1.0\jre\lib\truffle\locator.jar;C:\opt\graalvm-ce-java8-20.1.0\jre\lib\truffle\truffle-api.jar;C:\opt\graalvm-ce-java8-20.1.0\jre\lib\truffle\truffle-dsl-processor.jar;C:\opt\graalvm-ce-java8-20.1.0\jre\lib\truffle\truffle-tck.jar;S:\target\parser\libs\antlr-4.7.2-complete.jar;S:\target\parser\classes com.oracle.truffle.sl.parser.SLMain "S:\language\tests\Add.sl"
== running on org.graalvm.polyglot.Engine@56cbfb61
7
34
34
34
4000000000003
3000000000004
7000000000000
[generate_parser] _EXITCODE=0
</pre>


#### `simplelanguage\sl.bat`

Usage of command [**`sl.bat`**](bin/simplelanguage/sl.bat) is described on the documentation page ["Introduction to SimpleLanguage"](https://www.graalvm.org/docs/graalvm-as-a-platform/implement-language/) of the [GraalVM] website; we resume its usage below:

<pre style="font-size:80%;">
sl { &lt;option&gt; } [ &lt;file_path&gt; ]
</pre>

where **`<option>`** takes one of the following forms:

- **`-debug`**, **`-dump`**, **`-disassemble`**
- **`-J`**[**`<java_option>`**](https://docs.oracle.com/javase/8/docs/technotes/tools/windows/java.html), eg. **`-J-Xmx4M`**, **`-J-XshowSettings:vm`**,<br/>**`-J-Dgraal.ShowConfiguration=(none|info|verbose)`**
- or **`--<key>=<value>`**, eg. **`--log.level=FINE`** (see example below)

For instance passing [**`language\tests\Add.sl`**](https://github.com/michelou/simplelanguage/blob/master/language/tests/Add.sl) as argument generates the following output:

<pre style="font-size:80%;">
<b>&gt; <a href="bin/simplelanguage/sl.bat">sl</a> language\tests\Add.sl</b>
== running on org.graalvm.polyglot.Engine@47d384ee
7
34
34
34
4000000000003
3000000000004
7000000000000
</pre>

Command [**`sl`**](bin/simplelanguage/sl.bat) also accepts **`--<key>=<value>`** options; those are handled by the main class [**`SLMain`**](https://github.com/michelou/simplelanguage/blob/master/launcher/src/main/java/com/oracle/truffle/sl/launcher/SLMain.java) and are passed to the GraalVM [execution engine](https://www.graalvm.org/sdk/javadoc/org/graalvm/polyglot/Engine.html).

| *Option* (key/value) | *Description* |
| :------- | :------------ |
| <code>--engine.Inlining=&lt;value&gt;</code> | Controls inlining.<br/> Values: <code>true</code> or <code>false</code> |
| <a href="https://docs.oracle.com/javase/8/docs/api/java/util/logging/Level.html"><code>--log.level=&lt;value&gt;</code></a> | Controls the logging output.<br/>Values: <code>SEVERE</code>, <code>WARNING</code>, .., <code>FINEST</code> |

For instance, the SL source file [**`Fibonacci.sl`**](/simplelanguage/blob/master/language/tests/Fibonacci.sl) defines the two functions **`main`** and **`fib`** which are listed together with the SL built-in functions when specifying option [**`--log.level=FINE`**](https://docs.oracle.com/javase/8/docs/api/java/util/logging/Level.html).

<pre style="font-size:80%;">
<b>&gt; <a href="bin/simplelanguage/sl.bat">sl</a> "--log.level=FINE" language\tests\Fibonacci.sl</b>
== running on org.graalvm.polyglot.Engine@e580929
[sl::SLFunction] FINE: Installed call target for: readln
[sl::SLFunction] FINE: Installed call target for: print
[sl::SLFunction] FINE: Installed call target for: println
[sl::SLFunction] FINE: Installed call target for: nanoTime
[sl::SLFunction] FINE: Installed call target for: defineFunction
[sl::SLFunction] FINE: Installed call target for: stacktrace
[sl::SLFunction] FINE: Installed call target for: helloEqualsWorld
[sl::SLFunction] FINE: Installed call target for: new
[sl::SLFunction] FINE: Installed call target for: eval
[sl::SLFunction] FINE: Installed call target for: import
[sl::SLFunction] FINE: Installed call target for: getSize
[sl::SLFunction] FINE: Installed call target for: hasSize
[sl::SLFunction] FINE: Installed call target for: isExecutable
[sl::SLFunction] FINE: Installed call target for: isNull
[sl::SLFunction] FINE: Installed call target for: wrapPrimitive
[sl::SLFunction] FINE: Installed call target for: main
[sl::SLFunction] FINE: Installed call target for: fib
1: 1
2: 1
3: 2
4: 3
5: 5
6: 8
7: 13
8: 21
9: 34
10: 55
</pre>

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
<p style="margin:0 0 1em 20px;">
In our case we downloaded the following installation files (see section <a href="#section_01"><b>Project dependencies</b></a>):
</p>
<pre style="margin:0 0 1em 20px; font-size:80%;">
<a href="https://archive.apache.org/dist/ant/binaries/">apache-maven-3.6.3-bin.zip</a>          <i>(  8 MB)</i>
<a href="https://github.com/oracle/graal/releases/tag/vm-20.1.0">graalvm-ce-windows-amd64-20.1.0.zip</a> <i>(170 MB)</i>
<a href="https://www.microsoft.com/en-us/download/details.aspx?id=8442">GRMSDKX_EN_DVD.iso</a>                  <i>(570 MB)</i>
<a href="https://www.microsoft.com/en-us/download/details.aspx?displaylang=en&id=4422">VC-Compiler-KB2519277.exe</a>           <i>(121 MB)</i>
</pre>

<a name="footnote_03">[3]</a> ***ANTLR distributions*** [↩](#anchor_03)

<p style="margin:0 0 1em 20px;">
There exists two binary distributions of <a href="https://www.antlr.org/download/">ANTLR 4</a>: ANTLR tool and ANTLR runtime (with bindings to Java, JavaScript, C# and C++). Batch command <a href="bin/simplelanguage/generate_parser.bat"</a><b><code>generate_parser</code></b></a> requires ANTLR tool (<i>and</i> will download it if not present in output directory <b><code>target\parser\libs\</code></b>). 
</p>
<pre style="margin:0 0 1em 20px; font-size:80%;">
<b>&gt; java -cp target\parser\libs\antlr-4.7.2-complete.jar org.antlr.v4.Tool | findstr Version</b>
ANTLR Parser Generator  Version 4.7.2
</pre>

<a name="footnote_04">[4]</a> ***Parser generation*** [↩](#anchor_04)

<p style="margin:0 0 1em 20px;">
Batch file <a href="bin/simplelanguage/generate_parser.bat"><b><code>generate_parser.bat</code></b></a> delegates the addition of the copyright notice to the generated source files to the PowerShell script <a href="bin/simplelanguage/generate_parser.ps1"><b><code>generate_parser.ps1</code></b></a>.
</p>

<a name="footnote_05">[5]</a> ***EBNF grammar*** [↩](#anchor_05)

<p style="margin:0 0 1em 20px;">
We used the online tool <a href="https://www.bottlecaps.de/rr/ui">Railroad Diagram Generator</a> to generate the PNG images presented in file <a href="docs/ebnf/SimpleLanguage.md"><b><code>docs\ebnf\SimpleLanguage.md</code></b></a> (based on the grammar file <a href="docs/ebnf/SimpleLanguage.ebnf"><b><code>docs\ebnf\SimpleLanguage.ebnf</code></b></a>).
</p>

<a name="footnote_05">[5]</a> ***Missing library `hsdis-amd64.dll`*** [↩](#anchor_05)

<p style="margin:0 0 1em 20px;">
Command <b><code>sl -disassemble</code></b> generates the error message <code>Could not load hsdis-amd64.dll</code> with some <b><code>.sl</code></b> files:
</p>
<pre style="margin:0 0 1em 20px; font-size:80%;">
<b>&gt; sl -disassemble language\tests\SumPrint.sl</b>
CompilerOracle: print *OptimizedCallTarget.callRoot
CompilerOracle: exclude *OptimizedCallTarget.callRoot
OpenJDK 64-Bit GraalVM CE 20.1.0 warning: printing of assembly code is enabled; turning on DebugNonSafepoints to gain additional output
== running on org.graalvm.polyglot.Engine@783e6358
[...]
Could not load hsdis-amd64.dll; library not loadable; PrintAssembly is disabled
</pre>
<p style="margin:0 0 1em 20px;">
Since library file <b><code>hsdis-amd64.dll</code></b> is not available anywhere we have to <a href="https://dropzone.nfshost.com/hsdis/">build it ourself</a>.
</p>
<p style="margin:0 0 1em 20px;">
DZone article "<i><a href="https://dzone.com/articles/running-xccompilecommand-on-windows">Running -XX:CompileCommand on Windows</a></i>" by Dustin Marx (September 7, 2016) provdies more information about that topics.
</p>

***

*[mics](https://lampwww.epfl.ch/~michelou/)/June 2020* [**&#9650;**](#top)
<span id="bottom">&nbsp;</span>

<!-- link refs -->

[antlr]: https://www.antlr.org/
[antlr_downloads]: https://www.antlr.org/download.html
[antlr_relnotes]: https://github.com/antlr/antlr4/releases/tag/4.7.2
[git_cli]: https://git-scm.com/docs/git
[git_downloads]: https://git-scm.com/download/win
[git_relnotes]: https://raw.githubusercontent.com/git/git/master/Documentation/RelNotes/2.27.0.txt
[github_graalvm_sl]: https://github.com/graalvm/simplelanguage
[github_markdown]: https://guides.github.com/features/mastering-markdown/
[graalvm]: https://www.graalvm.org/
[graalvm_downloads]: https://github.com/oracle/graal/releases
[graalvm_relnotes]: https://www.graalvm.org/docs/release-notes/20_0/
[graalvm_simplelanguage]: https://github.com/graalvm/simplelanguage
[man1_awk]: https://www.linux.org/docs/man1/awk.html
[man1_diff]: https://www.linux.org/docs/man1/diff.html
[man1_file]: https://www.linux.org/docs/man1/file.html
[man1_wc]: https://www.linux.org/docs/man1/wc.html
[maven_downloads]: http://maven.apache.org/download.cgi
[maven_project]: https://maven.apache.org/guides/getting-started/
[maven_relnotes]: http://maven.apache.org/docs/3.6.3/release-notes.html
[mvn_cmd]: https://maven.apache.org/guides/introduction/introduction-to-the-lifecycle.html
[unix_opt]: http://tldp.org/LDP/Linux-Filesystem-Hierarchy/html/opt.html
[vs2010_downloads]: https://visualstudio.microsoft.com/vs/older-downloads/
[vs2010_relnotes]: https://docs.microsoft.com/en-us/visualstudio/releasenotes/vs2010-version-history
[windows_cl]: https://docs.microsoft.com/en-us/cpp/build/reference/compiling-a-c-cpp-program?view=vs-2019
[windows_dumpbin]: https://docs.microsoft.com/en-us/cpp/build/reference/dumpbin-reference?view=vs-2019
[windows_sdk]: https://www.microsoft.com/en-us/download/details.aspx?id=8442
[zip_archive]: https://www.howtogeek.com/178146/htg-explains-everything-you-need-to-know-about-zipped-files/
