---
layout: post
title: "HTTP 协议解析"
date: 2013-11-21 11:15:21 +0800
comments: true
categories: 技术
---
从进入软件开发至今，也做了几个关于Web的应用。对于HTTP协议的理解不足让我吃到了不少的苦头，也曾在看到某一项解释之后一拍脑门：
原来是这样的，原来还能那么做。就从经典的3W理论（What, How,
Why）来深入一下HTTP，看看这个HTTP到底是个什么玩意。 

******
### 戳破HTTP协议的面纱

> 超文本传输协议（英文：HyperText Transfer
> Protocol，缩写：HTTP）是互联网上应用最为广泛的一种网络协
   议。设计HTTP最初的目的是为了提供一种发布和接收HTML页面的方法。通过HTTP或者HTTPS协议请求的资源由
   统一资源标识符（Uniform Resource Identifiers，URI）来标识。
   *来自[维基百科](http://zh.wikipedia.org/wiki/超文本传输协议)*

通常，由HTTP客户端发起一个请求，创建一个指向到服务器某个特定端口（默认是80）的
TCP连接，例如：`http://localhost:3000` 即创建一个指向本地3000端口的TCP连接。一旦服
务器端收到请求，会向客户端返回一个状态码，以及返回客户端请求的内容。

> HTTP状态码（英语：HTTP Status
> Code）是用以表示网页服务器HTTP响应状态的3位数字代码。它由RFC 
   2616规范定义的，并得到RFC 2518、RFC 2817、RFC 2295、RFC 2774、RFC 4918等规范扩展。
   *来自[维基百科](http://zh.wikipedia.org/wiki/HTTP状态码)*

所有的状态码的第一个数字代表了响应的五种状态之一

+ 1xx：代表请求已被接受，需要继续处理。这类响应是临时响应，只包含状态行和某些可选的响应头信息，并以空行
   结束。
+ 2xx：代表请求接收、理解并且接受。
+ 3xx：代表需要客户端采取进一步的操作才能完成请求。通常，这些状态码用来重定向，后续的请求地址（重定向目
   标）在本次响应的Location域中指明。当且仅当后续的请求所使用的方法是GET或者HEAD时，用户浏览器才可以
   在没有用户介入的情况下自动提交所需要的后续请求。
+ 4xx：代表了客户端看起来可能发生了错误，妨碍了服务器的处理。除非响应的是一个HEAD请求，否则服务器就应
   该返回一个解释当前错误状况的实体，以及这是临时的还是永久性的状况。
+ 5xx：代表了服务器在处理请求的过程中有错误或者异常状态发生，，也有可能是服务器意识到以当前的软硬件资源
   无法完成对请求的处理。

#### HTTP常见状态码

<table class="table">
  <tr><td>200<td><td>请求已经成功，请求所希望的响应头或者数据体将随着此响应返回</td></tr>
  <tr><td>202<td><td>服务器已接受请求，但尚未处理。正如它可能被拒绝一样，最终该请求可能会也可能不会被执行。在异步操作的场合下，没有比发送这个状态码更方便的做法了</td></tr>
  <tr><td>204<td><td>服务器成功处理了请求，但不需要返回任何实体内容，并且希望返回更新了的元信息</td></tr>
  <tr><td>304<td><td>被请求的资源内容没有发生更改</td></tr>
  <tr><td>400<td><td>包含语法错误，无法被服务器解析</td></tr>
  <tr><td>403<td><td>服务器已经接收请求，但是拒绝执行</td></tr>
  <tr><td>404<td><td>请求失败，请求所希望得到的资源未在服务器上发现</td></tr>
  <tr><td>408<td><td>请求超时。客户端可以再次提交这一请求而无需任何修改</td></tr>
  <tr><td>500<td><td>服务器内部错误，无法处理请求</td></tr>
  <tr><td>502<td><td>作为网关或者代理工作的服务器尝试执行请求时，从上游服务器接收到无效响应</td></tr>
  <tr><td>504<td><td>作为网关或者代理工作的服务器尝试执行请求时，未能及时从上游服务器（URI标识出的服务器，例如HTTP、FTP、LDAP）或者辅助服务器（例如DNS）收到响应</td></tr>
</table>

####请求信息

发出的请求信息包括以下几种：

+ 请求行（GET /images/logo.gif HTTP/1.1）
+ 头(Accept-Language:en)
+ 空行
+ 其他消息体

请求行和标题必须以<CR><LF>作为结尾。空行内必须只有<CR><LF>而无其他空格。在HTTP/1.1协议中，所有的请求头，除Host外，都是可选的。

HTTP URL的格式如下：
**http://host[":"port][abs_path]**

#### 请求方法

HTTP/1.1协议中定义了八种方法来以不同的方式操作指定的资源：

+ OPTIONS：这个方法可使服务器传回该资源所支持的所有HTTP请求方法。
+ HEAD：与GET方法一样，都是向服务器发出指定资源的请求。只不过服务器将不传回资源的本文部份。它的好处在
   于，使用这个方法可以在不必传输全部内容的情况下，就可以获取其中“关于该资源的信息”（元信息或称元数据）。
+ GET：读取指定资源数据。
+ POST：向指定资源提交数据，请求服务器进行处理。
+ PUT：向指定位置上传其最新内容。
+ DELETE：请求服务器删除REQUEST-URI所标识的资源。
+ TRACE：回显服务器收到的请求，主要用于测试或诊断。
+ CONNECT：HTTP/1.1协议中预留给能够将连接改为管道方式的代理服务器。通常用于SSL加密服务器的链接（经       
   由非加密的HTTP代理服务器）。
+ 此外，除了上述方法，特定的HTTP服务器还能够扩展自定义的方法。

******

#### 消息报头

HTTP头字段包括四类：

+ General-header
+ Request-header
+ Response-header
+ Entity-header

**General Header Fields**
有少数报头用于所有的请求和响应消息，但是不用与被传输的实体，只用于传输的消息。

+ Cache-Control：用于指定缓存指令，缓存指令是单向且独立的。HTTP1.0中使用的报头域为Pragma。
  + 请求时指令：no-cache, no-store, max-age, max-stale, min-fresh, only-if-cached
  + 响应时指令：public, private ,no-cache, no-store, no-transform, must-revalidate, proxy-revalidate, max-age, s-maxag
+ Date：表示消息产生的时间和日期。
+ Connection：允许发送指定连接的选项。此header的含义是当client和server通信时对于长链接如何进行处理。
    如果client使用http1.1协议，但又不希望使用长链接，则需要在header中指明connection的值为close。
+ 不常用：Trailer, Transfer-Encoding, Upgrade, Via, Warning

**Request Header Fields**
请求报头允许客户端向服务器端传递请求的附加信息以及客户端自身的信息。

+ Accept：指定客户端接收哪些类型的消息。例如：Accept: image/gir，表明客户端接收GIF图像格式资源。
+ Accept-Charset：指定客户端接收的字符类型。缺省接收所有字符类型。
+ Accept-Encoding：指定客户端可接收的内容编码。
+ Accept-Language：指定客户端接收的自然语言。
+ Authorization：用于证明客户端有权限查看某个资源。当浏览器访问一个页面时，如果收到服务器的响应代码为
   401（未授权），可以发送一个包含Authorization请求报头域的请求，要求服务器对其进行验证。
+ Host：指定被请求资源的主机和端口号，通常从HTTP URL中提取出来。
+ User-Agent：允许客户端将它的操作系统、浏览器和其他属性告诉服务器。不过，这个报头域不是必需的，如果我
   们自己编写一个浏览器，不使用User-Agent请求报头域，那么服务器端就无法得知我们的信息了。
+ 不常用：Expect, From, If-Match, If-Modified-Since, If-None-Match, If-Range, If-Unmodified-Since, Max-Forwards, Proxy-Authorization, Range, Referer, TE

典型的请求信息：

``` http
Accept: text/html, application/xhtml+xml;q=0.9,image/webp,*/*;q=0.8
Accept-Encoding:gzip,deflate,sdch
Accept-Language:zh-CN,zh;q=0.8,en;q=0.6,zh-TW;q=0.4
Connection:keep-alive
Cookie:connect.sid=s%3AdF5CuLecykHstAVmBnliuGmx.qyOANqn7nqe8rAZEVgPwpAgc2pKkfWgtnhNg7A1CWp0
Host:yuez.me  
If-None-Match:"761947465"
Referer:http://yuez.me/
User-Agent:Mozilla/5.0 (X11; Linux i686) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/31.0.1650.48 Safari/537.36
```

**Response Header Fields**

响应报头允许服务器传递不能放在状态中的附加响应信息，以及服务器的信息和对Request-URL所标识资源进行下一步访问的信息。

+ Location：重定向接收者到一个新的位置。Location常用在更换域名的时候。
+ Server：Server响应报头域包含了服务器用来处理请求的软件信息。与User-Agent请求报头域是相对应的。
+ 不常用：Accept-Rangers, Age, ETag, Proxy-Authenticate, Retry-After, Vary, WWW-Authenticate

典型的响应信息：

``` http
Connection:keep-alive
Date:Thu, 21 Nov 2013 13:57:59 GMT
ETag:"761947465"
Server:nginx/1.1.19
X-Powered-By:Express
```

**Entity Header Fields**    
请求和响应消息都可以传送一个实体，一个实体由实体报头域和实体正文组成，但不是说实体报头域要和实体正文一起发送，可以只发送实体报头域。实体报头定义了实体正文和请求所标识的资源的元信息。

+ Content-Encoding：指示已经被应用到实体正文中的附加内容编码。因而要获得Content-Type报头域中所引用
   的媒体类型，必须采用相应的解码机制。
+ Content-Language：描述了资源所用的自然语言。
+ Content-Length：指明实体正文的长度，以字节方式储存的十进制数字来表示。
+ Content-Type：指明发送给接收着实体正文的媒体类型。
  + [Content-Type常用对照表](http://tool.oschina.net/commons)
+ Last-Modified：指示资源最后修改的日期和时间。
+ Expires：给出响应过期的日期和时间。
+ 不常用：Allow, Content-Location, Content-MD5, extension-header

TO BE CONTINUE
