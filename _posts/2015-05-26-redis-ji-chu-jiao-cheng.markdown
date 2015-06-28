---
layout: post
title: "Redis 基础教程"
date: 2015-05-26 10:46:25 +0800
comments: true
categories: 技术
---
## 简介

Redis 是一个键值存储仓库，经常被称为 NoSQL 数据库。键值存储仓库的本质是有能力按
照一个键映射一个值的方式存储一些数据，然后你可以只通过这个键寻找到你之前通过这个
键存储的值。我们可以使用命令`SET`将值『fido』存储在键『server:name』中：

``` ruby
SET server:name "fido"
```

Redis 将会把我们的数据永久存储。于是，我们可以假设这样询问 Redis 数据库：键 server:name
对应的值是什么？ 然后，Redis 会返回『fido』。

```
GET server:name # => "fido"
```

下面列出了一些其他常用的命令：

+ `DEL`   根据给定的键，删除相应的键值关系
+ `SETNX` 当且仅当给定键没有指定值的时候，才设定相应的键值对
+ `INCR`  将数字递增

```
SET  connection 10
INCR connection # => 11
INCR connection # => 12
DEL  connection
INCR connection # => 1
```

## 递增

对于 `INCR` 命令，我们有一些特别的事情要说明。Redis 为什么会提供一个自己很简单就
能实现的功能呢？就像下面这么简单：

```
x = GET count
x += 1
SET count x
```

然而问题是，这种递增操作只能用于单客户端上。看一下，如果两个客户端同时执行这样
的操作会发生什么：

1. 客户端 A 读取值 x 为10
2. 客户端 B 读取值 x 为10
3. 客户端 A 写 x 的值为11
4. 客户端 B 写 x 的值为11

我们希望 x 的值为12，但是真实的 x 的值仅仅是11，这是因为你自己定义的递增操作不是
一个原子性操作。使用 Redis 的 `INCR` 命令可以防止这样的事情发生， 因为它是一个原
子性操作。Redis 为许多不同类型的数据提供了类似的原子性操作。

## 过期

Redis 可以使用命令 `EXPIRE` 和 `TTL`，能让一个键值对只存在于指定的时间段内。

```
SET resource:lock "Redis Demo"
EXPIRE resource:lock 120
```

这会导致键 resource:lock  会在120s 后被删除，你可以使用 `TTL` 去查看一个键还能存
在多少时间：

```
TTL resource:lock # => 120

# after 122s later
TTL resource:lock # => -2
```

这里的 -2 是指 resource:lock 已经不存在了，如果返回值是 -1 说明这个键永远不会过
期。注意：当你使用 `SET` 重新设置一个键， 它对应的 `TTL` 就会被重置。

```
SET resource:lock "Redis demo 1"
EXPIRE resource:lock 120
TTL resource:lock # => 119
SET resoource.lock "Redis demo 2"
TTL resource:lock # => -1
```

## 列表

此外，Redis 也支持一些更复杂的数据结构。我们第一个会看的是列表。一个列表是一系列
有序的值。与数组有关的一系列操作是：`RPUSH`, `LPUSH`, `LLEN`, `LRANGE`, `LPOP`和
`RPOP`。列表和普通的值一样，可以被直接使用。

+ `RPUSH` 将值添加到列表的末尾

```
RPUSH friends "Alice"
RPUSH friedns "Joe"
```

+ `LPUSH` 将值添加到列表的开始

```
LPUSH friends "Sam"
```

+ `LRANGE`是从列表中去一个指定范围的子集。它通过你想取的范围的第一个元素的下标和
  最后一个元素的下标作为参数。将 -1 作为参数意味着取值到列表的最后。

```
LRANGE friends 0 -1 # => 1) "Sam", 2) "Alice", 3) "Joe"
LRANGE friends 0  1 # => 1) "Sam", 2) "Alice"
LRANGE friends 1  2 # => 1) "Alice", 2) "Joe"
```

+ `LLEN` 返回指定列表的长度

```
LLEN friends # => 3
```

+ `LPOP` 从列表中删除第一个元素，并将它作为返回值

```
LPOP friends # => "Sam"
```

+ `RPOP` 从列表中删除最后一个元素，并将它作为返回值

```
RPOP friends # => "Joe"
```

注意看现在的列表：

```
LLEN friends # => 1
LRANGE friends 0 -1 # => 1) "Alice"
```

## 集合

接下来我们要看的数据结构是集合。集合和列表类似，但是集合中元素是无序且不能重复的。
和集合有关的一些重要的命令是：`SADD`, `SREM`, `SISMEMBER`, `SMEMBERS` 和 `SUNION`.

+ `SADD` 将给定的值添加到集合中

```
SADD superpowers "flight"
SADD superpowers "x-ray vision"
SADD superpowers "reflexes"
```

+ `SREM` 从集合中移除指定的值

```
SREM superpowers "reflexes"
```

+ `SISMEMBER` 检查一个值是否在集合中，返回0不在，返回1在。

```
SISMEMBER superpowers "flight" # => 1
SISMEMBER superpowers "reflexes" # => 0
```

+ `SMEMBERS` 返回集合中所有的元素

```
SMEMBERS superpowers # => 1) "flight", 2) "x-ray vision"
```

+ `SUNION` 合并两个或者更多个集合，并且将所有的元素返回。

```
SADD birdpowers "pecking"
SADD birdpowers "flight"
SUNION superpowers birdpowers # => 1) "pecking", 2) "flight", 3) "x-ray vision"
```

## 可排序集合

集合是一个非常有用的数据类型，但是因为它是无序的，所以因此会导致很多的问题。因此
Redis 1.2 开始添加了可排序集合。可排序集合和标准的集合类似，只是添加了一个分数和
集合中的元素相关联。这个分数用来给元素排序。

```
ZADD hackers 1940 "Alan Kay"
ZADD hackers 1906 "Grace Hopper"
ZADD hackers 1954 "Wang Zhi He"
ZADD hackers 1988 "Li Feng"

ZRANGE hackers 1, 3 # => 1) "Alan Kay", 2) "Grace Hopper", 3) "Wang Zhi He"
```

## 哈希表

除了字符串、列表、集合之外，Redis 还能储存一种类型的数据————哈希表。哈希表将两个
字符串类型的值映射在一起，它是最好的用来表示对象的数据结构。

```
HSET user:1000 name "John Smith"
HSET user:1000 email "john.smith@google.com"
HSET user:1000 password "public"
```

使用命令 `HGETALL` 获得保存的数据

```
HGETALL user:1000
```

我们也可以一起行设置多个域

```
HMSET user:1001 name "Zack Lee" email "zack.lee@facebook.com" password "public"
```

我们也可以只获取特定域的值：

```
HGET user:1001 name # => "Zack Lee"
```

数字类型的值在哈希表里面有一些方便的原子性的递增方法：

```
HSET user:1000 visits 10
HINCRBY user:1000 visits 1  # => 11
HINCRBY user:1000 visits 10 # => 21
HDEL    user:1000 visits
HINCRBY user:1000 visits 1  # => 1
```

关于哈希表的完整命令列表，请查看[官方文档](http://redis.io/commands#hash)

更多关于 Redis 文档:

+ [Redis官方文档](http://redis.io/documentation)
+ [命令参考](http://redis.io/commands)
+ [Redis 中数据类型介绍](http://redis.io/topics/data-types-intro)
