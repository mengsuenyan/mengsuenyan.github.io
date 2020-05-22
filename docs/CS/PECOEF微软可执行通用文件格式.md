# PECOEF

<span id='toc'></span>
[TOC]

## [文件格式](#toc)

### [.exe](#toc)

- EXE Header;
- OEM Identifer, OEM Information;
- Relocation Table;
- PE Header;
- Section Headers;
- Image Pages;
  - import info;
  - export info;
  - fix-up info;
  - resource info;
  - debug info;

### [Object Module](#toc)

- COEFF header;
- section headers;
- image pages:
  - fix-up info;
  - debug info;

### [特殊段](#toc)

- `.arch`: 架构信息;
- `.bss`: 未初始化数据;
- `.data`: 初始化数据
- `.idata`: 导入表;
- `.edata`: 导出表;
- `.pdata`: 异常信息;
- `.rdata`: 只读数据;
- `.reloc`: 重定位映像;
- `.rsrc`: 资源目录;
- `.text`: 可执行代码;
- `.tls`: 线程存储数据(Thread Local Storage);
- `.xdata`: 异常信息;
