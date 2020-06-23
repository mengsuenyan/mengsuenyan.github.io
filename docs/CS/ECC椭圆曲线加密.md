# ECC椭圆曲线加密

注: 本博文是SEC1 V2中描述的椭圆加密标准(参考资料[1]);

<span id='toc'></span>
[TOC]

## [数学基础](#toc)

- [椭圆曲线加密数学基础](https://www.cnblogs.com/mengsuenyan/p/13156265.html);
- [数论相关](https://www.cnblogs.com/mengsuenyan/p/12969712.html);

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

简而言之是大端序;

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
    - 计算群元素$\alpha \equiv x^3+ax+b \mod p$, 计算$\beta=\sqrt{\alpha} \mod p$(不能计算出$\beta \in F_q$则转换失败);
    - 若$\beta\equiv y_p \mod 2$, 那么$y=\beta$;
    - 若$\beta\not\equiv y_p \mod 2$, 那么$y=p-\beta$;
  - 若$F_q=F_{2^m}$, 那么:
    - 若$x=0$, 那么$y=b^{2^{m-1}}\ in\ F_{2^m}$
    - 若$x\ne0$, 计算$\beta=x_p+a+bx^{-2}\ in\ F_{2^m}$, 在求$z^2+z=\beta$的解$z$, 将$z$表示为二值多项式$z=z_{m-1}x^{m-1}+\cdots+z_1x^1+z_0$(不能计算出$z$则转换失败);
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

## [加密组件](#toc)

### [椭圆曲线域参数](#toc)

#### [群$F_p$上的椭圆曲线域参数](#toc)

群$F_p$上的椭圆曲线域参数为$T=(p,a,b,G,n,h)$. 记有以二进制位数表示的近似加密安全级别$t, t\in \{80,112,128,192,256\}$, $a$和可选的八位组表示的随机数$S$作为输入, 则域参数计算如下:

- 当有输入$t$, 则质数$p$的选择满足映射$t\rightarrow \lceil log_2(p) \rceil, \{80\rightarrow 192, 112\rightarrow 224, 128\rightarrow 256, 192\rightarrow 384, 256\rightarrow 521\}$;
- $n$表示基点$G$的阶数;
- $h=\#E(F_p) / n$;
- 若未提供随机数$S$, 则从群$F_p$和$E(F_p)$中选择的曲线等式系数$b$, 基点$G$需满足如下条件:
  - $4a^3+27b^2\not\equiv 0 \mod p$;
  - $\#(E(F_p)) \ne p$;
  - $\forall B\in [1,100), p^B\not\equiv1 \mod n$;
  - $h\le 2^{t/8}$;
  - $n-1$和$n+1$的最大公因子$r$满足$log_2(r)\gt \frac{19}{20}$;
- 若提供了随机数$S$, 则按照下一节的规则生成曲线等式系数和基点;

#### [曲线等式系数和基点生成](#toc)

- 若提供了随机数八位组为$S$, 记$S$的位长度为$g$, 及有哈希函数$Hash$(哈希输出位长度为$l$), 及群的阶为$q$:
  - 记$m=\lceil log_2(p) \rceil, s=\lfloor (m-1)/l \rfloor, k=m-sl - (q\mod 2)$;
  - 将八位组$S$转为大整数$s_0$;
  - 从j=0迭代计算如下步骤s次:
    - $s_j = s_0 + j \mod 2^g$;
    - 将大整数$s_j$再转换为长度为$g/8$的八位组$S_j$;
    - $H_j = Hash(S_j)$;
    - 将$H_j$转换为大整数$e_j$;
  - $e=e_0 2^{ls} + e_1 2^{l(s-1)}+\dots + e_s \mod 2^{k+sl}$;
  - 若$q \mod 2 = 0$:
    - $e=0$, 则本次计算失败, 提供新的随机数, 进行下一次计算;
    - $e\ne 0$, 则$b=e$;
  - 若$q \mod 2 = 1$:
    - $a=0$ or $4e+27\equiv0 \mod q$ or $\sqrt{\frac{a^3}{r}} \mod q \not\in F_q$:
      - 本次计算失败, 提供新的随机数, 进行下一次计算;
      - $b=\sqrt{\frac{a^3}{r}} \mod q$

- 置$A=0x421736520706f696e74$("Base Point"的ASCII), $B=0x01$;
- 从$c=1$开始迭代循环, 每次迭代$c=c+1$:
  - 将整数$c$转换为长度为$1+\lfloor log_{256}(c) \rfloor$的八位组$C$;
  - 计算哈希值$H=Hash(A||B||C||S)$;
  - 将$H$转为大整数$e, k=e\mod 2q, u=k\mod q, z=\lfloor k/q \rfloor$;
  - 将$u$转为大整数$x$;
  - 按$(x,z)$点压缩的方式, 将z作为$Y$来解析$y$, 如果得到合法的$y$:
    - $G = h(x,y)$;
  - 如果得到的是不合法的$y$, 那么继续迭代;

注: 该标准中采用[SHA算法](https://www.cnblogs.com/mengsuenyan/p/12697811.html)作为Hash函数来散列数据;

#### [群$F_{2^m}$上的椭圆曲线域参数](#toc)

群$F_{2^m}$上的椭圆曲线域参数为$T=(m,f(x),a,b,G,n,h)$, 记有输入$t, t\in{80, 112, 128, 192, 256}$和可选的随机数$S$, 及系数$a$, 那么域参数计算规则如下:

- 从$\{112,128,192,256,512\}$中选择一个大于$t$的最小整数$t'$, 然后从$\{163,233,239,283,409,571\}$中选择一个满足$2t\lt m \lt 2t'$的整数作为$m$;
- 从下表中选择一个不可规约的二值多项式$f(x)$;
- $n$表示基点$G$的阶数;
- $h=\#E(F_p) / n$;
- 若未提供随机数$S$, 则从群$F_p$和$E(F_p)$中选择的曲线等式系数$b$, 基点$G$需满足如下条件:
  - $q=2^m$;
  - $b \mod q \not\equiv 0$;
  - $\#E(F_{2^m})\ne 2^m$;
  - $\forall B \in [1,100m), 2^B\not\equiv 1 \mod n$;
  - $h\le 2^{t/8}$;
  - $n-1$和$n+1$的最大公因子$r$满足$log_2(r)\gt \frac{19}{20}$;
- 若提供了随机数$S$, 则按照上一节的规则生成曲线等式系数和基点;

表1: $F_{2^m}$约化多项式表:
|群|约化多项式|
|:-:|:-:|
|$F_{2^{163}}$|$f(x)=x^{163}+x^{7}+x^6+x^3+1$|
|$F_{2^{233}}$|$f(x)=x^{233}+x^{74}+1$|
|$F_{2^{239}}$|$f(x)=x^{239}+x^{36}+1$ <br> or <br> $x^{239}+x^{158}+1$|
|$F_{2^{283}}$|$f(x)=x^{283}+x^{12}+x^{7}+x^{5}+1$|
|$F_{2^{409}}$|$f(x)=x^{409}+x^{87}+1$|
|$F_{2^{571}}$|$f(x)=x^{571}+x^{10}+x^{5}+x^{2}+1$|

#### [群$F_p$上的椭圆曲线域参数验证](#toc)

记有域参数$T=(p,a,b,G,n,h)$, 则该域参数需要满足以下条件:

- 质数$p$的选择满足映射$t\rightarrow \lceil log_2(p) \rceil, \{80\rightarrow 192, 112\rightarrow 224, 128\rightarrow 256, 192\rightarrow 384, 256\rightarrow 521\}$;
- $a,b,G=(x,y)$是区间$[0, p-1]$之间的整数;
- $4a^3 + 27b^2 \not\equiv 0 \mod p$;
- $y^3 = x^3 + ax^2 + b \mod p$;
- $n, n\ne p$是一个素数;
- $h\le 2^{t/8}, h=\lfloor (\sqrt{q}+1)^2/n \rfloor$;
- $nG=\mathcal{O}$;
- $\forall B \in [1,100), p^B \not\equiv 1 \mod n$;

#### [群$F_{2^m}$上的椭圆曲线域参数验证](#toc)

记有域参数$T=(m,f(x),a,b,G,n,h)$, 则该域参数需要满足如下条件:

- $2t \lt m \lt 2t'$;
- $f(x)$需要和表1中所列一致;
- $a,b,G=(x,y)$小于$2^m$;
- $b\not\equiv 0 \mod 2^m$;
- $y^2+xy=x^3+ax^2+b$;
- $n$是素数;
- $h \le 2^{t/8}, h=\lfloor (\sqrt{2^m} + 1)^2 / n \rfloor$;
- $nG=\mathcal{O}$;
- $\forall B \in [1, 100m), 2^B \not\equiv 1 \mod n, nh \ne 2^m$;

### [密钥生成](#toc)

记有域参数$T=(p,a,b,G,n,h)$或$T=(p,a,b,G,n,h)$;

- 随机选择一个整数$d, d\in [1,n-1]$;
- 得到(私钥, 公钥)=$(d, dG)=(d, Q)$;

#### [公钥验证](#toc)

记有域参数$T=(p,a,b,G,n,h)$或$T=(p,a,b,G,n,h)$, 及公钥$Q=(x,y)$;

1. $Q\ne \mathcal{O}$;
2. 若T是$F_p$上的域参数, 则$x,y$需满足$x,y\in [0,p-1]$, 且$y^2=x^3+ax^2+b \mod p$;
3. 若T是$F_{2^m}$上的域参数, 则$x,y$需满足$x,y\in [0,2^m-1]$, 且$y^2+xy=x^3+ax^2+b \mod 2^m$;
4. $nQ=\mathcal{O}$;

完全验证: 需要验证条件1/2/3/4;
部分验证: 只需验证条件1/2/3;

### [Diffie-Hellman原根](#toc)

记有域参数$T$, 实体$U$拥有私钥$d_U$, 实体$V$拥有公钥$Q_V=(x,y)$, $U$和$V$的密钥是由同一域参数得到的;

椭圆曲线Diffie-Hellman原根

- $P=(x_P, y_P)=d_U Q_V$;
- 若$P=\mathcal{O}$, 则无共享加密元素;
- 若$P\ne\mathcal{O}$, 则存在共享加密元素$z=x_P$;

椭圆曲线余因子Diffie-Hellman原根

- $P=(x_P, y_P)= h d_U Q_V$;
- 若$P=\mathcal{O}$, 则无共享加密元素;
- 若$P\ne\mathcal{O}$, 则存在共享加密元素$z=x_P$;

### [MQV原根](#toc)

记有域参数$T$(所属群的阶记为$q$), 实体$U$拥有密钥对$(d_{1,U}, Q_{1,U}=(x_{1,U}, y_{1,U}))$和$(d_{2,U}, Q_{2,U}=(x_{2,U}, y_{2,U}))$, 实体$V$拥有公钥$Q_{1,V}=(x_{1,V}, y_{1,V})$和$Q_{2,V}=(x_{2,V}, y_{2,V})$, $U$和$V$的密钥是由同一域参数得到的;

- $z=2^{\lceil log_2(n)/2 \rceil}$;
- $s=d_{2,U} + d_{1,U}\cdot((x_{2,U} \mod z)+z) \mod n$;
- $s'=z + (x_{2,V} \mod z)$;
- $P=(x_P, y_P)=hs(Q_{2,V} + s'Q_{1,V})$;
- 若$P=\mathcal{O}$, 则无共享加密元素;
- 若$P\ne\mathcal{O}$, 则存在共享加密元素$z=x_P$;

## [签名方案](#toc)

### [ECDSA椭圆曲线数字曲线签名算法](#toc)

记有明文数据$M$, 哈希函数$Hash$, 及期望的安全级别$t$, :

- 实体$U$从$\{E(F_p), E(F_{2^m})\}$中选定一个群, 由指定的安全级别$t$, 计算椭圆曲线域参数$T$;
- 由域参数$T$生成密钥对$(d_U, Q_U)$, 并将公钥$Q_U$发送给$V$;
- 由$U$对明文进行签名发送给$V$:
  - 由域参数$T$再选择一组密钥对$(k, (x, y))$;
  - $r=x\mod n$;
  - $H=Hash(M)$, 记$H$的位长度为$l$;
  - $l\le \lceil log_2(n) \rceil \Rightarrow E=H;\quad l\gt \lceil log_2(n) \rceil \Rightarrow E=truncate(H)$, 其中truncate截断$H$最左边的$\lceil log_2(n) \rceil$位;
  - $E$转为大整数$e$;
  - $s=k^{-1}(e+rd_U) \mod n$;
  - 若$s=0$, 再重新选择一组密钥重新迭代;
  - 得到$M$的签名$(r,s)$;
- $V$收到明文$M$及签名$(r,s)$, 对签名进行认证:
  - 验证$r,s \in [1,n-1]$;
  - $H=Hash(M)$:
  - $l\le \lceil log_2(n) \rceil \Rightarrow E=H;\quad l\gt \lceil log_2(n) \rceil \Rightarrow E=truncate(H)$, 其中truncate阶段$H$最左边的$\lceil log_2(n) \rceil$位;
  - $E$转为大整数$e$;
  - $u_1 = es^{-1} \mod n, u_2=rs^{-1} \mod n$;
  - $R=(x,y)=u_1 G + u_2 Q_U$;
  - 验证$R\ne\mathcal{O}$;
  - $v=x \mod n$;
  - 验证$v=r$, 则签名通过验证. 否则, 签名不正确;

## [加密和密钥传输方案](#toc)

### [ECIES椭圆曲线集成加密算法](#toc)

记有明文数据$M$, [密钥派生函数](https://www.cnblogs.com/mengsuenyan/p/13160157.html)$KDF$, [消息认证码函数](https://www.cnblogs.com/mengsuenyan/p/12699175.html)$MAC$, [对称加密函数](https://www.cnblogs.com/mengsuenyan/p/12697694.html)$ENC$, 域参数$T$, 记有实体$U$和$V$, $U$和$V$之间的共享数据$SharedInfo1$和$SharedInfo2$(可选);

- 密钥部署:
  - 实体$V$生成密钥对$d_V, Q_V$, 将公钥$Q_V$发送给$U$;
  - $U$对公钥$Q_V$合法性进行验证;
- 加密:
  - 由$T$生成密钥对$(k, R=(x,y))$;
  - 根据$R$是否使用点压缩方式, 将$R$转换为8位组$\bar{R}$;
  - 根据是否使用$Diffie-Hellman$公钥加密元素, 由$k, Q_V$生成生成加密共享元素$z$;
  - 将$z$转换位8位组$Z$;
  - $K=KDF(Z, [SharedInfo1])$, 输出八位组长度位$enckeylen+mackeylen$;
  - 取$K$的最左边的$enckeylen$个八位组作为$EK$, 最右边的$mackeylen$个八位组作为$MK$;
  - $EK$作为密钥, 加密明文得密文$EM=ENC(EK, M)$;
  - 计算消息认证码$D=MAC(EM, MK, [SharedInfo2])$;
  - 输出$C=\bar{R} || EM || D$;
- 解密:
  - $V$接收到加密数据$C$;
  - 根据$C$的头字节是$0x02/0x03/0x04$, 提取公钥$R=(x,y)$, $EM$, $D$;
  - 根据是否使用$Diffie-Hellman$, 由$(d_V, R)$;
  - 然后按照和如上加密过程相同的方式, 生成$EK$, $EM$, $D$;
  - 验证生成的$D$和接收到的$D$是否相同;
  - 如果MAC认证相同, 那么解密$M=ENC(EM, EK)$;

## [密钥协商方案](#toc)

### [椭圆曲线Diffie-Hellman方案](#toc)

记有域参数$T$, 实体$U$和$V$;

- 密钥部署:
  - $U$和$V$分别计算密钥对$(d_U, Q_U)$, $(d_V, Q_V)$;
  - $U$和$V$交换公钥, 并各自验证收到的公钥是否合法;
- 密钥协商:
  - 实体$U$由$d_U, Q_V$计算Diffie-Hellman原根$z$;
  - 将$z$转换位八位组$Z$, 由密钥派生函数得到密钥数据$K=KDF(Z, [SharedInfo])$;
  - 输出$K$

### [椭圆曲线MQV方案](#toc)

将椭圆曲线Diffie-Hellman方案过程基本一致, 只需将其中的$Diffie-Hellman$原根替换$MQV原根$;

## [参考资料](#toc)

[1]. Standars for Efficient Cryptography 1 (SEC1: Elliptic Curve Cryptography), Daniel R.L.Brown;
