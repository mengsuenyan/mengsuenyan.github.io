# Rust Ordering语义理解

<span id='toc'></span>
[TOC]

## [应用场景/条件](#toc)

- 应用场景: 多线程之间使用原子类型通过共享内存的方式进行线程间通信;
- 使用条件: 支持原子类型操作的指令集架构平台, 如`x86/x86_64`支持`LOCK`前缀的指令是原子操作;

注: 使用条件仅仅针对Rust, 当前1.43.1版本中Rust的所有`Atomic**`实现中都加了`#[cfg(target_has_atomic_load_store = "8")]`属性配置;

为什么需要内存顺序?

- 一些编译器有指令重排功能以优化代码执行效率, 在不同线程中针对同一变量(内存)的读写顺序可能会被打乱, 不能保证顺序的一致性;
- 一些处理器中有Cache缓存, 对某一内存的读取可能是从缓存中直接读取, 因此不同线程对同一变量的读写顺序亦不能保证一致性;

## [原子内存顺序](#toc)

Rust原子操作操作有5中内存顺序: `Relaxed/Release/Acquire/AcqRel/SeqCst`, 下面一一介绍;

### [Relaxed](#toc)

没有内存顺序约束, 仅仅是原子类型的本条`store/load`操作是原子操作, 即针对该原子类型的在不同线程之间的操作顺序是任意的;

### [Release/Acquire](#toc)

`Release`和`Acquire`是在不同的线程间针对同一原子类型对象的进行`store`和`load`操作时配合使用. 当一个线程`store`with`Release`写原子类型对象, 而有另一个线程`load`with`Acquire`度原子类型对象时, 那么在写及写之前的所有写原子操作都是发生在另一个线程中读该原子类型之后的所有读原子操作之前.

简而言之就是, `Release`之前的**写**原子操作先于`Acquire`之后的**读**原子操作;

### [AcqRel](#toc)

和Release/Acquire的效果一样, 只不过是读的时候使用`Acquire`顺序, 写的时候使用`Release`顺序;

### [SeqCst](#toc)

若某一原子类型对象在不同线程中使用`SeqCst`读写, 那么该原子操作之前的所有**读写**原子操作都先于该原子操作之后的**读写**操作

## [参考资料](#toc)

- The Rust Standard Library Version 1.43.1;
- [cppreference std::memory_order](https://en.cppreference.com/w/cpp/atomic/memory_order#Release-Acquire_ordering);