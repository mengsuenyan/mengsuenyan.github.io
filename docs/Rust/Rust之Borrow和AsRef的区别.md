# Rust Borrow和AsRef的区别

<span id='toc'></span>
[TOC]

`AsRef/AsRefMut`和`Borrow/BorrowMut`具有相似的借语义, 但他们有如下的不同;

- 任何类型`T`都实现了(**blanket impl**)`Borrow`trait, 即Rust中任何实例都是可以被借用(`&/&mut`)的(当然这里任何是指满足语法语义规则的任何, 比如该实例没有其被其它实例`&mut`借用). 而AsRef只是实现了满足实现了`AsRef<U>`的类型`&T`到`&U`的转换. 源码如下:;

```Rust
///////////////////////////////////Borrow
#[stable(feature = "rust1", since = "1.0.0")]
impl<T: ?Sized> Borrow<T> for T {
    fn borrow(&self) -> &T {
        self
    }
}

#[stable(feature = "rust1", since = "1.0.0")]
impl<T: ?Sized> BorrowMut<T> for T {
    fn borrow_mut(&mut self) -> &mut T {
        self
    }
}

/////////////////////////////////// AsRef
#[stable(feature = "rust1", since = "1.0.0")]
impl<T: ?Sized, U: ?Sized> AsRef<U> for &T
where
    T: AsRef<U>,
{
    fn as_ref(&self) -> &U {
        <T as AsRef<U>>::as_ref(*self)
    }
}

#[stable(feature = "rust1", since = "1.0.0")]
impl<T: ?Sized, U: ?Sized> AsRef<U> for &mut T
where
    T: AsRef<U>,
{
    fn as_ref(&self) -> &U {
        <T as AsRef<U>>::as_ref(*self)
    }
}
```

- `Borrow`还有一个潜在的语义是: 如果某个类型实现了`Hash/Eq/Ord`, 那么在`Borrow`实例上的`Hash/Eq/Ord`操作应该和该类型实例上的`Hash/Eq/Ord`操作是等效的, 如`HashMap`上的`get`接口实现对`K`的类型约束. 根据该潜在的语义, 如果只是借用某个结构`struct`中的某个域, 应该实现`AsRef`而不是`Borrow`;

```Rust

#[stable(feature = "rust1", since = "1.0.0")]
impl<T: ?Sized> Borrow<T> for &T {
    fn borrow(&self) -> &T {
        &**self
    }
}

#[stable(feature = "rust1", since = "1.0.0")]
impl<T: ?Sized> Borrow<T> for &mut T {
    fn borrow(&self) -> &T {
        &**self
    }
}

#[stable(feature = "rust1", since = "1.0.0")]
impl<T: ?Sized> BorrowMut<T> for &mut T {
    fn borrow_mut(&mut self) -> &mut T {
        &mut **self
    }
}
```

## [参考资料](#toc)

- [Rust 1.44.1](https://github.com/rust-lang/rust.git);
