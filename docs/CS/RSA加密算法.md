# [RSA加密算法](#toc)

<span id='toc'></span>
[TOC]

## [符号说明](#toc)

- $x\dots y$: $y$拼接在$x$之后;  

## [RSA v1.5](#toc)

### [密钥生成](#toc)

- 随机选择两个质数$p$和$q$($p\neq q$), 则模数$n=p*q$. 模数的字节长度$k$满足: $2^{((k-1)*8}\le n \lt 2^{k*8}$;  
- 在$[1,n]$之中, 随机选择一个整数$e$作为公钥的指数部分. 其中, $e$满足和$p-1$及$q-1$都是互质关系(公共因子是1);  
- 那么私钥的指数部分$d$满足: $d*e-1$能被$q-1$和$p-1$整除;  

### [密钥的表示](#toc)

RSA标准中的密钥表示采用ASN.1语法, 公钥和密钥表示如下:

```txt
RSAPublicKey ::= SEQUENCE {
    modulus         INTEGER, -- n
    publicExponent  INTEGER, -- e
}

RSAPrivateKey ::= SEQUENCE {
    version         Version,
    modulus         INTEGER, -- n
    publicExponent  INTEGER, -- e
    privateExponent INTEGER, -- d
    prime1          INTEGER, -- p
    prime2          INTEGER, -- q
    exponent1       INTEGER, -- d mod (p-1)
    exponent2       INTEGER, -- d mod (q-1)
    coeffient       INTEGER, -- (inverse of q) mod p
}

Version ::= INTEGER
```

### [加密过程](#toc)

```mermaid
graph LR;
    id1(数据块格式化) --> id2(整数转换);
    id2 --> id3(RSA计算);
    id3 --> id4(字节流转换);
```

#### [格式化](#toc)

记有数据块$D$, 其字节长度应满足$len(D)\le k$. 那么, $D$需要按照如下格式填充:

$$
EB = 0x00 \dots BT \dots PS \dots 0x00 \dots D
$$

- EB: 格式化后的数据块, 字节长度为$k$;  
- BT: 数据块的类型: 私钥操作中为`0x00`or`0x01`, 公钥操作中为`0x02`;  
- D: 原始数据块;  
- PS: 字节长度为$k-3-len(D)$, `BT=0x00`则填充为`0x00`; `BT=0x01`则填充为`0xff`; `BT=0x02`则填充为非0的随机数;  

#### [整数转换](#toc)

将EB转换为正整数$x$, $x=\sum_{i=0}^{k-1}2^{8*(k-1-i)}EB_{i}$, $EB_{i}$表示$EB$从左往右的第i个字节所表示的十进制数.  

#### [RSA计算](#toc)

RSA计算公式如下:  

$$
y = x^e \mod n
$$

#### [字节流转换](#toc)

将整数$y$转换为字节数据块$ED$, 满足$y=\sum_{i=0}^{k-1}2^{8*(k-1-i)}ED_{i}$, $ED_{i}$表示$ED$从左往右的第i个字节所表示的十进制数.

### [解密过程](#toc)

解密过程是加密的逆过程, 除了RSA计算采用的是私钥指数$y=x^d \mod n$, 其它按照加密的逆序操作即可;  

## [参考资料](#toc)

- RFC2313 RSA v1.5;  
- RFC3447 RSA v2.1;  
- RFC8017 RSA v2.2;  
