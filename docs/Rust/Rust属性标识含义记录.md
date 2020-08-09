# Rust属性标识含义记录

<span id='toc'></span>
[TOC]

- `#[fundamental]`: Rust trait系统有个*孤儿规则(Orphan Rule)*的限制, 他的含义是: 当要在某个类型上实现某个trait时, 要求该类型或该Trait至少有一个是再当前crate中定义的. 但是当某个类型加上`#[fundamental]`属性标识时, 可不受该规则限制;
- `#[global_allocator]`: 用于实现了`GlobalAlloc`trait的静态变量上以设置全局内存分配器;
- `#[cold]`: 告知编译器该属性标识的函数不大可能被调用;
- `#[link_name="xxx"]`: 告知编译器某个函数在名为"xxx"库中定义;
- `#[cfg(debug_assertions)]`: 改属性告知编译器其标注的代码在debug版本中保留, 在优化版本中去掉;

## [测试相关](#toc)

- `#[test]`: 该属性用于告知编译器其标注的函数用作为测试函数, 其中该函数需满足: 不带参数, 返回值为`()`或`Result<(), E> where E: Error`;
- `[should_panic]` or `#[should_panic = "panic message"]` or `#[should_panic(expected =  "panic message")]`: 该属性用于标注了`#[test]`属性的返回值为`()`的函数, 表示该函数会产生panic, 其中的`"panic message"`为panic的提示信息;
- `#[ignore]` or `#[ignore = "why the test is ignored"]`: 用于标注了`#[test]`属性的函数, 告知编译器该测试函数不需要执行, 但是在测试模式下需要编译;

## [参考资料](#toc)

- [Rust 1.44.1](https://github.com/rust-lang/rust.git);
