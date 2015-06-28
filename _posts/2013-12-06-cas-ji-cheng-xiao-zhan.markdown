---
layout: post
title: "CAS 集成小战"
date: 2013-12-06 11:32:25 +0800
comments: true
categories: 技术
---
> 近来，项目中需要整合单点登录系统。按照项目要求，工程中原先的单点登录无法完成任务，需要重新加工。于
> 是选用[JA-SIG](http://www.jasig.org/)的`CAS`系统整合项目中。

在这开始之前需要明白什么是单点登录。

### 什么是单点登录系统

在企业中，随着系统中使用工程数量的增加，一个显而易见的问题就出现在眼前——在各个系统之间切换时，总是需要频繁的切换登陆，这浪费了大量的时间，严重降低了用户体验。于是我们需要一套方案可以使得一名信任用户在A系统登录之后，在B、C等系统中也将被视为已登录用户，从而避免重复登录。

我们都知道，在游玩公园时，只需要在售票处购买一张门票，就可以游玩公园内的所有景点而不需要在每个景点前重复购票。单点登录系统也好比这样，设置一个所有系统的统一入口，当用户登录之后，生成一个Ticket交给这名用户，随后用户携带这个Ticket访问各个系统，验证Ticket合法后，即可认为该用户已经登录。

#### Ticket储存

+ Cookie-based
+ Broker-based
+ Agent-based
+ Token-based
+ Agent and Broker-based
+ SAML. SAML(Security Assertion Markup Language，安全断言标记语言）的出现大大简化了SSO，并被OASIS批准为SSO的执行标准。开源组织OpenSAML 实现了SAML规范。

在集成CAS系统之前，还需要为开启TOMCAT的SSL功能，并且是使用`keytool`生成安全证书，导入安全证书。

### 开启SSL

[keytool api](http://docs.oracle.com/javase/6/docs/technotes/tools/solaris/keytool.html "keytool api")

1. 创建keystore

``` bash
keytool -genkey -alias Example -keyalg RSA -validity 3600 -keystore example.keystore -storepass changeit
```

**CN需要与你访问的域名相同**

2. 导出crt

``` bash
keytool -export -alias Example -file example.crt -keystore example.keystore -storepass changeit
```

3. 将crt导出Java证书库中($JAVA_HOME/jre/lib/security/cacerts)

``` bash
keytool -import -alias Example -file example.crt -keystore $JAVA_HOME/jre/lib/security/cacerts
```

4. 配置tomcat的server.xml文件，开启ssl

``` xml
<Connector port="8443" protocol="HTTP/1.1" SSLEnable="true"
    maxThreads="150" scheme="https" secure="true"
    clientAuth="false" sslProtocol="TLS"
    keystoreFile="PATH/TO/KEYSTORE"
    keystorePass="changeit"
    truststoreFile="$JAVA_HOME/jre/lib/security/cacerts"
    truststorePass="changeit" />
```

这时，运行tomcat，访问`https://localhost:8443`如果在浏览器窗口出现安全锁，即已经成功打开tomcat的ssl功能。

以上准备工作完成之后，就可以开始将CAS系统集成到我们的项目中了

------------------------------------------------------------------------------------------------

需要集成进系统中的CAS又是什么呢？

### 简介CAS

*CAS Version 3.5.2， CAS Client Version 3.1.10*

[CAS User Manual](https://wiki.jasig.org/display/CASUM/Home "CAS User Manual")

CAS是一套由耶鲁大学开发的企业级单点登录服务。

+ 公开、文档式协议
+ 开源Java Server容器
+ 客户端支持JAVA、.NET、PHP、Perl、Apache等集成
+ 社区型文档
+ 大型讨论社区

这次集成的目标是基于JDBC数据库验证。如果需要其他验证方式，请参看用户手册。CAS的配置分为客户端和服务器端，先从客户端的配置开始。


### CAS客户端配置

客户端即我们需要集成的系统。

添加cas-client-core.jar文件

``` xml
<dependency>
    <groupId>org.jasig.cas</groupId>
    <artifactId>cas-client-core</artifactId>
    <version>3.1.10</version>
</dependency>
```

在`web.xml`文件中添加`CAS Authentication Filter`和`CAS Validation Filter`，具体配置如下：

``` xml
<filter>
    <filter-name>CAS Authentication Filter</filter-name>
    <filter-class>org.jasig.cas.client.authentication.AuthenticationFilter</filter-class>
    <init-param>
        <param-name>casServerLoginUrl</param-name>
        <param-value>https://exmaple.com:8443/cas/login</param-value>
    </init-param>
    <init-param>
        <param-name>serverName</param-name>
        <param-value>http://example.com:8080</param-value>
    </init-param>
</filter>
<filter>
    <filter-name>CAS Validation Filter</filter-name>
    <filter-class>org.jasig.cas.client.validation.Saml11TicketValidationFilter</filter-class>
    <init-param>
        <param-name>casServerUrlPrefix</param-name>
        <param-value>https://exmaple.com:8443/cas</param-value>
    </init-param>
    <init-param>
        <param-name>serverName</param-name>
        <param-value>http://example.com:8080</param-value>
    </init-param>
    <init-param>
        <param-name>redirectAfterValidation</param-name>
        <param-value>true</param-value>
    </init-param>
    <init-param>
        <param-name>useSession</param-name>
        <para-value>true</param-value>
    </init-param>
</filter>
<filter-mapping>
    <filter-name>CAS Authentication Filter</filter-name>
    <url-pattern>/*</url-pattern>
</filter-mapping>
<filter-mapping>
    <filter-name>CAS Validation Filter</filter-name>
    <url-pattern>/*</url-pattern>
</filter-mapping>
```

这些配置是使用CAS的最小配置，Validation
Filter可以有多种，如果需要使用使用其他Filter可以参考用户手册。在这里使用
`Saml11TicketValidatioFilter`是为了在CAS验证登陆的时候在`HttpServletRequest`
中添加更多可以使用的用户信息（从数据库中取出来的）

客户端的配置就这样完成了，很简单吧。下面进入服务器端的配置。

### 服务器端配置

服务器端即CAS Server

为了支持集成jdbc验证，需要添加jar文件

``` xml
<dependency>
    <groupId>org.jasig.cas</groupId>
      <artifactId>cas-server-support-jdbc </artifactId>
      <version>${cas.version} </version>
  <dependency>
```

服务器端的配置集中在`deployerConfigContext.xml`文件中。

首先配置`authenticationHandlers`，这里支持配置多个handler，使用多种验证方式。我们只用jdbc一种。

在list中添加bean

``` xml
<bean class="org.jasig.cas.adaptors.jdbc.QueryDatabaseAuthenticationHandler"
    p:dataSource-ref="dataSource"
    p:passwordEncoder-ref="passwordEncoder"
    p:sql="select password from T where username = ?"/>
```

**list中有一个simpleAuthenticationHanlder需要删除，它是测试时使用，只要用户名密码相同即通过验证**

其中dataSource为必须属性。passwordEncoder是可选属性，它表示了密码的加密方式，CAS提供MD5和SHA1两种，当然你也可以自定义你的加密方式——实现org.jasig.cas.authentication.handler.PasswordEncoder接口。看了上面的配置很清楚的就知道了还需要配置dataSource和passwordEncoder。

``` xml
<bean id="dataSource" class="org.apache.commons.dbcp.BasicDataSource"
    p:driverClassName="org.postgresql.Driver"
    p:url="jdbc:postgresql://127.0.0.1:5432/exmaple_db"
    p:username="foo"
    p:password="bar"/>
<bean id="passwordEncoder" class="org.jasig.cas.authentication.Handler.DefaultPasswordEncoder"
    p:characterEncoding="UTF-8">
    <constructor-arg index="0" value="MD5"/>
</bean>
```
以上，我们所需要的最低配置就已经完成了。如果在启动的时候报一些NoSuchMethod之类的错误，请检查jar是否有所缺失。

### 总结

`CAS`是一个异常强大的单点登录系统。以上使用的都只是其中最基本的功能。如果需要使用更高级的功能，请参考用户手册0 0.)
