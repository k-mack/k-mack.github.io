---
title: "Groovy's @CompileStatic and Methods with the Same Name"
date: 2021-11-06T13:30:00-07:00
tags: ["groovy", "java", "metaprogramming"]
---

Application programming interfaces (APIs) can get whacky,
but compiled languages help users to get things semantically correct.
And dynamic languages?
Their ergonomic "dynamic sauce" ladled over a codebase can sometimes be less than helpful.
This post is about how Groovy's `@CompileStatic` can help to demystify what is happening at the call site of a method that has the same name and descriptor as another.

<!--more-->

## Part I: The Java API

Let's start with what we know we cannot do in Java:
No two methods in one class file may have the same name and descriptor.[^1]
The Java compiler simply does not let us do the following:

```java
public class MyClass {
  public String something() {}
  public static String something() {}
}
```

When the above class is compiled, an error message complaining that method `static void something()` is already defined.

```shell_session
$ echo "public class MyClass{\n public String something(){}\n public static String something(){}\n}" > /tmp/MyClass.java          
$ "$JDK11_HOME"/bin/javac /tmp/MyClass.java
/tmp/MyClass.java:3: error: method something() is already defined in class MyClass
  public static String something() {}
                     ^
1 error
```

Java 8 updated the language to permit interfaces to have static methods,
so we can update our API such that it has a concrete class with an instance and a static method that use the same name and descriptor.
I would not say this is a common thing to see in an API, but I have seen it.
In fact, this post is based on my experience with using one :).

Let's refactor the above class to use interfaces to give the impression that it has two methods with the same name and descriptor.
One interface will define `String something()`;
another interface will define `static String something()`;
and a concrete class will implement the two interfaces.
The concrete class will compile because it actually no longer has `static String something()` as part of its implementation.
When calling the static method, it must be through the interface, not the concrete class, because _the static method is part of the interface_.
The code for these three files is below.

```java
// InterfaceWithSomething.java
public interface InterfaceWithSomething {
  String something();
}

// InterfaceWithStaticSomething.java
public interface InterfaceWithStaticSomething {
  static String something() {
    return "Interface's static method";
  }
}

// Implementation.java
public class Implementation implements InterfaceWithSomething, InterfaceWithStaticSomething {
  @Override
  public String something() {
    return "Implementation's instance method";
  }
}
```

We will use the above classes as our Java API.
Let's get groovy.

## Part II: The Groovy App

Since the JVM is our development platform, we can mix JVM languages.
Let's use our Java API in some Groovy code.

```groovy
// GroovyCode.groovy
class GroovyCode {
  static void main(String[] args) {
    def impl = new Implementation()
    println impl.something()
  }
}
```

Running this produces:

```shell_session
groovy -cp . GroovyCode.groovy 
Interface's static method
```

Cool!
Wait, what?
We are creating a new _instance_ of `Implementation` and invoking the _instance_ method `String something()`.
Why is Groovy invoking the _static_ method with the same name,
especially since Java does not permit us to invoke `Implementation.something()` as that method is only part of `InterfaceWithStaticSomething`?

**I actually do not know the answer to this question!**
What I do know is that there must be ambiguity at the call site, where or what, again, I do not know.
The Groovy runtime decides to invoke `InterfaceWithStaticSomething.something()`.
If we use the Groovy Console to inspect the AST and view the bytecode generated from `GroovyCode`,
we see this:

```
public static varargs main([Ljava/lang/String;)V
 L0
  INVOKESTATIC GroovyCode.$getCallSiteArray ()[Lorg/codehaus/groovy/runtime/callsite/CallSite;
  ASTORE 1
 L1
  LINENUMBER 4 L1
  ALOAD 1
  LDC 0
  AALOAD
  LDC LImplementation;.class
  INVOKEINTERFACE org/codehaus/groovy/runtime/callsite/CallSite.callConstructor (Ljava/lang/Object;)Ljava/lang/Object; (itf)
  LDC LImplementation;.class
  INVOKESTATIC org/codehaus/groovy/runtime/ScriptBytecodeAdapter.castToType (Ljava/lang/Object;Ljava/lang/Class;)Ljava/lang/Object;
  CHECKCAST Implementation
  ASTORE 2
 L2
  ALOAD 2
  POP
 L3
  LINENUMBER 5 L3
  ALOAD 1
  LDC 1
  AALOAD
  LDC LGroovyCode;.class
  ALOAD 1
  LDC 2
  AALOAD
  ALOAD 2
  INVOKEINTERFACE org/codehaus/groovy/runtime/callsite/CallSite.call (Ljava/lang/Object;)Ljava/lang/Object; (itf)
  INVOKEINTERFACE org/codehaus/groovy/runtime/callsite/CallSite.callStatic (Ljava/lang/Class;Ljava/lang/Object;)Ljava/lang/Object; (itf)
  POP
 L4
  LINENUMBER 6 L4
  RETURN
  LOCALVARIABLE args [Ljava/lang/String; L0 L4 0
  LOCALVARIABLE impl LImplementation; L2 L4 2
  MAXSTACK = 4
  MAXLOCALS = 3
```

Near the bottom of `L3` we see the [`INVOKEINTERFACE`](https://docs.oracle.com/javase/specs/jvms/se11/html/jvms-6.html#jvms-6.5.invokeinterface) instruction being used twice.
At both occurrences, it is calling an interface method on `CallSite`, which is implemented with Groovy meta code.
These two instructions dynamically invoke `String something()` (on the `Implementation` object) and `println`.

Ultimately, whatever the ambiguity is that is causing `CallSite` to select the static method over the instance method, we need to remove it.
Instead of relying on the "dynamic sauce" of Groovy's runtime, we need to break through it.
We need the rigid static compilation that Java gives us.
We need `@CompileStatic`!

## Part III: @CompileStatic

Here is what Groovy's documentation says about `@CompileStatic`.

> This will let the Groovy compiler use compile time checks in the style of Java then perform static compilation, thus bypassing the Groovy meta object protocol.
>
> When a class is annotated, all methods, properties, files, inner classes, etc. of the annotated class will be type checked. When a method is annotated, static compilation applies only to items (closures and anonymous inner clsses _[sic]_) within the method.
>
> _Source: https://docs.groovy-lang.org/2.4.2/html/gapi/groovy/transform/CompileStatic.html_

This is exactly what we need,
and the really nice thing is that we only need to annotate the method `main(String[])`.
Let's do that and see what happens.

First, we annotate what we want to be statically compiled, which is `GroovyCode`'s `main(String[])`:

```groovy
class GroovyCode {
  @groovy.transform.CompileStatic
  static void main(String[] args) {
    Implementation impl = new Implementation()
    println impl.something()
  }
}
```

Next, let's run the Groovy code:

```shell_session
groovy -cp . GroovyCode.groovy 
Implementation's static method
```

Excellent.
We are now calling the method of our Java API that we originally set out to call.

Lastly, let's look at the bytecode using the Groovy Console again:

```
public static varargs main([Ljava/lang/String;)V
 L0
  LINENUMBER 4 L0
  NEW Implementation
  DUP
  INVOKESPECIAL Implementation.<init> ()V
  ASTORE 1
 L1
  ALOAD 1
  POP
 L2
  LINENUMBER 5 L2
  LDC LGroovyCode;.class
  ALOAD 1
  INVOKEVIRTUAL Implementation.something ()Ljava/lang/String;
  INVOKESTATIC org/codehaus/groovy/runtime/DefaultGroovyMethods.println (Ljava/lang/Object;Ljava/lang/Object;)V
  ACONST_NULL
  POP
 L3
  LINENUMBER 6 L3
  RETURN
  LOCALVARIABLE args [Ljava/lang/String; L0 L3 0
  LOCALVARIABLE impl LImplementation; L1 L3 1
  MAXSTACK = 2
  MAXLOCALS = 2
```

We can see there is less bytecode generated.
This makes sense as static compilation removes the [runtime metaprogramming](https://groovy-lang.org/metaprogramming.html#_runtime_metaprogramming).
Also, we can see that the two `INVOKEINTERFACE` instructions we noticed before have been replaced.
The first is now `INVOKEVIRTUAL` and invokes `Implementation.something()` -- the API call we have been after this whole time.
The second is now `INVOKESTATIC` and invokes the `println` method.
Both of which are more efficient that hopping through the call site metaprogramming that was there before.

## Conclusion

Sometimes you need to cut through dynamic invocation magic to ensure what you intend to happen actually happens.
The example discussed in this post was attempting to invoke an instance method that had the same name as a static method provided by a Java Interface.
Groovy's runtime metaprogramming invoked the static method instead of the instance method, even though the call site looked unambiguous.
We corrected the behavior of the Groovy code by using the `@CompileStatic` annotation to statically compile the call site.

_Fin_.

[^1]: https://docs.oracle.com/javase/specs/jvms/se11/html/jvms-4.html#jvms-4.6
