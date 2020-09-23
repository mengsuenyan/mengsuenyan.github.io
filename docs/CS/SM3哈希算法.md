# SM3哈希算法

<span id='toc'></span>
[TOC]

## [简要说明](#toc)

||消息长度(bits)|块大小(bits)|单词长度(bits)|消息摘要长度(bits)|
|:----:|:-:|:-:|:-:|:-:|
|SM3|$\lt 2^{64}$|512|32|256|

## [算法流程](#toc)

### [位填充](#toc)

记有消息$M$(位长度为$l$), 首先在消息尾补一个比特位`0b1`, 然后补$k$个比特位`0b0`, $k$为满足$l+1+k\equiv 448 \mod 512$的最小非负整数. 最后, 将$l$转为64位长整数, 填充到消息最后;

### [计算过程](#toc)

将位填充后的消息$M$按位长度512划分为块$M^{(1)}, M^{(2)}, \dots, M^{(n)}, n = len(M)/512$, 将块$M^{(i)}$按位长度32划分为单词$M_0^{(i)}, M_1^{(i)}, \dots, M_16^{(i)}$;

$$
\begin{aligned}
& H_0^0,H_1^0,H_2^0,H_3^0,H_4^0,H_5^0,H_6^0,H_7^0=IV[0],IV[1],IV[2],IV[3],IV[4],IV[5],IV[6],IV[7] \\
& for\ i\ in\ 0..n \\
& \quad for\ j\ in\ 0..68 \\
& \quad \quad if\ j\lt 16 \\
& \quad \quad \quad W_j = M_j^{(i)}\\
& \quad \quad else \\
& \quad \quad \quad W_j = P_1(W_{j-16}\oplus W_{j-9}\oplus (W_{j-3} \lll 15))\oplus (W_{j-13} \lll 7)\oplus W_{j-6}\\
& \quad \quad end \\
& \quad end\\
& \quad \quad \\
& \quad a,b,c,d,e,f,g,h = H_0^i,H_1^i,H_2^i,H_3^i,H_4^i,H_5^i,H_6^i,H_7^i\\
& \quad for\ j\ in\ 0..64 \\
& \quad \quad W_j^{'} = W_j \oplus W_{j+4}\\
& \quad \quad s1 = ((a\lll 12)+e+T_j\lll j)\lll 7\\
& \quad \quad s2 = s1 \oplus (a\lll 12)\\
& \quad \quad t1 = FF_j(a,b,c)+d+s2+W_j^{'} \\
& \quad \quad t2 = GG_j(e,f,g)+h+s1+W_j \\
& \quad \quad d=c; c=b\lll 9; b=a; a=t1;h=g;g=f\lll19;f=e;e=P_0(t2)\\
& \quad end\\
& H = [H_0^i\oplus a,H_1^i\oplus b,H_2^i\oplus c,H_3^i\oplus d,H_4^i\oplus e,H_5^i\oplus f,H_6^i\oplus g,H_7^i\oplus h] \\
& end \\
\end{aligned}
$$

## [常量与函数定义](#toc)

说明:

- 算法中涉及的多字节表示方式皆是大端序;
- $X \lll b$: 表示$X$循环左移$b$位;

```Rust
/// 哈希初始值
const IV: [u32;8] = [0x7380166f, 0x4914b2b9, 0x172442d7, 0xda8a0600, 0xa96f30bc, 0x163138aa, 0xe38dee4d, 0xb0fb0e4e];
```

$$
T_j =
\begin{cases}
0x79cc4519 \quad if\quad 0 \le j \lt 16 \\
0x7a879d8a \quad if\quad 16 \le j \lt 64
\end{cases}
$$

$$
FF_j(X,Y,Z) =
\begin{cases}
X\oplus Y\oplus Z \quad if\quad 0 \le j \lt 16 \\
(X\land Y) \lor (X\land Z) \lor (Y\land Z) \quad if\quad 16 \le j \lt 64
\end{cases}
$$

$$
GG_j(X,Y,Z) =
\begin{cases}
X\oplus Y\oplus Z \quad if\quad 0 \le j \lt 16 \\
(X\land Y)\lor((\neg X)\land Z) \quad if\quad 16 \le j \lt 64
\end{cases}
$$

$$
P_0(X) = X\oplus (X\lll 9)\oplus (X\lll 17)
$$

$$
P_1(X)= X\oplus (X\lll 15)\oplus (X\lll 23)
$$

## [参考资料](#toc)

- SM3密码杂凑算法, 国家密码管理局, 2010/2;
