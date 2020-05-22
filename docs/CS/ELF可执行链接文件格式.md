# ELF

<span id='toc'></span>
[TOC]

## [目标文件格式](#toc)

目标文件格式分为三种类型:

- 可重定位文件: 保存代码和适当的数据, 用来和其他的目标文件一起来创建一个可执行文件或者共享目标文件;
- 可执行文件: 保存了可执行程序, 该文件指出了`exec`如何来创建程序进程映像;
- 共享目标文件: 保存代码和适当的数据, 可以通过ld链接编辑器与其他共享目标文件或可重定位文件一起来创建其他共享目标文件. 另外还可以通过动态链接器, 和其他共享目标文件或可执行文件一起创建一个进程映像;

### [特殊section](#toc)

- `.bss`: 保存未初始化的数据, 这些数据存在于内存映像中, 该section不占用文件空间;
- `.comment`: 版本控制信息;
- `.data`: 保存初始化数据;
- `.data1`: 保存初始化数据;
- `.debug`: 保存调试符号信息;
- `.dynamic`: 保存动态链接信息和`SHF_ALLOC/SHF_WRITE`属性;
- `.hash`: 保存符号哈希表;
- `.line`: 保存用于调试的行号信息;
- `.rodata/.rodata1`: 保存只读数据;
- `.shstrtab`: 保存section段名;
- `.strtab`: 保存字符串;
- `.symtab`: 保存符号表;
- `.text`: 保存代码(可执行指令);

## [参考资料](#toc)

1. Tool Interface Standard(TIS) Executable and Linking Format(ELF) Specification V1.1;
2. Tool Interface Standard(TIS) Executable and Linking Format(ELF) Specification V1.2;
