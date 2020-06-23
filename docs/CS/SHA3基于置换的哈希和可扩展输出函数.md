# SHA3 基于置换的哈希和可扩展输出函数

<span id='toc'></span>
[TOC]

## [Hash](#toc)

记有消息$M$, SHA-3定义如下:

$$
\begin{aligned}
& SHA3-224(M) = Keccak[448](M || 01, 224) \\
& SHA3-256(M) = Keccak[512](M || 01, 256) \\
& SHA3-384(M) = Keccak[768](M || 01, 384) \\
& SHA3-512(M) = Keccak[1024](M || 01, 512) \\
& \quad
\end{aligned}
$$

$$
\begin{aligned}
& Keccak[c] = Sponge[Keccak_p[1600, 24], pad, 1600-c] \\
& \quad
\end{aligned}
$$

$$
\begin{aligned}
pad(x,m) = 1 || 0^j || 1, \quad j = (-m-2) \mod x,\quad x \in Z^{+}, m \in N \\
\quad
\end{aligned}
$$

$$
\begin{aligned}
Sponge[k[b, n_r], pad, r](N, d): \\
& P = N || pad(r, len(N)) \\
& n = len(P) / r \\
& c = b-r \\
& P_i = Trunc_{i*r\dots (i+1)*r}(P) \\
& S = 0^b \\
& for \ i \ in \ 0..n \\
& \quad S = k(S \oplus (P_i || 0^c)) \\
& end \\
& Z = ""\\
& loop \\
& \quad Z = Z || Trunc_{0\dots r}(S) \\
& \quad if \quad d \le len(Z) \\
& \quad \quad return\quad Trunc_{0\dots d}(Z)\\
& \quad else \\
& \quad \quad S = k(S) \\
& \quad end \\
& end \\
& \quad
\end{aligned}
$$

$$
\begin{aligned}
Keccak[b, n_r](S),\ assert(len(s)) = b: \\
& M_{S\rightarrow A}: A[x,y,z] = S[w*(5y+x)+z], x\in [0,5), y\in [0, 5), z\in[0, b) \\
& Rnd(A, i_r) = \iota(\chi(\pi(\rho(\theta(A)))), i_r)\\
& for\ i_r\ in (12+2l-n_r)..(12+2l) \\
& \quad A = Rnd(A, i_r) \\
& end \\
& return\quad M^{-1}_{S\rightarrow A} \\
& \quad
\end{aligned}
$$

$$
\begin{aligned}
\theta(A): \\
& C[x,z] = A[x,0,z]\oplus A[x,1,z]\oplus A[x,2,z]\oplus A[x,3,z]\oplus A[x,4,z] \\
& D[x,z] = C[(x-1)\mod 5, z] \oplus C[(x+1)\mod 5, (z-1)\mod w] \\
& return\quad A[x,y,z]\oplus D[x,z]\\
& \quad
\end{aligned}
$$

$$
\begin{aligned}
\rho(A): \\
& A'[0,0,z] = A[0,0,z], \forall z\in [0,w) \\
& (x,y) = (1,0) \\
& for\ t\ in\ [0, 24)\\
& \quad A'[x,y,z] = A[x,y,(z-(t+1)(t+2)/2)\mod w], \forall z\in [0,w) \\
& \quad (x,y) = (y,(2x+3y)\mod 5) \\
& end \\
& return\quad A'\\
&\quad
\end{aligned}
$$

$$
\begin{aligned}
\pi(A): \\
& A'[x,y,z] = A[(x+3y)\mod 5, x, z], \forall x\in[0,5), \forall y\in[0,5), \forall z\in [0,w) \\
& return\quad A' \\
&\quad
\end{aligned}
$$

$$
\begin{aligned}
\chi(A): \\
& A'[x,y,z] = A[x,y,z]\oplus ((A[(x+1)\mod 5, y, z] \oplus 1) \& A[(x+2)\mod 5, y, z]), \forall x\in[0,5), \forall y\in[0,5), \forall z\in [0,w) \\
& return\quad A' \\
& \quad
\end{aligned}
$$

$$
\begin{aligned}
\iota(A,i_r): \\
& A'[x,y,z] = A[x,y,z], \forall x\in[0,5), \forall y\in[0,5), \forall z\in [0,w) \\
& RC = 0^w \\
& for\ j\ in\ [0,l) \\
& \quad RC_{j\dots(j+1)} = rc(j+7i_r)\\
& end \\
& A'[0,0,z] = A'[0,0,z]\oplus RC_{z\dots(z+1)}, \forall z\in [0,w)\\
& return\quad A' \\
& \quad
\end{aligned}
$$

$$
\begin{aligned}
rc(t): \\
& tmp = t\mod 255 \\
& if\ tmp = 0 \\
& \quad return\quad 1 \\
& end \\
& R = 10000000 \\
& for\ i\ in\ 1..(tmp+1) \\
& \quad R = 0 || R \\
& \quad R_{0\dots 1} = R_{8\dots 9}\\
& \quad R_{4\dots 5} = R_{8\dots 9}\\
& \quad R_{5\dots 6} = R_{8\dots 9}\\
& \quad R_{6\dots 7} = R_{8\dots 9}\\
& \quad R = Trunc_{0\dots 8}(R)\\
& end \\
& return \quad Trunc_{0\dots 1} \\
& \quad
\end{aligned}
$$

|b|w|l|
|:-:|:-:|:-:|
|25|1|0|
|50|2|1|
|100|4|2|
|200|8|3|
|400|16|4|
|800|32|5|
|1600|64|6|

## [XOF](#toc)

记有消息$M$, 要求XOF输出的二进制串位长度为$d$, 则SHAKE定义如下:

$$
\begin{aligned}
& SHAKE128(M, d) = Keccak[256](M||1111, d) \\
& SHAKE256(M, d) = Keccak[512](M||1111, d) \\
\end{aligned}
$$

## [符号说明](#toc)

- $x||y$: $y$拼接在$x$之后;
- $0^j$: 表示$j$个二进制位`0b0`拼接在一起;
- $Trunc_{i\dots j}(X)$: 表示截取$X$的$[i, j)$之间的$j-i$位. 其中, $j\gt i \ge 0, j \le len(X)$;
- $X_{i..j}$: 表示$X$的第$i$位到第$j$位之间的$j-i$个二进制位;
- $X\oplus Y$: $X$按位异或$Y$;
- $M_{S\rightarrow A}$: 表示一个映射, 将集$S$映射到$A$. $M^{-1}_{S \rightarrow A}$表示其逆映射;

## [参考资料](#toc)

- FIPS 202(SHA-3 Standard: Permutation-Base Hash and Extendable-Output Functions);
- [SHA安全散列算法](https://www.cnblogs.com/mengsuenyan/p/12697811.html);
