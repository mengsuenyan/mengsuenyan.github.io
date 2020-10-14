# ECDSA椭圆曲线数字签名算法

<span id='toc'></span>
[TOC]

## [符号说明](#toc)

[椭圆加密数学基础](#toc)

- $F_p$: $y^2 = x^3 + ax + b, (4a^3+27b^2)\mod p \ne 0, (x,y)\in F_p$;
- $F_{2^m}$: $y^2 + xy = x^3 + ax^2+b, b \ne 0, (x,y) \in F_{2^m}$;
- $G$: 椭圆曲线域参数的基点或生成子;
- $(x_P, y_P)$: 椭圆曲线点$P$的坐标表示;
- $(r,s)$: 数字签名, 整数对;
- $Q$: 公钥;
- $d$: 私钥, $Q = d\cdot G$;
- $\mathcal{O}$: 无限远点, 充当椭圆曲线群的零元素;
- $n$: 素数, 生成子$G$的阶;
- $E(F_q)$: 定义在$F_q$域上的椭圆曲线;
- $(a, b)$: 椭圆曲线的系数;
- $q$: 有限域的大小;
- $truncate_l(X)$: 取位字符串$X$的最左边$l$位/字节;
- 域参数:
  - $q$;
  - $a$;
  - $b$;
  - $x_G$;
  - $y_G$;
  - $n$;
  - $SEED$: (可选), 用于生成可验证的随机域参数的位字符串;
  - $h$: (可选), 余因子$h=|E|/n$;

## [数据转换](#toc)

### [整数和八位串之间的转换](#toc)

记有自然数$x$, 与其对应的八位串记为$M$. 其中, $len(M) = k, 2^{8\cdot k} \gt x$, 那么整数和八位串之间的转换可使用如下公式:

- $x = \sum_{i=1}^{k}2^{8\cdot (k-i)} \cdot m_i$;
- $M = m_1 || m_2 || \dots || m_k$;

### [域元素转为八位串](#toc)

记有域元素$\alpha, \alpha \in F_q$, 将其转换为八位串$M$:

- $t = \lceil \log_2(q) \rceil, l = \lceil t/8 \rceil$;
- $q \mod 2 = 1$:
  - $\alpha \in [0,q-1]$的整数, 按照整数将其转为八位串;
- $q \mod 2 = 0, q = 2^m$:
  - $\alpha = s_1 || s_2 || \dots || s_m$;
  - $S = 0||\dots||0, bitslen(S) = 8\cdot l - m$;
  - $M = S || s_1 || s_2 || \dots || s_m$;

### [八位串转为域元素](#toc)

记有域$F_q$, 八位串$M, len(M) = l, l = \lceil t/8 \rceil, t = \lceil \log_2(q) \rceil$, 将其转为域元素$\alpha$:

- $q \mod 2 = 1$:
  - 将$M$转为整数$x$, 若$x \in [0,q-1]$, 则$\alpha = x$;
- $q \mod 2 = 0, q = 2^m$:
  - $M = S || m_1 || m_2 || \dots || m_m, bitslen(S) = 8\cdot l - m$;
  - $\alpha = m_1 || m_2 ||\dots ||m_m$;

### [域元素转为整数](#toc)

记有域元素$\alpha \in F_q$, 将其转为整数$x$:

- $q \mod 2 = 1$:
  - $x = \alpha$;
- $q \mod 2 = 0, q = 2^m$:
  - $\alpha = s_1 || s_2 || \dots || s_m$;
  - $x = \sum_{i=1}^{m} 2^{m-i} s_i$;

### [曲线点转为八位串](#toc)

无穷远点$\mathcal{O}$转为$M = 0x00$;

记有椭圆曲线$E(F_q)$上的非无穷远点$P=(x_P, y_P)$, 将其转为八位串$M$:

- 将域元素$x_P$转为八位串$M_x$;
- 若以压缩形式表示点, 则:
  - 计算压缩形式$(x_P, z_P)$;
  - $z_P = 0$:
    - $M = 0x02 || M_x$;
  - $z_P = 1$:
    - $M = 0x03 || M_x$;
- 若以非压缩形式表示点, 则:
  - 将域元素$y_P$转为八位串$M_y$;
  - $M = 0x04 || M_x  || M_y$;
- 若以混合形式表示点, 则:
  - 将域元素$y_P$转为八位串$M_y$;
  - 计算$z_P$;
  - $z_P = 0$:
    - $M= 0x06 || M_x || M_y$;
  - $z_P = 1$:
    - $M= 0x07 || M_x || M_y$;

### [八位串转为曲线点](#toc)

记有域$F_q$, 和合法的八位串$M$, 将其转为点$P=(x_P, y_P);:

- $l = \lceil \log_2(q) / 8 \rceil$;
- $len(M) = 1 \land M = 0x00$:
  - $P = \mathcal{O}$;
- $len(M) = l + 1$:
  - $M = S || M_x, len(S) = 1$;
  - 验证$S = 0x02 \lor S = 0x03$;
  - $S = 0x02$:
    - $z_P = 0$;
  - $S = 0x03$;
    - $z_P = 1$;
  - 将八位串$M_x$转为域元素$x_P$;
  - 压缩形式的点$(x_P, z_P)$转为点$(x_P, y_P)$;
- $len(M) = 2\cdot l + 1$:
  - $M = S || M_x || M_y, len(S) = 1, len(M_x) = l$;
  - 验证$S = 0x04 \lor S = 0x06 \lor S = 0x07$;
  - 将八位串$M_x$转为域元素$x_P$;
  - 将八位串$M_y$转为域元素$x_P$;
  - $S = 0x06 \lor S = 0x07$:
    - $S = 0x06$
      - $z_P = 0$
    - $S = 0x07$
      - $z_P = 1$
    - 由$(x_P, y_P)$计算$z_{P}^{'}$, 验证$z_P = z_{P}^{'}$;
    - 由$(x_P, z_P)$计算$(x_P, y_{P}^{'})$, 验证$y_P = y_{P}^{'}$;

## [签名](#toc)

- 记有位字符串消息$M$;
- 由域参数生成临时密钥对$(k, R)$;
- 将$x_R$转为整数$j$;
- $r = j \mod n, r \ne 0$;
- $H = Hash(M)$;
- 将$H$转为整数$e$:
  - $E = truncate_l(H), l = \min(log_2(n), bitslen(H))$;
  - 将位字符串转为整数$e$;
- $s = k^{-1}\cdot (e+d\cdot r) \mod n,\quad s \ne 0$;
- 输出$(r, s), r\in [1,n-1], s\in [1,n-1]$;

## [验证](#toc)

### [通过公钥验证](#toc)

- 记收到消息$M'$, 签名$(r', s')$;
- 验证$(r' \in [1,n-1]) \land  (s' \in [1,n-1])$;
- $H' = Hash(M')$;
- 将$H'$转为整数$e$:
  - $E = truncate_l(H'), l = \min(log_2(n), bitslen(H))$;
  - 将位字符串$E$转为整数$e$;
- $u_1 = e' \cdot (s')^{-1} \mod n, u_2 = r' (s')^{-1}\mod n$;
- 计算椭圆曲线点$R=(x_R, y_R) = u_1\cdot G + u_2\cdot Q$;
- 验证$R \ne \mathcal{O}$;
- 将$x_R$转为整数$j$;
- $v = j\mod n$;
- 验证$v = r'$;

### [通过私钥验证](#toc)

- 记收到消息$M'$, 签名$(r', s')$;
- 验证$(r' \in [1,n-1]) \land  (s' \in [1,n-1])$;
- $H' = Hash(M')$;
- 将$H'$转为整数$e$:
  - $E = truncate_l(H'), l = \min(log_2(n), bitslen(H))$;
  - 将位字符串$E$转为整数$e$;
- $u_1 = e' \cdot (s')^{-1} \mod n, u_2 = r' (s')^{-1}\mod n$;
- $k' = (u_1 + u_2\cdot d) \mod n$;
- $R = k'\cdot G$;
- 验证$R \ne \mathcal{O}$;
- $v = j\mod n$;
- 验证$v = r'$;

## [椭圆曲线域参数](#toc)

### [点压缩](#toc)

记由椭圆曲线上的一点$P=(x_P, y_P)$, 则点可以压缩为$x_P$和$y_P$的某些位$z_P$;

- $rightmost_l(y)$表示$y$的最右边的$l$位;
- $leftmost_l(y)$表示$y$的最左边的$l$位;

#### [域$F_p$上点压缩](#toc)

$P=(x_P,y_P), y^2 = x^3 + a\cdot x+b,\quad x,y\in F_p,\ z_P = rightmost_1(y_P)$;

- 已知$(x_P, z_P)$求$y_P$;
  - $\alpha = x_P^3 + a\cdot x_P + b \mod p$;
  - $\beta = \sqrt{\alpha} \mod p$;
  - $y_P = \beta\quad if\ rightmost_1(\beta)=y_P\quad else\ y_P = p-\beta$;

#### [域$F_{2^m}$上点压缩](#toc)

$P=(x_P,y_P), y^2 + x\cdot y = x^3 + a\cdot x^2 + b,\quad x,y\in F_{2^m}$. 若$x_P=0$, 则$z_P=0$. 否则, $z_P = rightmost_1(y_P\cdot x_{P}^{-1})$;

- 已知$(x_P, z_P)$求$y_P$;
  - 若$x_P=0$, $y_P = b^{2^{m-1}}$;
  - 若$x_P\ne 0 $:
    - $\alpha = x_P + a + b\cdot x_P^{-2}$;
    - $\beta^2 + \beta = \alpha$;
    - $z_{P}^{'} = rightmost_1(\beta)$;
    - $z_{P}^{'} \ne z_P$;
      - $\beta = \beta + g$, 其中$g$是[乘法单位元](https://www.cnblogs.com/mengsuenyan/p/13156265.html);
    - $y_P = x_P\cdot \beta$;

### [保证椭圆曲线安全性的一些必要条件](#toc)

#### [MOV条件](#toc)

Menezes-Okamoto-Vanstone(MOV): $F_q \rightarrow F_{q^B}, B\ge 1$, ANS X9.62中选择$B$大于等于100;

- 给定MOV阈值$B$, 素数$q$, 素数$n, n=|E(F_q)|$, 验证MOV条件是否合法:
  - $t = 1$;
  - `for i in 1..=B`:
    - $t = t\cdot q \mod n$;
    - `return false`, if $t = 1$;
  - `return true`;

#### [异常条件(The Anomalous condition)](#toc)

若$|E(F_q)| = q$, 则称定义在$F_q$上的椭圆曲线$E(F_q)$是$F_q-anomalous$, 该种情况下椭圆曲线的离散对数问题很容易被解出.

- 给定$E(F_q)$, 及椭圆曲线的阶$u=|E(F_q)|$, 验证是否满足Anomalous条件:
  - `return u != q`;

### [椭圆曲线的选择](#toc)

#### [可验证随机椭圆曲线](#toc)

给定随机种子$SEED$, $t=bitslen(HashVal)$, $|F_q|=q$, 求椭圆曲线的系数$(a,b)$;

- $m = \lceil \log_2(q) \rceil$;
- $s = \lfloor (m-1)/t \rfloor$;
- $k = m - st - (q \mod 2)$;
- $H = Hash(SEED)$;
- $H$转为整数$e$;
- $c_0 = e \mod 2^k$;
- `for j in 1..=s`:
  - $c_j = Hash((SEED + j)\mod 2^g)$
- $c = c_0\cdot 2^{ts} + c_1\cdot 2^{t\cdot (s-1)}+\dots + c_s$;
- 将整数$c$转为域元素$r$;
- 从$F_q$中随机选择一个元素$a$;
- $q \mod 2 = 0$:
  - $b = r$;
  - `return error`, if $b = 0$;
- $q \mod 2  = 1$:
  - $b^2\cdot r = a^3$
  - `return error`, if $4\cdot a^3 + 27\cdot b^2 = 0$;
- `return (a,b)`;

#### [椭圆曲线的验证](#toc)

- 给定椭圆曲线$E(F_q, a, b)$, 可选的种子$SEED$, 验证该椭圆曲线是否合法:
  - $q$是奇数, 若:
    - $q$不是素数:
      - `return false`;
    - $a \notin [0,q-1], b \notin [0,q-1]$:
      - `return false`;
    - $4\cdot a^3 + 27\cdot b^2  = 0$:
      - `return false`;
  - $q$是偶数, 若:
    - $q$不满足$q = 2^m$, $m$是素数;
      - `return false`;
    - $bitslen(a) \ne m, bitslen(b) \ne m$:
      - `return false`;
  - 若$SEED$提供, 验证更具上一节的椭圆曲线生成算法生成$(a', b')$:
    - `return a=a' && b=b'`;
  - `return true`;

### [基点的选择](#toc)

#### [可验证随机基点](#toc)

给定随机种子$SEED$, 整数计数器$base$, $hashlen = bitslen(HashVal)$, 域大小$q$, 余因子$h$, 求基点$x_G, y_G$;

- $element = 1$;
- `loop`:
  - 将计数器$base$的值和$element$转为位字符串$Base, Element$;
  - $H = Hash("Base point" || Base || Element || SEED)$;
  - $H$转为整数$e$;
  - $element = element + 1$;
  - `break`, if $\lfloor e/2\cdot q \rfloor \ne \lfloor 2^{hashlen} / (2\cdot q) \rfloor$;
- $t = e \mod (2\cdot q)$;
- $x = t\mod q, z = \lfloor t/q \rfloor$;
- $x$转为域元素$x_G$;
- 由$(x_G, z)$计算出$y_G$;
- 输出$(x_G, y_G)$;

#### [基点的验证](#toc)

给定域参数, 验证基点$G$是否合法;

- $G = \mathcal{O}$:
  - `return false`;
- $q$奇数, 若:
  - $x_G \notin [0,q-1], y_G \notin [0,q-1]$:
    - `return false`;
  - $y_{G}^2 \ne x_{G}^3 + a\cdot x_G + b$:
    - `return false`;
- $q=2^m$偶数, 若:
  - $bitslen(x_G) \ne m, bitslen(y_G) \ne m$:
    - `return false`;
  - $y_{G}^2 + x_G\cdot y_G \ne x_{G}^3 + a\cdot x_{G}^2 + b$:
    - `return false`;
- $n\cdot G \ne \mathcal{O}$:
  - `return false`;
- 若提供了随机种子$SEED$:
  - $base = 1$:
  - `loop`:
    - `return false`, if $base \gt 10\cdot h^2$;
    - 通过$SEED$和$base$生成基点$R=(x,y)$;
    - $G' = h\cdot R$;
    - $base = base + 1$;
    - `break`, if $n\cdot G' = \mathcal{O}$;
  - `return G' = G`;
- `return true`;

### [椭圆曲线域参数的选择](#toc)

生成随机种子$SEED$, 生成基点/曲线系数;

#### [EC域参数的验证](#toc)

给定安全级别$s$;

- $n \lt \max(2^{2\cdot s - 1}, 2^{160})$:
  - `return false`;
- $n$不是素数:
  - `return false`;
- 椭圆曲线$E(F_q, a, b)$不合法:
  - `return false`;
- $h' = \lfloor (q^{1/2} + 1)^2 / n$;
- 如果域参数提供了$h$, 若$h \ne h'$:
  - `return false`;
- $h' \gt 2^{s/8}$:
  - `return false`;
- MOV条件不合法:
  - `return false`;
- Anomalous条件不合法:
  - `return false`;
- 基点$G$不合法:
  - `return false`;
- `return true`;

#### [EC域参数的生成](#toc)

给定安全级别$s$, 和可选的一些限制: 最大的余因子值$h_max$, 准素性验证中的素除数界$I_max$, MOV条件的阈值$B$;

- 生成$SEED$;
- 选择一个符合安全级别的域大小$q$;
- 生成$E(F_q, a, b)$;
- 计算椭圆曲线的大小$u=|E|$;
- 生成$n, h$;
- 生成基点$G$;
- 验证域参数的合法性;
- 输出域参数;

## [椭圆曲线密钥对](#toc)

$(d, Q), d\in [1,n-1], Q = d\cdot G$;

### [椭圆曲线公钥验证](#toc)

给定公钥$Q$和已经验证正确的域参数, 验证$Q$的合法性:

- $Q = \mathcal{O}$:
  - `return false`;
- $q \mod 2 = 1$:
  - $x_Q \not in [0,q-1], y_Q \notin [0,q-1]$:
    - `return false`;
  - $y_Q^2 \ne x_Q^3 + a\cdot x_Q + b$:
    - `return false`;
- $q \mod 2 = 0, q = 2^m$:
  - $bitslen(x_Q) \ne m, bitslen(y_Q) \ne m$:
    - `return false`;
- $y_Q^2 + x_Q \cdot y_Q \ne x_Q^3 + a\cdot x_Q^2 + b$:
  - `return false`
- $n\cdot Q \ne \mathcal{O}$:
  - `return false`;
- $n\cdot Q = \mathcal{O}$:
  - `return true`;

### [椭圆曲线密钥对的生成](#toc)

给定已经验证正确的域参数, 密钥对$(d, Q)$生成如下:

- 随机选择一个整数作为私钥$d\in [1,n-1]$;
- 计算公钥$Q = d\cdot G$;

## [素性](#toc)

### [概率素性测试-ProbabilisticPrimalityTest](#toc)

[Miller-Rabin测试](https://www.cnblogs.com/mengsuenyan/p/12969712.html);

由于早期博客符号不统一, 这里重新描述下:

- 记由一个奇数$n$, 和正整数$T$, 现需判断$n$是合数, 还是可能是一个素数(注意这里是可能, Miller-Rabin测试出错的概率和测试次数有关, 至多为$2^{-T}$);
  - 计算非负整数$v$和奇正数$w$, 满足$n-1 = 2^v \cdot w$;
  - rust: `for j in 1..=T`:
    - 随机选择一个整数$a, a\in [2, n-1]$;
    - $b = a^w \mod n$;
    - `continue`, if $b = 1$ or $b = n-1$;
    - $cnt = 0$;
    - `for i in 1..=(v-1)`:
      - $b = b^2 \mod n$;
      - `break`, if $b = n-1$;
      - `return 合数` if $b = 1$;
      - $cnt = cnt + 1$;
    - `return 合数`, if $cnt = v-1$;
  - `return 可能是素数`;

### [准素性(near primality)测试](#toc)

- 概念说明:
  - 记有正整数$I_{max}$, 若正整数$h$的每个素除数都不超过$I_{max}$, 那么称$h$是$I_{max}-smooth$;
  - 记有两个素数$p_1, p_2$, 有$p=p_1\cdot p_2$, 那么称$p$是准素数;
  - 记有正整数$r_{min}$, $I_{max}-smooth$的正整数$h$, 及可能是素数的正整数$n, n\ge r_{min}$. 若正整数$u$满足$u=h\cdot n$, 那么$u$是一个准素数;

- 准素性测试:
  - 记有正整数$r_{min}, I_{max}, u$, 判断$u$是否是一个准素数:
    - $n = u, h = 1$;
    - `for i in 2..=I_max`:
      - while $n / i \gt 0$:
        - $n = n / i,\quad h = h\cdot i$;
        - `return 非准素数`, if $n \lt r_{min}$;
    - `return (准素数, h, n)`, if $n$满足概率素性测试;
    - `return 非准素数`;

## [参考资料](#toc)

- ANS X9.62-2005;
