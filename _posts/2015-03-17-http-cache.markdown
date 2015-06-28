---
layout: post
title: "HTTP Cache"
date: 2015-03-17 21:01:48 +0800
comments: true
categories: 技术
---

使用缓存的优点：

+ 减少了冗余的数据传输
+ 缓解了网络瓶颈
+ 降低了对原始服务器的要求
+ 降低了距离时延

### 再验证

HTTP为我们提供了几个用来对已缓存对象进行再验证工具，但最常用的是
`If-Modified-Since`首部。

+ 再验证命中，返回`304 Not Modified`响应。
+ 再验证未命中，服务器返回普通的，带有完整内容的`200 OK`响应。
+ 对象被删除，返回`404 Not Found`响应。

### 缓存的处理步骤

1. 接收——缓存从网络中读取抵达的请求报文。
2. 解析——缓存对报文进行解析，提取出URL和各种首部。
3. 查询——缓存查看是否有本地副本可用，如果没有，就获取一份副本（并将其保存在本
   地）。
4. 新鲜度检测——缓存查看已缓存的副本是否足够新鲜，如果不是，就询问服务器是否有
   任何更新。
5. 创建响应——缓存会用辛的首部和已缓存的主体来构建一条响应报文。
6. 发送——缓存通过网络将响应发送回给客户端。
7. 日志——缓存可选地创建一个日志文件条目来描述这个事务。

### 保持副本的新鲜度

+ **文档过期**。通过特殊的HTTP `Cache-Control`首部和`Expires`首部。
+ **服务器再验证**。HTTP定义了五个条件请求首部。对缓存再验证来说最有用的两个
  首部是`If-Modified-Since`和`If-None-Match`。

### 控制缓存的能力

服务器可以通过HTTP定义的几种方式来指定在文档过期之前可以将其缓存多长时间。

+ `Cache-Control: no-store`
+ `Cache-Control: no-cache`
+ `Cache-Control: must-revalidate`
+ `Cache-Control: max-age`
+ `Expires`
+ 不附加过期信息，让缓存确定自己的过期日期。

#### no-store和no-cache响应首部

可以防止缓存提供未经证实的已缓存对象：

``` perl
Pragma: no-cache
Cache-Control: no-store
Cache-Control: no-cache
```

#### max-age响应首部

表示从服务器将文档传输来之时起，可以认为此文档处于新鲜期的秒数。

``` perl
Cache-Control: max-age=3600;
Cache-Control: s-maxage=3600;
```

将最大使用期限设置为0则不进行缓存。

#### Expires响应首部

不推荐使用。

#### must-revalidate响应首部

在事先没有跟原始服务器进行再验证的情况下，不能提供这个对象陈旧的副本。

``` perl
Cache-Control: must-revalidate
```

#### 试探性过期

如果响应中没有`Cache-Control: max-age`首部，也没有`Exprires`首部，缓存可以计
算出一个试探性最大使用期。可以使用任意算法，如果得到的最大使用期大于24小时,
就应该向响应首部添加一个Heuristic Expiration Warning首部。

LM-Factor算法是一种常用的试探性过期算法，如果文档中包含了最后修改日期，就可以
使用这种算法。算法逻辑如下：

+ 如果已缓存的文档最后一次修改发生在很久以前，它可能会是一份稳定的文档，不太
  会突然发生变化，因此将其继续保存在缓存中会比较安全。

+ 如果已缓存的文档最近被修改过，就说明它很可能会频繁地发生变化，因此在与服务
  器进行再验证之前，只应该将其缓存很短的一段时间。

``` perl
$time_since_modify      = max(0, $server_Date - $server_Last_Modified);
$server_freshness_limit = int($time_since_modify * $lm_factor);
```

### 设置缓存控制

Apache Web服务器提供了几种设置HTTP缓存控制首部的机制。其中很多机制在默认情况
下都没有启动。

+ mod\_headers

``` apache
<Files *.html>
  Header set Cache-control no-cache
</Files>
```

+ mod\_expires


``` perl
ExpiresDefault A3600
ExpiresDefault M86400
ExpiresDefault "access plus 1 week"
ExpiresByType text/html "modification plus 2 days 6 hours 12 minutes"
```

+ mod\_cern\_meta

#### 通过HTTP-EQUIV控制HTML缓存

为了让作者在无需与Web服务器的配置文件进行交互的情况下，能够更容易地为所提供的
HTML文档分配HTTP首部信息，HTML2.0定义了`<META HTTP-EQUIV>`标签。

``` html
<html>
  <head>
    <title>My document</title>
    <meta http-equiv="cache-control" content="no-cache">
  </head>
</html>
```

### 详细算法

对HTTP的新鲜度计算算法进行详细的讨论，并对此算法动机进行解释。

#### 使用期和新鲜生存期

``` perl
$is_fresh_enough = ($age < $freshness_lifetime);
```

#### 使用期的计算

响应的使用期就是服务器发布响应（活服务器对其进行了再验证）之后经过的总时间。

``` perl 使用期计算的伪代码
# 使用期计算的伪代码
$apparent_age = max(0, $time_got_response - $Date_header_value);
$corrected_apparent_age = max($apparent_age, $Age_header_value);
$response_delay_estimate = ($time_got_response - $time_issued_request);
$age_when_document_arrived_at_our_cache =
    $correncted_apparent_age + $response_delay_estimeate;
$how_long_copy_has_been_in_our_cache =
    $current_time - $time_got_response;
$age = $age_when_document_arrived_at_our_cache +
    $how_long_copy_has_been_in_our_cache;
```

#### 完整的服务器新鲜度算法

``` perl 服务器新鲜度限制计算算法
## 服务器新鲜度限制的计算
sub server_freshness_limit
{
  local($heuristic, $server_freshness_limit, $time_since_last_modify);

  $heuristic = 0;

  if ($Max_Age_value_set)
  {
    $server_freshness_limit = $Max_Age_value;
  }
  elseif ($Expires_value_set)
  {
    $server_freshness_limit = $Expires_value - $Date_value;
  }
  elseif ($Last_Modified_value_set)
  {
    $time_since_last_modify = max(0, $Date_value - $Last_Modified_value);
    $server_freshness_limit = int($time_since_last_modify * lm_factor);
    $heuristic = 1;
  }
  else {
    $server_freshness_limit = $default_cache_min_lifetime;
    $heuristic = 1;
  }

  if ($heuristic)
  {
    if ($server_freshness_limit > $default_cache_max_lifetime)
    {
      $server_fresh_limit = $default_cache_max_lifetime;
    }
    if ($server_freshness_limit < $default_cache_min_lifetime)
    {
      $server_fresh_limit = $default_cache_min_lifetime;
    }
  }

  return ($server_freshness_limit);
}

## 客户端新鲜度限制的计算
sub client_modified_freshness_limit
{
  $age_limit = server_freshness_limit();

  if ($Max_Stale_value_set)
  {
    if ($Max_Stale_value == $INT_MAX)
    {
      $age_limit = $INT_MAX;
    }
    else
    {
      $age_limit = server_freshness_limit() + $Max_Stale_value;
    }
  }

  if ($Min_Fresh_value_set)
  {
    $age_limit = min($age_limit, server_freshness_limit() -
        $Min_Fresh_value_set);
  }

  if ($Max_Age_value_set)
  {
    $age_limit = min($age_limit, $Max_Age_value);
  }
}
```
