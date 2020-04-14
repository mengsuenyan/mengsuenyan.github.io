# [MD5消息摘要算法](#toc)

[TOC]
<span id='toc'></span>

## [算法流程](#toc)

```mermaid
graph LR;
    step1(位填充)-->step2(初始化MD缓存);
    step2 --> step3(数据处理);
    step3 --> step4(拼接输出);
```

### [位填充](#toc)

记有消息$Msg$, 其位长度为$x_l$, 那么进行MD5计算之前, 需要经过如下位填充步骤:  

- 在$Msg$末尾填充一个位$1$, 然后填充若干个位$0$, 以使其位长度模除512值为448;
  - 注意: 即使$x_l\%512=448$, 依然需要先填充一个1, 然后补齐447个0;  
- 将$x_l$放入到64位长度缓存中($x_l$超过64位长度则截断低64位存入, 不足64位则高位补0), 然后依次将该缓存中的数据按照从低字节到高字节填充到$Msg$的尾部;  

记经过以上两步位填充后的按32位长划分的数组为$M[0, \cdots, N-1]$, 其中$N=y_{l}/32$, $y_l$表示$Msg$填充后的长度;  

### [初始化MD缓存](#toc)

初始化4个32位长的摘要缓存, 记为$A, B, C, D$:  

```Pseudo
uint32_t A = 0x67452301;
uint32_t B = 0xEFCDAB89;
uint32_t C = 0x98BADCFE;
uint32_t D = 0x10325476;
```

### [数据处理](#toc)

数据处理算法如下:  

```Pseudo
# <<< 表示循环左移

# uint32->x,y,z
F(x, y, z) = (x & y) | ((~x) & z)
G(x, y, z) =  (x & z) | (y & (~z))
H(x, y, z) =  x ^ y ^ z
I(x, y, z) =  y ^ (x | (~z))

# uint32->a,b,c,d,Mi,s,t
DP(a, b, c, d, Mi, s, t, Callback) =
    a = b + ((a + Callback(b, c, d) + Mi + t) <<< s)

CALLBACK = [F, G, H, I]
WORDIDX = [lambda x:x, lambda x:(1+5*x)&15, lambda x:(5+3*x)&15, lambda x:(7*x)&15]
T = lambda x: uint32(pow(uint64(2),32) * abs(sin(x)))
S = [7, 12, 17, 22, 5, 9, 14, 20, 4, 11, 16, 23, 6, 10, 15, 21]

for blockIdx in 0...N/16:
    for i in 0...16:
        X[i] = M[blockIdx*16+j]

    AA = A; BB = B; CC = C; DD = D

    for roundIdx in 0...4:
        callback = CALLBACK[roundIdx]
        wordfuc = WORDIDX[roundIdx]
        for wordIdx in 0...4:
            DP(A, B, C, D, M[wordfuc(wordIdx*4)], S[roundIdx*4 + wordIdx], T(wordIdx*4), callback)
            DP(D, A, B, C, M[wordfuc(wordIdx*4+1)], S[roundIdx*4 + wordIdx], T(wordIdx*4+1), callback)
            DP(C, D, A, B, M[wordfuc(wordIdx*4+2)], S[roundIdx*4 + wordIdx], T(wordIdx*4+2), callback)
            DP(B, C, D, A, M[wordfuc(wordIdx*4+3)], S[roundIdx*4 + wordIdx], T(wordIdx*4+3), callback)
        end
    end

    A = A + AA
    B = B + BB
    C = C + CC
    D = D + DD
end

MD5 = [A, B, C, D]
```

## [参考资料](#toc)

- [RFC1321-The MD5 Message-Digest Algorithm](https://tools.ietf.org/pdf/rfc1321.pdf);  
