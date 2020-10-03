# Hash函数的安全性

<span id='toc'></span>
[TOC]

## [安全性指标](#toc)


### [Collision Resistance](#toc)

抗碰撞性(Collision Resistance): 若有**任意**两条消息$x_1, x_2$且$x_1 \ne x_2$, 则发现$H(x_1)=H(x_2)$需要计算的次数为$2^N$, 则其抗碰撞性为$N/2$. 一般情况下$N=L$;

### [Preimage Resistance](#toc)

抗原像性(Preimage Resistance): 若有任意一个消息摘要$y$, 则找到一个消息$x$满足$H(x)=y$需要计算的次数为$2^N$, 则其抗原像性为$N$. 一般情况下$N=L$;

### [Second Preimage Resistance](#toc)

抗二次原像性(Second Preimage Resistance): 若**给定**任意一个消息$x_1$, 那么找到另一个消息$x_2 \ne x_1$, 使得$H(x_2)=H(x_1)$需要计算的次数为$2^N$, 则其抗碰撞性为$N$. 一般情况下$N=L$;

## [SHA-2](#toc)

||SHA-1|SHA-224|SHA-256|SHA-384|SHA-512/224|SHA-512/256|SHA-512|
|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
|CR|<80|112|128|192|112|128|256|
|PR|160|224|256|384|224|256|512|
|SPR|160-L(M)|min(224,256-L(M))|256-L(M)|384|224|256|512-L(M)|

## [SHA-3](#toc)

||SHA-224|SHA-256|SHA-384|SHA-512|SHAKE128|SHAKE256|
|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
|CR|112|128|192|256|min(d/2,128)|min(d/2,256)|
|PR|224|256|384|512|>=min(d,128)|>=min(d,256)|
|CPR|224|256|384|512|min(d,128)|min(d,256)|

其中:
$$
L(M) = \lceil log_2(len(M)/block\_bits\_len) \rceil
$$

## [参考资料](#toc)

1. FIPS-202;  
2. SP 800-107 r1;  
