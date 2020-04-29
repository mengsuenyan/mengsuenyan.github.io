# 常用校验和算法

<span id='toc'></span>
[TOC]

## [Adler-32校验和](#toc)

记校验和为$C$(32位), 其高16位记为$s_2$, 低16位记为$s_1$, 那么有$C=s_2 * 2^{16} + s_1$. 记有数据字节流$D[0..len]$ 算法过程如下:

$$
\begin{aligned}
& s_1 = 1u32 \\
& s_2 = 0u32 \\
& M = 65521(小于65536的最大质数) \\
& \quad \\
& for \quad d \quad in \quad D \\
& \qquad s_1 = (s_1 + d) \mod M \\
& \qquad s_2 = (s_1 + s_2) \mod M \\
& end \\
& \quad \\
& C = s_2 \ll 16 + s_1
\end{aligned}
$$

## [CRC校验](#toc)

记有生成多项式$G(x)$的二进制表示$g[0..m]$, 有字节流数据$F(x)$其二进制位表示为$f[0..n]$, 记校验和为$C$(m-1位), 算法流程如下:

$$
\begin{aligned}
& C = 0; g=g[0]*2^{0}+g[1]*2^{1}+\cdots+g[m-1]*2^{m-1} \\
& src = 0 \\
& \quad \\
& for \quad bit \quad in \quad f \\
& \qquad src = (src \ll 1) + bit\\
& \qquad if \quad src \ge g \\
& \qquad \qquad src = src \mod g\\
& \qquad end  \\
& end \\
& C = src
\end{aligned}
$$

## [Fnv算法](#toc)

Fnv算法目前在用的有两个版本`Fnv-1`和`Fnv-1a`. 记有校验和$C$(共有$2^{n}$位), 有字节流数据$D[0..len]$, 算法流程如下: 

- Fnv-1:

$$
\begin{aligned}
& C = INV \\
& for \quad d \quad in \quad D \\
& \qquad C = C * P \\
& \qquad C = C \oplus d \\
& end
\end{aligned}
$$

- Fnv-1a:

$$
\begin{aligned}
& C = INV \\
& for \quad d \quad in \quad D \\
& \qquad C = C \oplus d \\
& \qquad C = C * P \\
& end
\end{aligned}
$$

- $x\oplus y$: x异或y;
- INV: 初始Hash值;
- P: 质数;

对于$C$不同的位长度, INV和P的值如下:

```C
// 32位
INV = 2166136261;
P = 16777619;   // 2^24+2^8+0x93

// 64位
INV = 14695981039346656037;
P = 1099511628211;  // 2^40+2^8+0xb3

// 128位
INV = 0x6c62272e07bb014262b821756295c58d;
P = 0x13b+2^88;     // 2^88+2^8+0x3b
```
