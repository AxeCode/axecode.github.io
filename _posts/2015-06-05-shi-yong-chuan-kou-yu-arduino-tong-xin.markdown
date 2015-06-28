---
layout: post
title: "使用串口与 Arduino 通信"
date: 2015-06-05 08:31:25 +0800
comments: true
categories: Arduino
---
## 在此之前

在串口通信实验之前还有几个其他的实验里面有一些需要记录的知识。

`constrain()` 函数：需要三个参数 x, a, b。这里 x 是一个被约束的数，它的最小值是 
a 最大值是 b。

`random()` 函数生成一个给定范围内的随机数，可以使用 `randomSeed()` 函数预先设置
随机数范围。

## 需要的硬件

这个实验会需要一个5V的 RGB 彩灯，也可以使用三个分别是红、绿、蓝色的 LED 灯代替。

## 代码回顾

``` c
char buffer[18];
int red, green, blue;

byte redPin   = 11;
byte bluePin  = 9;
byte greenPin = 10;

void setup() {
  Serial.begin(9600);
  Serial.flush();
  pinMode(redPin, OUTPUT);
  pinMode(bluePin, OUTPUT);
  pinMode(greenPin, OUTPUT);
}

void loop() {
  if (Serial.available() > 0) {
    int index = 0;
    delay(100);
    int numChar = Serial.available();
    if (numChar > 15) {
      numChar = 15;
    }
    while (numChar--) {
      buffer[index++] = Serial.read();
    }
    splitString(buffer);
  }
}

void splitString(char * data) {
  Serial.print("Data entered: ");
  Serial.println(data);
  char * parameter = strtok(data, " ,");
  while (parameter != NULL) {
    setLED(parameter);
    parameter = strtok(NULL, " ,");
  }
  
  for (int i = 0; i < 16; i++) {
    buffer[i] = '\0';
  }
  Serial.flush();
}

void setLED(char * data) {
  if ((data[0] == 'r' || data[0] == 'R')) {
    int Ans = strtol(data + 1, NULL, 10);
    Ans = constrain(Ans, 0, 255);
    analogWrite(redPin, Ans);
    Serial.print("Red is set to: ");
    Serial.println(Ans);
  }
  if ((data[0] == 'g' || data[0] == 'G')) {
    int Ans = strtol(data + 1, NULL, 10);
    Ans = constrain(Ans, 0, 255);
    analogWrite(greenPin, Ans);
    Serial.print("Green is set to: ");
    Serial.println(Ans);
  }
  if ((data[0] == 'b' || data[0] == 'B')) {
    int Ans = strtol(data + 1, NULL, 10);
    Ans = constrain(Ans, 0, 255);
    analogWrite(bluePin, Ans);
    Serial.print("Blue is set to: ");
    Serial.println(Ans);
  }
}
```

在 setup 函数中，使用了新的函数 `Serial.begin(9600)`。它到诉 Arduino 开始串口通
信，函数的参数是波特率(每秒内信号或者脉冲数)。串口以这个波特率开始通信。

`Serial.flush()` 命令清空串口中的残存的字符，为输入/输出做准备。

串口是 Arduino 与外界通信的一个简单方法。

在 loop 函数一开始，使用了 `Serial.available()` 函数检查是否有字符串发送到串口。
因为程序的执行快于串口数据的发送速度，所以在读取数据之前，需要执行 `delay(100)`
等待串口缓冲区数据到满。 后面，使用 `Serial.read()` 函数读串口数据，每次读取一个
字节。

读取完数据之后，需要对读取的字符串进程处理。在 Arduino 中，可以使用 `Serial.print`
和 `Serial.println` 函数打印字符串。之后，使用 `strtok(str, delimiter)` 函数分隔
字符串。如果delimiter的值是 " ,"，那么将按照空格或者逗号分割。

``` c
char * parameter = strtok(data, " ,");
while (parameter != NULL) {
  setLED(parameter);
  parameter = strtok(NULL, " ,");
}
```

看上面代码，在while循环中通过传递给 `strtok` 一个NULL值来实现对原来切割的字符串
的再次分割。

最后，需要清除串口缓冲区和 buffer 数组内的数据，为下一次数据的输入做准备。

之后，将处理后的字符串传递给 `setLED` 函数，让它控制 LED 的发光情况。

在 `setLED` 函数中，使用了 `strtol` 方法将分割后的字符串转换成数字.

``` c strtol reference
/**
 * @description 从一个字符串中解析integer类型数字
 * 这个方法会忽视 str 中前所有的空白字符，直到遇到第一个非空白字符，
 * 然后它将分析 str 可能的进制，将他转换为指定进制的数字。一个合法
 * 的数字由以下几个方面组成：
 * 1. + / - 代表正负的符号
 * 2. 前缀是0代表它大部分情况下是8进制
 * 3. 0x 或者 0X 前缀被认为是16进制
 * 4. 接下来的数字
 * 
 * @param str 需要解析的字符串
 * @param str_end 结尾字符，如果是NULL，这个参数会被忽略
 * @param base 被解析的字符串的进制
 **/
long strtol(const char * str, char ** str_end, int base);
```

将解析得到的亮度通过 `analogWrite(pinNum, value)` 写入则完成了对 LED 的控制。

总结
===

+ 脉宽调制『PWM』以及如何利用 `analogWrite` 使用它们
+ 串口通信概念
+ 如何使用相同的电路、不同的代码产生各种灯光效果
+ 使用 `Serial.begin()` 设置波特率
+ 使用串口监视器发送命令
+ 使用 `Serial.flush()` 清空串口缓冲区
+ 使用 `Serial.available()` 检查数据是否发送到串口
+ 使用 `Serial.read()` 从串口中读数据
+ 使用 `Serial.print()`, `Serial.println()` 打印数据到串口监视器
+ 使用 `strtok()` 分隔字符串
+ 使用 `strtol()` 将字符串转为长整形数
+ 使用 `constrain()` 函数限制一个变量值
