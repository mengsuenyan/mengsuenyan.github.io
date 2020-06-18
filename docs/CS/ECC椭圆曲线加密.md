# ECC椭圆曲线加密

注: 本博文是SEC1 V2中描述的椭圆加密标准(参考资料[1]);

<span id='toc'></span>
[TOC]

## [数据格式转换](#toc)

### [二进制组和八位组之间的转换](#toc)

记有一串二进制位表示的数据$B=B_0 B_1\dots B_{l-1}$, 那么按如下规则转为八位组$\{M_i\}$:

- $r=l\mod 8, m=\lceil l/8 \rceil$, 在$M_0$的最左边填充$r$个0位, 然后按照从左往右的顺序依次将$B_0 B_1\dots B_{l-1}$填充到$M_0 M_1 \dots M_m$;

八位组$\{M_i\}$转为$\{B_j\}$: 将八位组的二进制位从左往右一次填充到$B_j$, 转换后的二进制组的位长度位$8*m$;

### [自然数和八位组之间的转换](#toc)

记有一自然数$x$, 满足$2^{8(m-1)} \le x \lt 2^{8m}$, 那么转换规则如下:

- 将x转为二值多项式表示$x=x_{m-1}2^{8(m-1)}+x_{m-2}2^{8(m-2)}+\dots +x_{1}2^8+x_0$;
- $M_i=x_{m-1-i}, 0 \le i \le m-1$;
- $x=\sum_{i=0}^{m-1}2^{8(m-1-i)}M_i$

其实就是大端序;

### [椭圆曲线点转换为八位组](#toc)

记$P$是$E(F_q)$上的一点, $M$表示八位组(其字节长度记为$m$), 那么转换规则如下:

- 若$P=\mathcal{O}$, 那么$M=0x00$, $m=1$;
- 若$P=(x,y)\ne\mathcal{O}$采用点压缩的方式表示, 那么:
  - 将自然数$x$转为八位组$X$
  - 若$F_q=F_p$, 那么:
    - $y_p = y \mod 2$;
  - 若$F_q=F_{2^m}$, 那么:
    - 若$x=0$, 那么$y_p=0$. 否则, 计算$z=z_{m-1}x^{m-1}+\cdots+z_1 x + z_0$, 其中$z=yx^{-1}$, 则$y_p=z_0$;
  - 若$y_p=0$, 则$Y=0x02$. 若$y_p=1$, 则$Y=0x03$;
  - 将$X$和$Y$拼接为$M=Y||X$, $m=\lceil (\log_2^q)/8 \rceil + 1$;
- 若$P=(x,y)\ne\mathcal{O}$不采用点压缩的方式表示, 那么:
  - 将自然数$x$转为八位组$X$;
  - 将自然数$y$转为八位组$Y$;
  - 将$X$和$Y$拼接为$M=0x04||X||Y$, $m=2\lceil (log_2^q)/8 \rceil + 1$;

### [八位组转换为椭圆曲线点](#toc)

记$P$是$E(F_q)$上的一点, $M$表示八位组(其字节长度记为$m$), 那么转换规则如下:

- 若$M=0x00$, 则$P=\mathcal{O}$;
- 若$m=\lceil (log_2^q)/8 \rceil + 1$, 那么:
  - 那么将$M$表示为$M=Y||X$, $Y$是最左边的一个字节, $X$是后续字节;
  - 将$X$转换为自然数$x$;
  - 若$Y=0x02$, 置$y_p=0$, $Y=0x03$, 置$y_p=1$;
  - 若$F_q=F_p$, 那么:
    - 计算群元素$\alpha \equiv x^3+ax+b \mod p$, 计算$\beta=\sqrt{\alpha} \mod p$;
    - 若$\beta\equiv y_p \mod 2$, 那么$y=\beta$;
    - 若$\beta\not\equiv y_p \mod 2$, 那么$y=p-\beta$;
  - 若$F_q=F_{2^m}$, 那么:
    - 若$x=0$, 那么$y=b^{2^{m-1}}\ in\ F_{2^m}$
    - 若$x\ne0$, 计算$\beta=x_p+a+bx^{-2}\ in\ F_{2^m}$, 在求$z^2+z=\beta$的解$z$, 将$z$表示为二值多项式$z=z_{m-1}x^{m-1}+\cdots+z_1x^1+z_0$;
    - 若$z_0=y_p$, 那么$y=xz\ in\ F_{2^m}$;
    - 若$z_0\ne y_p$, 那么$y=x(z+1)\ in\ F_{2^m}$;
  - $P=(x,y)$;
- 若$m=2\lceil (log_2^q)/8 \rceil + 1$, 那么:
  - 那么将$M$表示为$M=W||X||Y$, $W$是最左边的一个字节, $X$是后续$\lceil log_2^q \rceil$字节, $Y$是后续的$\lceil log_2^q \rceil$字节;
  - 检查$W=0x04$;
  - 将$X$转换为自然数$x$;
  - 将$Y$转换为自然数$y$
  - 检查$(x,y)$是否满足定义的曲线公式;
  - $P=(x,y)$;

## [签名策略](#toc)

## [加密和密钥传输策略](#toc)

## [密钥协商策略](#toc)

## [参考资料](#toc)

[1]. Standars for Efficient Cryptography 1 (SEC1: Elliptic Curve Cryptography), Daniel R.L.Brown;
