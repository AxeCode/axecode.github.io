---
layout: post
title: "The meta programming in Ruby"
date: 2014-11-06 10:05:34 +0800
comments: true
categories: 技术
---
The machine could be used to create new programming that
it could then execute. And that would be meta programming
--writing code that writes code.

## Base

The basement of meta programming.

###Objects and Classes

In reality, however, Ruby has just a single underline
class and object structure.

A Ruby object has three components: a set of flags, some
instance variables, and an associated class.


#### self and Method calling

`self` has two significant roles in running Ruby program.

+ `self` control how Ruby finds instance variables.
+ `self` plays a vital role in method calling. If there
  is no explicit reciever, Ruby uses `self` as default
  reciever.

Inside a class definition, `self` is set to the class
object of the class being defined.


#### Singletons

Ruby lets you define methods that are specific to a
particular object. These are called `singleton methods`.

``` ruby
animal = 'cat'
def animal.speak
  puts "The #{ self } says miaow."
end

animal.speak # => "The animal says miaow."
```

When we defined singleton method for the `animal` object，
Ruby create a new anonymous class and defined the `speak`.


#### Singletons and Classes

Newcomers to Ruby commonly make the mistake of setting
instance variables inline in the class definition and
then attempting to access these variables from instance
methods.

**Instance variables defined in the class body are
associated with the class object, not the instance
of the class.**

####Another way to access the singleton class

You can do the same thing Ruby's Class << an_object
notation.

You can't create a new instance of a singleton class.

To make `attr_accessor` work with class level instance
variables, you must have to invoke `attr_accessor` in
singleton class.


#### Inheritance and Visibility

Within a class definition, you can change the visibility
of a method in an ancestor class.

If a subclass changes the visibility of a method in a
parent, Ruby effectively inserts a hidden proxy method in
the subclass that invoke the original method using
`super`.

The call of `super` can access the parent's methods
regardless of its visibility.


### Modules and Mixins

The module that you include is effectively added as a
superclass of the class being defined.

When you include a module in class `Example`, Ruby Constructs
a new class object, makes it the superclass of `Example`,
and then set the superclass of the new class to be the
original superclass of `Example`.

Ruby will include a module only **once** in a
inheritance chain.


#### prepend

> New feature in 2.0

If a method inside a prepended module has the same name
as one in the original class, it will be invoked instead
of the original. The prepended module can then call the
original using `super`.


#### extend

Add the instance methods to a particular object.If you
use it in a class definition, the module's methods
become class methods.


#### Refinements

> New feature in 2.0

A refinement is a way of packaging a set of changes to
one or more classes. These refinements are defined
within a module.


### Meta programming Class-Level Macros

Because of the way they expand into something bigger,
folks sometimes call these kinds of methods `macros`.

A `class method` is defined in the class object's
singleton class. That means we can call it later in the
class definition without an explicit receiver.

Use `define_method` to define a log method on the fly.

``` ruby
class Logger
  def self.add_logging(id_string)
    define_method(:log) do |msg|
      now = Time.now.strftime("%H:%M:%S")
      STDERR.puts "#{ now }-#{ id_string }: #{ self } #{ msg }"
    end
  end
end

class Song < Logger
  add_logging('Tune')
end
```

As well as passing parameters from the class method into
the body of the method being defined, we can also use
the parameter to determine the name of the method or
methods to create.

``` ruby
class AttrLogger
  def self.attr_logger(name)
    attr_reader name

    define_method("@#{ name }=") do |val|
      puts "Assigning #{ val.inspect } to #{ name }"
      instance_variable_set("@#{ name }", val)
    end
  end
end
```

We use `instance_variable_set` to set the value of an
instance variable. There's a corresponding `_get` method
that fetches the value of a named instance variable.


#### Class Methods And Modules

You can use module to hold your meta programming
implementation. In this case, using `extend` inside a
class definition will add the methods in a module as
class methods to the class being defined.

``` ruby
module AttrLogger
  def attr_logger(name)
    attr_reader name

    define_method "@#{ name }" do |val|
      puts "Assigning #{ val.inspect }" to #{ name }
      instance_variable_set "@#{ name }", val
    end
  end
end

class Example
  extend AttrLogger

  attr_logger :value
end
```

Here's one technique, make us to add both class methods
and instance methods into the class being defined.

``` ruby
module GeneralLogger
  module ClassMethods
    def attr_logger(name)
      attr_reader name

      define_method "#{ name }=" do |val|
        puts "Assigning #{ val.inspect } to #{ name }"
        instance_variable_set "@#{ name }", val
      end
    end
  end

  module InstanceMethods
    def log(msg)
      puts Time.now.strftime("%Y-%m-%d %H:%M:%S " + msg)
    end
  end

  def self.included(receiver)
    receiver.extend         ClassMethods
    receiver.send :include, InstanceMethods
  end
end

class Example
  include GeneralLogger

  attr_logger :name
end

ex = Example.new
ex.log "A new Example created."
# => 2014-10-31 08:56:56 A new Example created.

ex.name = "Yuez"
# => Assigning "Yuez" to name

ex.name = "Lucky"
# => Assigning "Lucky" to name
```


#### Creating Singleton Class

Use `Class#new` directly to create a singleton class. By
default this class will be direct decendent of `Object`.
You can give them a different parent by passing the
parent's class as a parameter.


### instance\_eval and class\_eval

+ `Object#instance_eval`
+ `Module#class_eval`
+ `Module#module_eval`

`instance_eval` and `class_eval` both set `self` for the
duration of the block. However, they differ in the way
they set up the environment for method definition.
`class_eval` sets things up as if you were in the body
of a class definition.

In contrast, calling `instance_eval` on a class acts as
if you were working inside the singleton class of `self`

Ruby has variants of these methods.

+ `Object#instance_exec`
+ `Module#class_exec`
+ `Module#module_exec`

behave identically to there `_eval` counterparts but take
only a block(they do not take a string).


### Hook Methods

`included` is an example of a *hood method* (sometime
  called a *callback*). A hook method is a method that
  you write but that Ruby calls from within the interpreter
  when some particular events occurs.

  The interpreter looks for these methods by name--if
  you define a method in the right context with an
  appropriate name, Ruby will call it when the corresponding
  event happens.

  The methods that can be invoked from within the
  interpreter are:

+ Method related hooks.

  `method_added`, `method_missing`,  `method_removed`,
  `method_undefined`, `singleton_method_added`,
  `singleton_method_removed`, `singleton_method_undefined`

+ Class and module related hooks.

  `append_features`, `const_missing`, `extend_object`,
  `extended`, `included`, `inherited`,
  `initialize_clone`, `initialize_coty`,
  `initialize_dup`

+ Object marshaling hooks.

  `marshal_dump`, `marshal_load`

+ Coercion hooks.

  `coerce`, `included_from`, `to_xxx`
