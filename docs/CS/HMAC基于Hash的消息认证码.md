# [HMAC基于Hash的消息认证码](#toc)

<span id='toc'></span>
[TOC]

## [HMAC](#toc)

- H: 哈希函数;  
- K: 密钥;  
- $K_{0}$: 经过预处理后的密钥;  
- B: 哈希函数计算消息的哈希值时, 所使用的块大小(字节长度);  
- L: 哈希函数所计算的哈希值的字节长度;
- text: 消息数据;  
- $x\oplus y$: x异或y;  
- $x\dots y$:表示将数据块$y$拼接在数据块$x$之后;  

HMAC通过指定的Hash函数, 提供了一种消息传输或存储的一致性验证机制, 其验证机制如下:

$$
\begin{aligned}
& MAC(text) == HMAC(K, text) \Rightarrow \\
& MAC(text) == H((K_{0} \oplus opad) \dots H(K_{0} \oplus ipad)\dots text)
\end{aligned}
$$

解释如下:

- ipad: `0x36`重复B次后得到的字节长度为B的数据块;  
- opad: `0x5c`重复B次后得到的字节长度为B的数据块;  
- $K_0$: 如果$len(K)==B$, 那么$K_{0}=K$; 如果$len(K)\lt B$, 那么在K后填充$B-len(K)$个位0得到$K_{0}$; 如果$len(K)\gt B$, 那么先对其进行H(K), 然后填充$B-len(K)$个0得到$K_{0}$;  
- 将消息传拼接到$K_{0}\oplus ipad$之后, 计算Hash值记为$H_{r1}$;  
- 将$H_{r1}$拼接到$K_{0}\oplus opad$之后, Hash计算出来的结果便是MAC值;  

## [参考资料](#toc)

- [RFC2104 HMAC](https://datatracker.ietf.org/doc/rfc2104/);  
- [FIPS/198-1 HMAC](https://csrc.nist.gov/publications/detail/fips/198/1/final);
