---
layout: post
title: "重新认识Java，发现你的细节"
date: 2014-01-25 09:08:34 +0800
comments: true
categories: 技术
---
## 序言

“人和动物的本质区别是会制造和使用劳动工具”，这是初中历史课上的内容。  
“工欲善其事，必先利其器”，先贤留下的警世恒言。   
“高明的剑客，通晓其剑。是何材质，轻重几许，剑刃几分……”。  

自古以来，人们便被教育工具的重要性。而人类，也是从文明伊始便发明种类繁复的工具，用以提高人的劳动
效率或者便利人的生活。计算机，人类有史以来最伟大的工具之一，引爆了整个人类发展的进程，使得最近三
十年以来人类信息增加的总量超过了过去几千年的信息增长量。语言，人类最伟大的工具，在整个人类文明中
扮演了最重要的角色。编程语言相对于计算机而言便等于语言至于人类，其重要性可见一斑。   

有了计算机和编程语言，那么自然便衍生了一种以它们为生的职业——程序员，使用编程语言建设计算机世界的
劳动者。我作为一名使用Java编程语言的程序员，试问自己，我是否了解我所使用的工具呢？答案是没有。所
以我写下这篇博文。

## 操纵字符串

**显而易见，字符串操作是计算机程序中最常见的行为。**在Java大展拳脚的Web系统中更是如此。

###String，其实是不可变的###

> Strings are constant; their values cannot be changed after they are created.
> String buffers s
  upport mutable strings. Because String objects are immutable they can be shared.

举例来说:

``` java
String str = "abc";
```

实际上是：

``` java
char[] data = { 'a', 'b', 'c' };
String str  = new String(data);
```

通过查询JDK文档会发现，String类每一个看起来会修改字符串的方法，实际上都是创建了一个全新的字符串。
通过一则代码说明：

``` java
public class Immutable {
    public static void main(String[] args) {
        String s = "immutable";
        String ss = s.toUpperCase();
        System.out.println(s);
        System.out.println(ss);
    }
}
/** Output:
  *  immutable
  *  IMMUTABLE
  */
```

在调用`toUpperCase`方法的实际上在内存中为该对象创建了一个副本，对其的操作都是在这个副
本上进行的。

### 重载的“+”与StringBuilder

在Java中针对String类，重新定义了操作符“+”的行为，它可以连接多个字符串。先看一段代码：

``` java
String mongo = "mongo";
String str = "This is a database named " + mongo + " it's awesome.";
```

想象一下这段代码是如何工作的：先创建一个`mongo`对象，在执行连接操作时，先为`This
is a database named` 创建一个对象，再为连接后的字符串创建一个对象，以此类推。那么在内存中不
可避免的会出现巨大的浪费，带来性能问题。实际的情况是怎样的呢？使用

``` bash
javap -c CLASSNAME
```

命令来反编译这段代码的二进制文件，看看在Java中到底是以什么样的方式执行字符串的连接操作的。

``` asm
Compiled from "Concatenation.java"

public class Concatenation {
  public Concatenation();
    Code:
        0: aload_0
        1: invokespecial #1                  // Method java/lang/Object."<init>":()V
        4: return

  public static void main(java.lang.String[]);
    Code:
        0: ldc           #2                  // String mongo
        2: astore_1
        3: new           #3                  // class java/lang/StringBuilder
        6: dup
        7: invokespecial #4                  // Method java/lang/StringBuilder."<init>":()V
      10: ldc           #5                  // String This is a database named
      12: invokevirtual #6                  // Method java/lang/StringBuilder.append:(Ljava/lang/String;)Ljava/lang/StringBuilder;
      15: aload_1
      16: invokevirtual #6                  // Method java/lang/StringBuilder.append:(Ljava/lang/String;)Ljava/lang/StringBuilder;
      19: ldc           #7                  // String  it's awesome.
      21: invokevirtual #6                  // Method java/lang/StringBuilder.append:(Ljava/lang/String;)Ljava/lang/StringBuilder;
      24: invokevirtual #8                  // Method java/lang/StringBuilder.toString:()Ljava/lang/String;
      27: astore_2
      28: getstatic     #9                  // Field java/lang/System.out:Ljava/io/PrintStream;
      31: aload_2
      32: invokevirtual #10                 // Method java/io/PrintStream.println:(Ljava/lang/String;)V
      35: return
}
```

这段反编译的代码相当于运行在Java虚拟机上的汇编语句。从中可以看到，编译器为我们自动的引入了
`java.lang.StringBuilder`对象，并且在每一次的连接操作时会调用它的`append`方法，最
后使用`toString`生成结果。无疑这是一个更高效的行为，但是`StringBuilder`又是
什么呢？

> A mutable sequence of characters.

在`StringBuilder`中最核心的两个方法是``append`和'toString`。它们接收
任何对象，将对象转成字符串后添加或者插入到String Builder中。
通常

``` java
sb.append(x);
```

与

``` java
sb.inset(sb.length(), x);
```

有着一样的效果。

`StringBuilder`的方法还包括：insert, repleace, substring, delete
甚至是reverse。

有了编译器的自动优化就可以随意的使用字符串了吗？下面代码使用两种方式生成一个字符串：第一种使用多个
String对象，让编译器为我们优化；第二种显式的调用StringBuilder。

``` java
public String implicit(String[] strs) {
    String result = "";
    for(String s : strs)
        result += s;
    return result;
}

public String explicit(String[] strs) {
    StringBuilder result = new StringBuilder();
    for(String s : strs)
        result.append(s);
    return result.toString();
}
```

反编译一下，看看实际调用过程：A mutable sequence of characters.

``` asm
Compiled from "WithStringBuilder.java"

public class WithStringBuilder {
  public WithStringBuilder();
    Code:
        0: aload_0
        1: invokespecial #1                  // Method java/lang/Object."<init>":()V
        4: return

  public java.lang.String implicit(java.lang.String[]);
    Code:
        0: ldc           #2                  // String 
        2: astore_2
        3: aload_1
        4: astore_3
        5: aload_3
        6: arraylength
        7: istore        4
        9: iconst_0
      10: istore        5
      12: iload         5
      14: iload         4
      16: if_icmpge     51
      19: aload_3
      20: iload         5
      22: aaload
      23: astore        6
      25: new           #3                  // class java/lang/StringBuilder
      28: dup
      29: invokespecial #4                  // Method java/lang/StringBuilder."<init>":()V
      32: aload_2
      33: invokevirtual #5                  // Method java/lang/StringBuilder.append:(Ljava/lang/String;)Ljava/lang/StringBuilder;
      36: aload         6
      38: invokevirtual #5                  // Method java/lang/StringBuilder.append:(Ljava/lang/String;)Ljava/lang/StringBuilder;
      41: invokevirtual #6                  // Method java/lang/StringBuilder.toString:()Ljava/lang/String;
      44: astore_2
      45: iinc          5, 1
      48: goto          12
      51: aload_2
      52: areturn

  public java.lang.String explicit(java.lang.String[]);
    Code:
        0: new           #3                  // class java/lang/StringBuilder
        3: dup
        4: invokespecial #4                  // Method java/lang/StringBuilder."<init>":()V
        7: astore_2
        8: aload_1
        9: astore_3
      10: aload_3
      11: arraylength
      12: istore        4
      14: iconst_0
      15: istore        5
      17: iload         5
      19: iload         4
      21: if_icmpge     43
      24: aload_3
      25: iload         5
      27: aaload
      28: astore        6
      30: aload_2
      31: aload         6
      33: invokevirtual #5                  // Method java/lang/StringBuilder.append:(Ljava/lang/String;)Ljava/lang/StringBuilder;
      36: pop
      37: iinc          5, 1
      40: goto          17
      43: aload_2
      44: invokevirtual #6                  // Method java/lang/StringBuilder.toString:()Ljava/lang/String;
      47: areturn
}
```

在反编译的代码中，第一种方法的循环体从12到48行，而第二种方法的循环体是从17到40行，更加的精简。
并且第二种方法只生成了一个StringBuilder对象。显式地创建StringBuilder对象还支持为其制定大小。如
果你知道需要的字符串大概的长短，那么指定StringBuilder的大小可以避免多次重新分配缓存。   

因此在为一个类编写`toString`方法时，如果操作比较简单，那么可以信赖编译器。如果要在方
中使用循环，最好还是显式地声明`StringBuilder`。

###格式化输出，打印出美丽的字符串

在 JAVASE5 中，终于添加了格式化输出的功能。可以使用printf(),
System.out.format()和Formatter类来
控制与排版字符串的输出。

+ `printf()`, 类似于c语言中的`printf()`函数，与c中不同的是java的printf()支持使用“+”符号连接字符串。
+ `System.out.format()`, 与`printf()`是等价的。只需要一个简单地格式化字符串和一些对应的参数。
+ Formatter类，将你需要格式化的信息由一个`OutputStream`或者`OutputWriter`打印出去。

Formatter类的简单示例：

``` java
import java.util.Formatter;

public class Turtle {
    private String name;
    private Formatter f;
    public Turtle(String name, Formatter f) {
        this.name = name;
        this.f = f;
    }

    public void move(int x, int y) {
        f.format("%s The Turtle is at (%d, %d)\n", name, x, y);
    }

    public static void main(String[] args) {
        Turtle t = new Turtle("Li Lei", new Formatter(System.out));
        t.move(3, 4);
        t.move(8, 9);
        t.move(1, 42);
        t.move(3, 2);
    }
}
```

本例中，将格式化的结果打印到System.out中。

###格式化说明符

在插入数据时，如果想要控制空格与对齐，那么就需要更精细的格式修饰符。一下是其抽象的语法：

``` bash
    %[arguments_index$][flages][width][.precision] conversion
```

用一段代码来说明这个语法：

``` java
import java.util.*;

public class Receipt {
    private double total;
    private Formatter f = new Formatter(System.out);

    public void printTitle() {
        f.format("%-15s %5s %10s\n", "Item", "Qty", "Price"); //
默认的对齐方式为右对齐，加上-之后变为左对齐
        f.format("%-15s %5s %10s\n", "----", "---", "-----");
    }

    public void print(String name, int qty, double price) {
        f.format("%-15.15s %5d %10.2f\n", name, qty, price);
        total += price;
    }

    public void printTotal() {
        f.format("%-15s %5s %10.2f\n", "Tax", "", total * 0.06);
        f.format("%-15s %5s %10s\n", "", "", "-----");
        f.format("%-15s %5s %10.2f\n", "Total", "", total * 1.06);
    }

    public static void main(String[] args) {
        Receipt recerp = new Receipt();
        recerp.printTitle();
        recerp.print("NanJing Tofu", 5, 5.8);
        recerp.print("LaoGanMa DouBanJiang", 2, 7.2);
        recerp.print("Little Cabbage", 1, 2.8);
        recerp.printTotal();
    }
}
```

输出结果如下：

    Item              Qty      Price
    ----              ---      -----
    NanJing Tofu        5       5.80
    LaoGanMa DouBan     2       7.20
    Little Cabbage      1       2.80
    Tax                         0.95
                               -----
    Total                      16.75

### 字符转换说明

转换符一般被分成以下几类：

+ **General**，可以转化任意对象
+ **Character**，可以转化用unicode表示的字符。比如char, Character, byte, Byte,
  short, Short. 也可以
  用来转换`Character.validCodePoint()`返回值为true的int或者Integer对象。
+ **Numeric**，转换整数或者浮点数。
+ **Date/Time**，接受long、Long、Date和Calendar类型的参数。
+ **Percent**，产生一个字面量“%”。
+ **Line Separator**，产生一条水平分割线。

下面用一张表格展示可接受参数的符号

符号               | 参数类型        | 描述
-------------------|-----------------|-----------------------------------------------------------
'b', 'B'           | General         | 如果参数是null或者`String.valueOf(arg)`返回值为false的值，得到的结果则是false。否则，结果为true。
'h', 'H'           | General         | 如果参数是null则返回“null”。否则返回这个参数的`Integer.toHexString()`的返回值。
'c', 'C'           | Character       | 返回值为Character。
's', 'S'           | General         | 如果参数是null则返回"null"；如果参数是`Formattable`的实现类，则调用参数的`arg.formatTo()`方法，并且将方法的返回值作为结果；最后返回的结果为`arg.toString()`。
'd'                | Integer         | 返回值为格式化后的十进制数字。
'o'                | Integer         | 返回值为格式化后的八进制数字。
'x', 'X'           | Integer         | 返回值为格式化后的十六进制数字。
'e', 'E'           | floating point  | 将浮点数用科学计数法表示出来。
'f'                | floating point  | 返回值为格式化的浮点数。
'g', 'G'           | floating point  | 返回用科学计数法表示的，固定精度的经过四舍五入的浮点数。
'a', 'A'           | floating point  | 返回指数形式有效位的十六进制浮点数。
't', 'T'           | Data/Time       | 将日期和时间转化成字符串。
'%'                | percert         | 返回一个百分比。
'n'                | line separator  | 返回一条分割线。
