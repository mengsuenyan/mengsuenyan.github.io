# CMAC基于块加密的消息认证码

<span id='ioc'></span>
[TOC]

## [Subkey Generation](#toc)

- $R_{128} = 0^{120}10000111; R_{64}=0^{59}11011$;
- $Cipher_{K}$指密钥为$K$的加密函数;

$$
\begin{aligned}
& b = Cipher_{K}.block\_size() \\
& L = Cipher_{K}(0^b) \\
& K_1 = L \ll 1 \quad if\quad MSB_{1}(L) = 0,\quad otherwise \quad (L \ll 1) \oplus R_{b} \\
& K_2 = K_1 \ll 1 \quad if\quad MSB_{1}(K_1),\quad otherwise \quad (K_1 \ll 1) \oplus R_{b} \\
& return \quad (K_1, K_2)
\end{aligned}
$$

## [MAC Generation](#toc)

$$
\begin{aligned}
& n = 1 \quad if \quad len(M) = 0, \quad otherwise\quad \lceil len(M)/b \rceil \\
& M = M_1 || M_2 || \dots || M_{n-1} || M_n^{*} \\
& M_n = M_n^{*} \oplus K_1\quad if\quad len(M)\mod b = 0,\quad otherwise\quad K_2 \oplus (M_n^{*} || 10^j),\quad j = n*b - (len(M)\mod b)\\
& C_0 = 0^b \\
& C_i = Cipher_{K}(C_{i-1}\oplus M_i) \\
& return\quad C_i
\end{aligned}
$$

## [MAC Verification](#toc)

$$
T' = CMAC(K, M)
$$

## [参考资料](#toc)

- SP 800-38B;
