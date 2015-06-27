---
layout: post
title: "发声器和光敏电阻"
date: 2015-06-15 09:11:03 +0800
comments: true
categories: arduino
---
### 发声器

在 Arduino 中，Arduino IDE 提供了函数用以控制扬声器，使得在 Arduino 项目上增加声
音功能非常容易。

控制发声器与控制 LED 在代码层面没有很大的区别，电路也相差不多。

``` c
pinMode(pinNum, OUTOUT);

// 使发声器发声, 第二个参数是频率
tone(pinNum, frequency);

// 第三个参数是可选参数，以毫秒作为单位，表示声音长度。
// 如果没有指定，则声音将一直持续输出知道一个不同的声音
// 或者使用 noTone 函数结束声音。
tone(pinNum, frequency, duration);

// 使发声器不发声
noTone(pinNum);
```

### 光敏元件

光敏电阻是一个依赖与光的电子元件。在黑暗环境中，光敏电阻是一个具有非常高阻值的电
阻。当光子撞击到光检测器时，电阻值降低。光线越强，电阻值越低。

在接下来这个项目中，使用 LDR 检测光，用压电扬声器给出光亮度的声音反馈。

#### 需要的元件

+ 压电扬声器
+ 光敏电阻
+ 10kΩ电阻

LDR 可以以任何方式插入电路中，它没有极性。

#### 代码

``` c
byte piezoPin = 8;
byte ldrPin = 0;
int ldrValue = 0;

void setup() {
  Serial.begin(9600);
}

void loop() {
  ldrValue = analogRead(ldrPin);
  Serial.print(ldrValue);
  delay(25);
  noTone(piezoPin);
  delay(ldrValue);
}
```

在代码层面，还是很容易理解的。

#### 硬件回顾

项目中，接触到了一个新的概念——分压器（也叫电位分配器）。分压器是由电阻构成的。使
用两个电阻串联，从其中一个取出电压，这样可以减小进入电路的电压。

{% lazy_img lazy no-shadow /photos/fen-ya-qi.jpg 640 200 '分压器' %}

输入电压(V<sub>in</sub>)连接在两个电阻上。当测量通过一个电阻的电压(V<sub>out</sub>)
时，电压将小俞输入电压（分压）。计算 R<sub>2</sub> 两端的输出电压公式如下：

V<sub>out</sub> = R<sub>2</sub> / (R<sub>2</sub> + R<sub>1</sub>) * V<sub>in</sub>
