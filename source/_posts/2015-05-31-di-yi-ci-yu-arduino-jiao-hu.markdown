---
layout: post
title: "第一次与 Arduino 交互"
date: 2015-05-31 21:01:21 +0800
comments: true
categories: Arduino
---
这是一个比较简单的实验，不过好歹也是让 Arduino 接受外界电子元件的输入值了。这是
套互动交通灯的实验，Arduino 等待行人按下按钮，这样行车灯会变红，行人灯会变绿。

## 需要的电子元件

+ LED 灯（2红，2绿，1黄）
+ 100Ω 电阻
+ 10KΩ 高阻值电阻（用于下拉电阻）
+ 按钮（有时供应商称之为微动开关）
+ 面包板与导线

## 代码回顾

``` c
int carRed    = 12;
int carGreen  = 10;
int carYellow = 11;

int pedRed    =  8;
int pedGreen  =  9;

int buttonPin =  2;

int crossTime = 5000;
unsigned long changeTime; // Time of press button

void setup() {
  pinMode(carRed,    OUTPUT);
  pinMode(carGreen,  OUTPUT);
  pinMode(carYellow, OUTPUT);

  pinMode(pedRed,    OUTPUT);
  pinMode(pedGreen,  OUTPUT);

  pinMode(buttonPin, INPUT);

  digitalWrite(carGreen, HIGH);
  digitalWrite(pedRed, HIGH);
}

void loop() {
  int state = digitalRead(buttonPin);

  if (state == HIGH && (millis() - changeTime) > 5000)
    changeLights();
}

void changeLights() {
  digitalWrite(carGreen, LOW);
  digitalWrite(carYellow, HIGH);
  delay(2000);

  digitalWrite(carYellow, LOW);
  digitalWrite(carRed, HIGH);
  delay(1000);

  digitalWrite(pedRed, LOW);
  digitalWrite(pedGreen, HIGH);
  delay(crossTime);

  for (int i = 0; i < 10; i ++) {
    digitalWrite(pedGreen, HIGH);
    delay(250);
    digitalWrite(pedGreen, LOW);
    delay(250);
  }

  digitalWrite(pedRed, HIGH);
  delay(500);

  digitalWrite(carYellow, HIGH);
  digitalWrite(carRed, LOW);
  delay(1000);
  digitalWrite(carGreen, HIGH);
  digitalWrite(carYellow, LOW);

  changeTime = millis();
}
```

这次使用了一个能存储大数字的数据类型

``` c
unsigned long chageTime;
```

由于 Arduino 使用的 Atemga 32 只有很小的内存，所以合理分配与使用内存在这之上就显
得非常重要。

接下来就是让 Arduino 读取按钮输出值了，

``` c
pinMode(buttonPin, INPUT);
```

这句代码让 Arduino 将按钮所在的引脚设置为 `Input` 模式。在程序循环中，使用

``` c
int state = digitalRead(buttonPin);
```

来检查引脚的状态。

## 硬件回顾

本次与 Arduino 交互的元件是按钮，或者叫开关。按钮不是之间连接在电源线和引脚之间
的，在按钮和地之间有一个电阻，这个电阻叫**下拉电阻**。对应的还有**上拉电阻**，它
们对保证按钮正常工作是非常重要的。

#### 逻辑状态

**逻辑电路**是一种只有开、关两种状态的电路，用布尔数0和1表示。电路处于关状态时，
输出端的电压接近0V。电路处于开状态时用高电平表示，输出端接近于电源供电电压。

如果不能确定状态接近所需要的电压，这部分电路可以被认为是**浮动的**（既不是高电平
，也不是低电平。），这种浮动也被称为电子噪声。电子噪声被随即的解释为0或者1。

上拉电阻或下拉电阻可用来保证状态确定为高或低。

#### 下拉电阻

如左图：

{% lazy_img lazy no-shadow /photos/dianzu.png 640 200 下拉电阻和上拉电阻 %}

如果按钮被按下，电流以电阻最小的路径在5V 端与输入引脚之间流过。 当按钮没有被按下
时，输入引脚通过100KΩ 电阻接地。如果没有这个电阻，当按钮没有被按下时，这个引脚将
不连接任何东西，因此它的电压是在 0V 和 5V 之间浮动。在这个电路中，当按钮没有被按
下输入将总是接地的，或者是0V，当按钮被按下时它将指向5V端。

#### 上拉电阻

如右图：

{% lazy_img lazy no-shadow /photos/dianzu.png 640 200 下拉电阻和上拉电阻 %}

交换下拉电阻和开关的位置，现在电阻变成了上拉电阻。当按钮没有被按下时，输入引脚通
过上拉电阻接到5V端，所以引脚上总是高电平。当按钮被按下时，通过限流电阻的路径引脚
接地，所以引脚被拉向地或者低电平状态。如果没有5V端和地之间的电阻，电路将被短路，
这将损坏电路或电源。上拉电阻在数字电路中应用更广泛。

上拉电阻在数字电路中经常用来保证输入保持高电平。

#### Arduino 内部的上拉电阻

 Arduino 内部包含了上拉电阻。它连接在引脚上，阻值为20KΩ，使用时需要通过软件激活。

``` c
pinMode(pin, INPUT);
digitalWrite(pin, HIGH);
```

同理，当一个输出脚为 HIGH 时，转换这个引脚到 INPUT 模式，那么内部上拉电阻将激活。

## 电位计与从模拟引脚读值

#### 电位计

电位计就是一个可调节电阻，调解范围从0到一个设定的值。电位计有三个引脚。若只连接
两个引脚，电位计可变为一个可变电阻。通过连接三个引脚，并为其提供电压，它将称为
一个分压器。

电位计提供了一种在0和设定的最大值之间调整数值的方法。

#### 模拟引脚读值

Arduino有6个模拟输入/输出引脚，每个引脚带有一个10位模/数转换器。这意味着模拟引脚
能够读取0V 到 5V之间的电压，用0到1023之间的正数代表0V 到 5V之间的电压。每个分度
表示 5V / 1024 电压，即每个分度是4.9mV。

通过直接读取电位计引脚数值到ledDelay这个变量中：

``` c
byte potPin = 2; // 电位计连接到的模拟引脚
int ledDelay = analogRead(potPin);
```

注意：模拟引脚不需要像数字引脚一样设置输入或输出模式。
