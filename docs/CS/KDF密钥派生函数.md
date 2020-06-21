# kDF密钥派生函数

<span id='toc'></span>
[TOC]

## [ANS X9.63-KDF](#toc)

记有数据$Z$, [哈希](https://www.cnblogs.com/mengsuenyan/p/12697811.html)函数$Hash$(hash值的字节长度为$l$), 需要输出的密钥数据字节长度位$k$, 及可选的附加数据$SharedInfo$;

- $Counter=0x00000001$;
- 从$i=0$迭代到$\lceil k/l \rceil$:
  - $K_i=Hash(Z||Counter||SharedInfo)$;
  - $Counter+=1$
- 取$K_0||K_1||\dots ||K_{\lceil k/l \rceil}$最左边$k$个字节赋给$K$;
- 输出$K$;

符号说明: $X||Y$: 表示$Y$拼接在$X$之后;

## [IKEv2-KDF](#toc)

## [TLS-KDF](#toc)

## [NIST-800-56-Cantenation-KDF](#toc)

## [参考资料](#toc)

[1]. Standars for Efficient Cryptography 1 (SEC1: Elliptic Curve Cryptography), Daniel R.L.Brown;
[2]. ANSI-X9.63-KDF;
[3]. IKEv2-KDF;
[4]. TLS-KDF;
[5]. NIST-800-56-Concatenation-KDF;
