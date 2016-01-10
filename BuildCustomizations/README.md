## Support for custom build type in Visual Studio.

1. Put all files from this folder into **"BuildCustomizations"** directory of Visual Studio.<br/>
*For example for VS 2015 a path will be like that:* **%ProgramFiles%\MSBuild\Microsoft.Cpp\v4.0\V140\BuildCustomizations\**
2. Find in file **SugarCpp.props** this line<br/>
*&lt;CommandLineTemplate&gt;D:\SugarCpp\SugarCpp.CommandLine.exe [AllOptions] [AdditionalOptions] [Inputs]&lt;/CommandLineTemplate&gt;*
3. Correct path for SugarCpp command line compiler on **your** computer.

Now all files with *.sc extension will be build to corresponding *.h and *.cpp files automatically whenever you build your project or solution.

But VS don't automatically include newly generated files - and I haven't found a way to do so.
You just have to **manually** once include these *.h and *.cpp files in project after the first build.
