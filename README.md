# Understanding Java

> about .class

## How to run

`run.sh` 스크립트를 실행하면 compile, compile된 .class 파일을 decompile 후 decompile 한 결과를 txt로 저장하고 -verbose:class 옵션으로 실행한 결과를 txt로 저장하게 됩니다.
아래의 명령어로 실행합니다.

```sh
chmod +x ./run.sh
./run.sh
```

## 시작하기에 앞서

`java bytecode(.class)`를 디컴파일한 파일을 분석할 때 constant pool 이라는 용어가 나옵니다. 하지만 자바에서 constant pool 이라는 용어가 포함된 비슷한 용어들이 있어 혼용의 여지가 있어서 이 용어의 개념을 잡고 시작하겠습니다.

### Constant pool 정리

- **_String constant pool_**
  - 리터럴 문자열을 저장하는 영역입니다
  - **Heap** 내 위치합니다
- **_Class file constant pool_**
  - 클래스 파일의 리터럴 상수와 심볼릭 참조 저장하는 영역입니다
    - 심볼릭 참조(Symbolic Reference) : 자바에서 클래스를 참조할 때에 클래스의 주소를 직접 참조하는 방식이 아닌 클래스의 이름으로 참조하게 됩니다. Class file 내 constant pool에 #1, #2...#[n] 와 같은 형태로 저장되고 해당 심볼릭 참조를 찾아갑니다. 자세한 내용은 `.class`파일을 분석할 때 다루겠습니다.
  - **.class** 내 위치합니다
  - 참조링크
    - https://docs.oracle.com/javase/specs/jvms/se6/html/ClassFile.doc.html
    - https://blogs.oracle.com/javamagazine/post/java-class-file-constant-pool
  - https://www.baeldung.com/jvm-constant-pool
- **Runtime Constant pool**
  - Class Constant pool이 런타임 시 저장되는 영역입니다.
  - **Metaspace(Method Area)** 내 위치합니다.
  - 참조링크
    - https://docs.oracle.com/javase/specs/jvms/se6/html/ConstantPool.doc.html

## Main.class 분석

### Origin source

[src/Main.java](./src/Main.java)

- [Person](./src/Person.java) class는 int age, String name의 멤버를 가지고 있고 getter와 setter, all argument constructor 를 가지고 있습니다.
- [PersonWithStatic](./src/PersonWithStatic.java) class는 person class와 동일하며 country 라는 String타입의 static 멤버를 가지고 있습니다.

```java
package src;
public class Main {
    public static void main(String[] args) {
        int a = 40;
        System.out.println("Before new Person");
        Person alice = new Person(a, "alice");
        System.out.println("new Person : alice");
        Person bob = new Person(a, "bob");
        System.out.println("new Person : bob");
        System.out.println("alice hash : " + System.identityHashCode(alice));
        System.out.println("bob   hash : " + System.identityHashCode(bob));
        System.out.println("PersonWithStatic.country call " + PersonIncludeStatic.country);
    }
}
```

앞서 .class 내의 constant pool에는 class의 리터럴 상수와 사용되는 클래스의 심볼릭 참조가 저장된다고 언급하였습니다. 위의 코드에서 사용되는 클래스들과 리터럴 상수들을 사용되는 순서대로 나열하면 아래와 같습니다.

- "Before new Person"
- "alice"
- class Person
- "new Person : alice"
- "bob"
- "new Person : bob"
- "alice hash : "
- "bob hash : "
- "PersonIncludeStatic.country call "
- PersonIncludeStatic.country

실제로 `System.out.println`, `System.identityHashCode` 등의 사용으로 더 많은 클래스들이 class constant pool에 저장될 것입니다. 하지만 class constant pool 의 이해를 돕기 위해 테스트를 위해 작성한 클래스만 나열하였습니다. 이제 나열한 클래스들과 리터럴 상수들이 어떻게 class constant pool에 저장이 되는지 보겠습니다.

### Class constant pool

[Main.decompiled.txt](./log/Main.decompiled.txt)

시작하기에 앞서 Class constant pool을 분석하기 위해서 .class file의 구조와 형식을 이해할 필요가 있습니다. [Class file format](https://docs.oracle.com/javase/specs/jvms/se17/html/jvms-4.html#jvms-4.4) 의 내용을 모두 이해하고 넘어가면 좋겠지만 이번 단계에서는 Class constant pool분석을 위한 Constant Type과 Field descriptor에 대해서만 알아보겠습니다.

#### Constant Type

class constant pool의 각 항목들은 아래와 같은 구조를 가지고 있습니다.

```
cp_info {
    u1 tag;
    u1 info[];
}
```

tag에 사용되는 1byte의 값이 Constant Type 인데 사용되는 주요 타입은 아래와 같습니다. 실제로 컴파일에 사용된 자바 버전에 따라 추가되거나 지원되지 않는 경우가 있기 때문에 자세히 알아보려면 [Class file format](https://docs.oracle.com/javase/specs/jvms/se17/html/jvms-4.html#jvms-4.4)를 참조 바랍니다.
- Class
- Fieldref
- Methodref
- InterfaceMethodref
- String
- Integer
- Float
- Long
- Double
- NameAndType
- Utf8

#### Field descriptor

field descriptor는 Fieldref, Methodref 이 참조하고 있는 NameAndType에서 Type의 클래스, 인스턴스, 지역 변수의 유형을 나타내며 사용되는 종류는 아래와 같습니다. [FieldType](https://docs.oracle.com/javase/specs/jvms/se17/html/jvms-4.html#jvms-FieldType)

- `B` byte signed byte
- `C` char Unicode character
- `D` double double-precision floating-point value
- `F` float single-precision floating-point value
- `I` int integer
- `J` long long integer
- `L<classname>;` reference an instance of class `<classname>`
- `S` short signed short
- `Z` boolean true or false
- `[` reference one array dimension


#### class constant pool 분석
앞서 코드에서 사용한 리터럴 문자열인 `"Before new Person"`은 아래와 같이 저장이 되어 있습니다. main 함수에서 해당 문자열을 참조할 때 #13을 참조하게 되고 #13은 #14를 참조하고 있어 Utf8 문자일인 `"Before new Person"`을 참조할 수 있게 됩니다.
```java
Constant pool:
  ...
  #13 = String             #14
  #14 = Utf8               Before new Person
```

Person 클래스에 대한 참조는 Person class의 **경로**(***#21***)인 `src/Person`를 포함하고 있습니다. 또한 new 키워드를 사용해여 생성자를 호출하기 때문에 **생성자에 대한 정보**(**#25**)도 포함하고 있습니다. new 키워드로 Person 객체를 생성할 때 class loader가 해당 경로를 참조하여 Person 클래스의 java byte code를 Runtime constant pool에 적재하게 되는데 해당 내용은 코드 실행 부분에서 다시 다루겠습니다.
```java
  #5 = Utf8               <init>
  ...
  #21 = Class              #22            // src/Person
  #22 = Utf8               src/Person
  ...
  #25 = Methodref          #21.#26        // src/Person."<init>":(ILjava/lang/String;)V
  #26 = NameAndType        #5:#27         // "<init>":(ILjava/lang/String;)V
  #27 = Utf8               (ILjava/lang/String;)V
```

코드에서 사용되는 리터럴 문자열 들인 `"alice"`, `"new Person : alice"`, `"bob"`, `"new Person : bob"`, `"alice hash : "`, `"bob hash : "`, `"PersonIncludeStatic.country call "` 심볼릭 참조 입니다.
```java
  #23 = String             #24            // alice
  #24 = Utf8               alice
  ...
  #28 = String             #29            // new Person : alice
  #29 = Utf8               new Person : alice
  #30 = String             #31            // bob
  #31 = Utf8               bob
  #32 = String             #33            // new Person : bob
  #33 = Utf8               new Person : bob
  ...
  #67 = String             #68            // alice hash : \u0001
  #68 = Utf8               alice hash : \u0001
  #69 = String             #70            // bob   hash : \u0001
  #70 = Utf8               bob   hash : \u0001
  ...
  #72 = Utf8               PersonWithStatic.country call \u0001
```


`PersonIncludeStatic` class 의 static field 인 `country`에 대한 심볼릭 참조입니다. 객체를 new 키워드로 생성하지 않고 static field만 참조하고 있기 때문에 앞서 살펴본 Person 클래스에서 포함하고 있던 생성자 정보는 포함하고 있지 않고 `PersonIncludeStatic` class의 경로(***#44***, ***#46***)와  `country` field에 대한 참조 정보(***#45***)만 포함하고 있습니다. `country` 는 String 타입의 static field이기 때문에 해당 필드가 String 타입이라는 정보를 포함하고 있습니다(***#48***)
- `Ljava/lang/String`
    - `L` : 클래스에 대한 Field descriptor
    - `java/lang/String` : 참조하는 클래스인 String 클래스
```java
  #43 = Fieldref           #44.#45        // src/PersonIncludeStatic.country:Ljava/lang/String;
  #44 = Class              #46            // src/PersonIncludeStatic
  #45 = NameAndType        #47:#48        // country:Ljava/lang/String;
  #46 = Utf8               src/PersonIncludeStatic
  #47 = Utf8               country
  #48 = Utf8               Ljava/lang/String;
```



### function main

[Main.decompiled.txt](./log/Main.decompiled.txt)
[Java Opcode](https://en.wikipedia.org/wiki/List_of_Java_bytecode_instructions)

```
    Code:
      stack=4, locals=4, args_size=1
         0: bipush        40
         2: istore_1
         3: getstatic     #7                  // Field java/lang/System.out:Ljava/io/PrintStream;
         6: ldc           #13                 // String Before new Person
         8: invokevirtual #15                 // Method java/io/PrintStream.println:(Ljava/lang/String;)V
        11: new           #21                 // class src/Person
        14: dup
        15: iload_1
        16: ldc           #23                 // String alice
        18: invokespecial #25                 // Method src/Person."<init>":(ILjava/lang/String;)V
        21: astore_2
        22: getstatic     #7                  // Field java/lang/System.out:Ljava/io/PrintStream;
        25: ldc           #28                 // String new Person : alice
        27: invokevirtual #15                 // Method java/io/PrintStream.println:(Ljava/lang/String;)V
        30: new           #21                 // class src/Person
        33: dup
        34: iload_1
        35: ldc           #30                 // String bob
        37: invokespecial #25                 // Method src/Person."<init>":(ILjava/lang/String;)V
        40: astore_3
        41: getstatic     #7                  // Field java/lang/System.out:Ljava/io/PrintStream;
        44: ldc           #32                 // String new Person : bob
        46: invokevirtual #15                 // Method java/io/PrintStream.println:(Ljava/lang/String;)V
        49: getstatic     #7                  // Field java/lang/System.out:Ljava/io/PrintStream;
        52: aload_2
        53: invokestatic  #34                 // Method java/lang/System.identityHashCode:(Ljava/lang/Object;)I
        56: invokedynamic #38,  0             // InvokeDynamic #0:makeConcatWithConstants:(I)Ljava/lang/String;
        61: invokevirtual #15                 // Method java/io/PrintStream.println:(Ljava/lang/String;)V
        64: getstatic     #7                  // Field java/lang/System.out:Ljava/io/PrintStream;
        67: aload_3
        68: invokestatic  #34                 // Method java/lang/System.identityHashCode:(Ljava/lang/Object;)I
        71: invokedynamic #42,  0             // InvokeDynamic #1:makeConcatWithConstants:(I)Ljava/lang/String;
        76: invokevirtual #15                 // Method java/io/PrintStream.println:(Ljava/lang/String;)V
        79: getstatic     #7                  // Field java/lang/System.out:Ljava/io/PrintStream;
        82: getstatic     #43                 // Field src/PersonIncludeStatic.country:Ljava/lang/String;
        85: invokedynamic #49,  0             // InvokeDynamic #2:makeConcatWithConstants:(Ljava/lang/String;)Ljava/lang/String;
        90: invokevirtual #15                 // Method java/io/PrintStream.println:(Ljava/lang/String;)V
        93: return
```



## Class 로딩되는 과정 (run with -verbose:class)

[Main.log.txt](./log/Main.log.txt)

```bash
...
[0.016s][info][class,load] src.Main source: file:/Users/mk/Desktop/temp/java-opcode/build/
...
Before new Person
[0.017s][info][class,load] src.Person source: file:/Users/mk/Desktop/temp/java-opcode/build/
new Person : alice
new Person : bob
...
중략 (여기서 System.identityHashCode load)
...
alice hash : 622488023
bob   hash : 414493378
[0.023s][info][class,load] src.PersonIncludeStatic source: file:/Users/mk/Desktop/temp/java-opcode/build/
...
PersonWithStatic.country call KOR
```
