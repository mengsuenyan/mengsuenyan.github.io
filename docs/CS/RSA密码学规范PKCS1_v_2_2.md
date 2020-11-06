# RSA密码学规范PKCS#1 v2.2

<span id='toc'></span>
[TOC]

## [符号说明](#toc)

- $n$: RSA模数$n$;
- $r_i$: 模数$n$的素因子(需是奇素数), $n=r_1\cdot r_2\cdot \dots\cdot r_u, u \ge 2$;
- $p,q$: $n$的素因子, 满足$n=p\cdot q$. 其中$r_1=p, r_2 = q$;
- $C$: 密文的八位串字符串表示;
- $c$: 密文的整数表示, $0\le c \le (n-1)$;
- $m$: 消息的整数表示, $0\le m \le (n-1)$;
- $M$: 消息的八位串(每8位一组)字符串表示;
- $s$: 签名的整数表示, $0\le s \le (n-1)$;
- $S$: 签名的八位串字符串表示;
- $d$: 私钥指数,  $e\cdot d \equiv 1\mod \lambda(n)$;
- $e$: 公钥指数, $3 \le e \le (n-1), GCD(e, \lambda(n))=1$;
- $EM$: 经过一定编码规则的消息串, 八进制八位串字符串;
- $d_i$: 素因子$r_i$的CRT指数, $e\cdot d_i\equiv 1 \mod (r_i-1), i=3,\dots, u$;
- $dP$: $p$的CRT指数, $e\cdot dP \equiv 1\mod (p-1)$;
- $dQ$: $q$的CRT指数, $e\cdot dQ \equiv 1\mod (q-1)$;
- $qInv$: CRT系数, $q\cdot qInv\equiv 1\mod p,\ 0\lt qInv \lt p$;
- $t_i$: CRT系数, $R_i\cdot t_i\equiv 1\mod r_i, R_i=r_1\cdot r_2\cdot\dots\cdot r_{i-1}, i = 3,\dots,u$;
- $\lambda(n)=LCM(r_1-1,r_2-1,\dots,r_u-1)$;
- $a||b$: 表示将字符串$b$拼接在$a$后;
- $len(X)$表示计算八位串的长度, 即字节长度;
- $truncate_l(X)$表示取$X$的最左边(最高有效位)的$l$个字节. 如果不足$l$个字节则在最高位填充0补齐到$l$个字节;

### [公钥私钥的表示](#toc)

- 公钥:
  - $(n,e)$;

- 私钥:
  - 第一种私钥表示:
    - $(n,d)$;
  - 第二种私钥表示:
    - $(p,q,dP,dQ,qInv), (r_i, d_i, t_i)$;

## [数据转换](#toc)

- I2OSP: 整数转为八位串字符串;
- OS2IP: 八位串字符串转为整数;

### [I2OSP](#toc)

记有大整数$x=\sum_{i=0}^{N-1}b_i\cdot 2^{8\cdot i}, N=len(x)$, 则对应的八位串字符串为$X=b_{N-1}||\dots||b_1||b_0$;

### [OSP2IP](#toc)

记有八位串字符串为$X=b_{N-1}||\dots||b_1||b_0$, 则对应的大整数为$x=\sum_{i=0}^{N}b_i\cdot 2^{8\cdot i}, N=len(x)$;

## [密码学原语](#toc)

### [加密RSAEP](#toc)

$$
c = m^e \mod n
$$

### [解密RSADP](#toc)

- 第一种私钥表示:
  - $m = c^d \mod n$;
- 第二种私钥表示:
  - $m_1 = c^{dP}\mod p, m_2 = c^{dQ}\mod q$;
  - $m_i = c^{d_i}\mod r_i, i=3,\dots,u$;
  - $h=(m_1 - m_2)\cdot qInv \mod p$;
  - $m = m_2 + q\cdot h$;
  - 初始化$T=r_1$, $m = m + (T\cdot r_{i-1})\cdot ((m_i - m)\cdot t_i \mod r_i)\quad for\ i\ from\ 3\ to\ u$

### [签名RSASP1](#toc)

- 第一种私钥表示:
  - $s=m^d \mod n$;
- 第二种私钥表示:
  - $s_1 = m^{dP}\mod p, s_2 = m^{dQ}\mod q$;
  - $s_i = m^{d_i} \mod r_i, i = 3,\dots,u$;
  - $h = (s_1 - s_2)\cdot qInv\mod p$;
  - $s = s_2 + q\cdot h$;
  - 初始化$T=r_1$, $s = s + (T\cdot r_{i-1})\cdot ((s_i - s)\cdot t_i \mod r_i)\quad for\ i\ from\ 3\ to\ u$

### [验证RSAVP1](#toc)

$$
m = s^e \mod n
$$

## [加密方案](#toc)

### [RSAES-OAEP](#toc)

- 符号说明:
  - $L$: 和消息$M$相关联的标签, 默认为空字符串;
  - $MGF$: 掩码生成函数(Mask Generation Function);

#### [RSAES-OAEP-Encrypt](#toc)

- 检查长度是否满足以下要求:
  - $len(L)$的长度需小于Hash函数对输入八位串长度的限制;
  - $len(M)\le len(n) - 2\cdot len(HashVal) - 2$;
- EME-OAEP编码:
  - $lval = Hash(L)$;
  - 生成八位串字符串$PS=0||\dots||0,\ len(PS)=len(n)-len(M)-2\cdot len(HashVal) - 2$;
  - 生成八位串字符串$DB=lval || PS || 0x01 || M$;
  - 生成八位串长度为$len(HashVal)$的随机八位串字符串$seed$;
  - $dbMask = MGF(seed, len(n)-len(HashVal)-1)$;
  - $maskedDB = DB \oplus dbMask$;
  - $seedMask = MGF(maskedDB, len(HashVal))$;
  - $maskSeed = seed \oplus seedMask$;
  - $EM = 0x00 || maskedSeed || maskedDB$;
- RSA加密:
  - $m=OS2IP(EM)$;
  - $c = RSAEP(m)$;
  - $C = truncate_{len(n)}(I2OSP(c))$;
- 输出$C$;

#### [RSAES-OAEP-Decrypt](#toc)

- 检查长度是否满足以下要求:
  - $len(L)$的长度需要小于Hash函数对输入八位串长度的限制;
  - $len(C) = len(n)$;
  - $len(n) \ge (2*len(HashVal) + 2)$;
- RSA解密:
  - $c=OS2IP(C)$;
  - $m = RSADP(c)$;
  - $EM = truncate_{len(n)}(I2OSP(m))$;
- EME-OAEP解码:
  - $lval = Hash(L)$;
  - $EM = Y || maskedSeed || maskedDB$;
  - $seedMask = MGF(maskedDB, len(HashVal))$;
  - $seed = maskedSeed \oplus seedMask$;
  - $dbMask = MGF(seed, len(n)-len(HashVal)-1)$;
  - $DB = maskedDB \oplus dbMask$;
  - $DB = lval^{'} || PS || Z || M$;
- 检查格式是否合法:
  - $Y = 0x00$;
  - $lval = lval^{'}$;
  - $Z = 0x01$;
- 输出$M$;

### [RSAES-PKCS1_v1.5](#toc)

#### [RSAES-PKCS1_v1.5-Encrypt](#toc)

- 检查消息长度是否合规:
  - $len(M) \le (len(n) - 11)$;
- EME-PKCS1-v1.5编码:
  - 随机生成各字节都非0的八位串: $PS,\quad len(PS) = len(n)-len(M)-3$;
  - $EM = 0x00||0x02||PS||0x00||M$;
- RSA加密:
  - $m=OS2IP(EM)$;
  - $c = RSAEP(m)$;
  - $C = I2OSP(c)$;
- 输出$C$;

#### [RSAES-PKCS_v1.5-Decrypt](#toc)

- 检查密文长度是否合规:
  - $len(C) = len(n), len(n) \ge 11$;
- RSA解密:
  - $c = OS2IP(C)$;
  - $m = RSADP(c)$;
  - $EM = I2OSP(m)$;
- EME-PKCS1-v1.5解码:
  - $EM= X||Y||PS||Z||M$;
  - 检查解码格式是否合规:
    - $X = 0x00, Y=0x02, Z=0x00$;
- 输出$M$;

## [签名方案](#toc)

### [RSASSA-PSS](#toc)

#### [RSASSA-PSS-Sign](#toc)

- EMSA-PSS编码:
  - $EM = EMSA-PSS-Encode(M, bitslen(n)-1)$;
- RSA签名:
  - $m = OS2IP(EM)$;
  - $s = RSASP1(m)$;
  - $S = truncate_{len(n)}(I2OSP(s))$;

#### [RSASSA-PSS-Verify](#toc)

- 检查签名长度:
  - $len(S) = len(n)$;
- RSA签名验证:
  - $s = OS2IP(S)$;
  - $m = RSAVP1(s)$;
  - $EM = trancate_{emLen}(I2OSP(m)), emLen = \lceil (bitslen(n) - 1) / 8 \rceil$;
- EMSA-PSS验证:
  - $EMSA-PSS-Verify(M, EM, bitslen(n) - 1)$;

### [RSASSA-PKCS1-v1.5](#toc)

#### [RSASSA-PKCS1-v1.5-Sign](#toc)

- EMSA-PKCS1-v1.5编码:
  - $EM = EMSA-PKCS1-v1.5-Encode(M)$;
- RSA签名:
  - $m = OS2IP(EM)$;
  - $s = RSASP1(m)$;
  - $S = I2OSP(s)$;

#### [RSASSA-PKCS1-v1.5-Verify](#toc)

- 检查$len(S) = len(n)$
- RSA验证:
  - $s = OS2IP(S)$;
  - $m = RSAVP1(S)$;
  - $EM = I2OSP(m)$;
- EMSA-PKCS1-v1.5编码:
  - $EM' = EMSA-PKCS1-v1.5-Encode(M)$;
  - 检查$EM = EM'$;

### [EMSA-PSS](#toc)

- $emBits$: $OS2IP(EM)$的最大位长度, $emLen = \lceil emBits/8 \rceil$;
- $sLen$: salt的字节长度;

#### [EMSA-PSS-Encode](#toc)

- `EMSA-PSS-Encode(M, emBits)`:
  - 检查消息的长度是否合规:
    - $len(M)$小于Hash函数的最大输入串的长度;
    - $emLen \ge (len(HashVal) + sLen + 2$;
  - $mHash = Hash(M)$;
  - 随机生成长度为$sLen$的salt字符串;
  - $M' = 0x00||0x00||0x00||0x00||0x00||0x00||0x00||0x00||mHash||salt$;
  - $H = Hash(M')$;
  - $PS = 0||\dots||0, len(PS)=emLen - sLen - len(H) - 2$;
  - $DB = PS || 0x01 || salt$;
  - $dBMask = MGF(H, emLen - len(H) - 1)$;
  - $maskedDB = DB\oplus dbMask$;
  - 将$maskedDB$最左边的$8*emLen - emBits$的各位替换为0;
  - $EM = maskedDB || H || 0xbc$;
  - 输出EM;

#### [EMSA-PSS-Verify](#toc)

- `EMSA-PSS-Verify(M, EM, emBits)`:
  - 检查消息的长度是否合规:
    - $len(M)$小于Hash函数的最大输入串的长度;
    - $emLen \ge (len(HashVal) + sLen + 2$;
  - 检查$EM$最右边的字节是否为$0xbc$;
  - $EM = maskedDB || H, len(maskedDB) = emLen - len(HashVal) - 1$;
  - 检查$maskedDB$最左边的$8*emLen - emBits$的各位是否为0;
  - $dbMask = MGF(H, emLen - len(H) - 1)$;
  - $DB = maskedDB \oplus dbMask$;
  - 将$DB$的最左边的$8*emLen - emBits$的各位替换为0;
  - $DB = X||Y||salt, len(X) = emLen-len(H)-sLen-2, len(Y)=1$;
  - 检查$X$的各位是否为0, 且$Y=0x01$;
  - $M' = 0x00||0x00||0x00||0x00||0x00||0x00||0x00||0x00||mHash||salt$;
  - $H' = Hash(M')$;
  - 检查是否满足$H = H'$;

### [EMSA-PKCS1-v1.5](#toc)

#### [EMSA-PKCS1-v1.5-Encode](#toc)

- 检查消息的长度是否合规:
  - $len(M)$小于Hash函数的最大输入串的长度;
- $H = Hash(M)$;
- `DER(Distinguished Encoding Rules)`:

```txt
DigestInfo ::= SEQUENCE {
  digestAlgorithm AlgorithmIdentifier,
  digest OCTET STRING
}
```

- 检查$emLen \ge (len(DigestInfo) + 11)$;
- $PS=0xff||\dots||0xff,\quad len(PS) = emLen - len(DigestInfo) - 3$;
- $EM = 0x00 || 0x01 || PS || 0x00 || DigestInfo$;
- 输出$EM$;

## [MGF](#toc)

PKCS#1 v2.2中定义了掩码生成函数MGF1, 其和标准IEEE 1363-2000, ANSI X9.44-2007中的一致;

- $MGF1(seed, olen)$:
  - $olen$表示掩码函数输出字串的长度, 需满足$olen\lt 2^{32}\cdot len(HashVal)$;
  - 初始化$T$为空串;
  - $T = T || Hash(seed || truncate_4(I2OSP(i)))\quad for\ i\ from\ 0\ to\ \lceil olen/len(HashVal) \rceil - 1$;
  - $truncate_{olen}(T)$;

## [参考资料](#toc)

- PKCS#1 v2.2: RSA Cryptography Standard;
