# kDF密钥派生函数

<span id='toc'></span>
[TOC]

## [Extraction-then-Expansion(E-E) Key Derivation Procedure](#toc)

```mermaid
graph TD;
  id1(KeyAgreementPrimitive) -.SharedSecret.-> id2(ExtractionStep)
  id2 -.KeyDerivationKey.-> id3(ExpansionStep)
  id3 -.DerivedKeyingMaterial, k1..ki..kn.-> id4(KDF)
  id4 -.- id5(DerivedKeingMaterial)
```

- SP 800-56C中定义了ExtractionStep->ExpansionStep;
- SP 800-108中定义了ExpansionStep;

### [Internet Key Exchange(IKE)](#toc)

#### [IKEv1-KDF](#toc)

- RFC 2409;  
- $g^{xy}$: Diffie-Hellman(DH) key exchange value, also called DH shared key;
- $a || b$: 表示字符串b拼接在字符串a后;

当数字签名(digital signature)用于认证时: $SKEYID=HMAC(Ni_b || Nr_b, g^{xy})$, $Ni_b, Nr_b$是non-secret values;

当公钥算法(public key algorithm)用于认证时: $SKEYID=HMAC(HASH(Ni_b||Nr_b), CKY-I||CKY-R)$, $Ni_b, Nr_b$是secret nonces, $CKY-I, CKY-R$是non-secret values;

当预共享密钥(pre-shared key)用于认证时: $SKEYID=HMAC(pre\_shared\_key, Ni_b||Nr_b)$, $Ni_b, Nr_b$是non-secret values;

$SKEYID_d=HMAC(SKEYID, g^{xy}||CKY-I||CKY-R||0)$, $SKEYID_d$用作密钥派生密钥, 为新的协商SA(security association)生成新的钥材(Key Material);

$SKEYID_a=HMAC(SKEYID, SKEYID_d||g^{xy}||CKY-I||CKY-R||1$, $SKEYID_a$用作HMAC密钥, 以认证当前的SA消息;

$SKEYID_e = HMAC (SKEYID, SKEYID_a || g^{xy} || CKY-I || CKY-R || 2)$, $SKEYID_e$用于密钥派生密钥, 以派生对称加密密钥, 为当前SA消息提供授信;

#### [IKEv2-KDF](#toc)

- RFC 4306
- $g^{ir}$: Diffie-Hellman(DH) key exchange value, also called DH shared key;

$SKEYSEED=HMAC(Ni||Nr, g^{ir})$, $SKEYSEED$作为密钥派生密钥, 用于ExpansionStep, $Ni, Nr$是non-secret nonce.

### [TLS-KDF](#toc)

- RFC 2246;
- RFC 4346;

## [其它应用特定的KDF](#toc)

### [ANS X9.63-KDF](#toc)

- ANS X9.63

记有数据$Z$, [哈希](https://www.cnblogs.com/mengsuenyan/p/12697811.html)函数$Hash$(hash值的字节长度为$l$), 需要输出的密钥数据字节长度位$k$, 及可选的附加数据$SharedInfo$;

- $Counter=0x00000001$;
- 从$i=0$迭代到$\lceil k/l \rceil$:
  - $K_i=Hash(Z||Counter||SharedInfo)$;
  - $Counter+=1$
- 取$K_0||K_1||\dots ||K_{\lceil k/l \rceil}$最左边$k$个字节赋给$K$;
- 输出$K$;

符号说明: $X||Y$: 表示$Y$拼接在$X$之后;

### [SecureShell(SSH)-KDF](#toc)

- RFC4251;
- RFC4252;
- RFC4253;
- RFC4254;

### [SecureRealTimeTransportProtocol(SRTP)-KDF](#toc)

- RFC3550;
- RFC3711;
- RFC6188;

### [SimpleNetworkManagementProtocol(SNMP)-KDF](#toc)

- RFC2571;
- RFC2574;

### [TrustedPlatformModule(TPM)-KDF](#toc)

- TPM Principles;
- TPM Structures;
- TPM Commands;

## [参考资料](#toc)

[1]. Standars for Efficient Cryptography 1 (SEC1: Elliptic Curve Cryptography), Daniel R.L.Brown;
[2]. ANSI-X9.63-KDF;
[3]. IKEv2-KDF;
[4]. TLS-KDF;
[5]. NIST-800-56-Concatenation-KDF;
[6]. SP 800-135r1;  
