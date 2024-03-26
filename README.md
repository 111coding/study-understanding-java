# Understanding Java

## How to build
```sh
chmod +x ./run.sh
./run.sh
```

## 시작하기에 앞서
Constant pool 용어 정리
- String constant pool : **Heap**에 위치
- Class file constant pool : **.class** 내에 클래스 파일의 리터럴 상수와 심볼릭 참조 저장
    - Symbolic Reference : 자바에서 클래스를 참조할 때에 클래스의 주소를 직접 참조하는 방식이 아닌 클래스의 이름으로 참조. Class file 내 constant pool에 #1, #2...#[n] 와 같은 형태로 저장되고 해당 심볼링 참조를 찾아감
    - https://blogs.oracle.com/javamagazine/post/java-class-file-constant-pool
    - https://www.baeldung.com/jvm-constant-pool
- Runtime Constant pool : Class Constant pool에서 읽어온 상수 값, 클래스 메타데이터 저장


## Main.class 분석

### Origin source
[src/Main.java](./src/Main.java)
- [Person](./src/Person.java) class는 int age, String name의 멤버를 가지고 있고 getter와 setter, all arg constructor 포함
- [PersonWithStatic](./src/PersonWithStatic.java) class는 person class와 동일하며 static String country를 가지고 있음

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

### constant pool
[Main.decompiled.txt](./log/Main.decompiled.txt)
- [class file format](https://docs.oracle.com/javase/specs/jvms/se17/html/jvms-4.html#jvms-4.4)

```java
Constant pool:
  ...
  #13 = String             #14            // Before new Person
  #14 = Utf8               Before new Person
  ...
  #21 = Class              #22            // src/Person
  #22 = Utf8               src/Person
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
  #43 = Fieldref           #44.#45        // src/PersonIncludeStatic.country:Ljava/lang/String;
  #44 = Class              #46            // src/PersonIncludeStatic
  #45 = NameAndType        #47:#48        // country:Ljava/lang/String;
  #46 = Utf8               src/PersonIncludeStatic
  #47 = Utf8               country
  #48 = Utf8               Ljava/lang/String;
  ...
  #67 = String             #68            // alice hash : \u0001
  #68 = Utf8               alice hash : \u0001
  #69 = String             #70            // bob   hash : \u0001
  #70 = Utf8               bob   hash : \u0001
  #71 = String             #72            // PersonWithStatic.country call \u0001
  #72 = Utf8               PersonWithStatic.country call \u0001
  ...
```


### function main
[Main.decompiled.txt](./log/Main.decompiled.txt)
- [Java Opcode]( https://en.wikipedia.org/wiki/List_of_Java_bytecode_instructions)
TODO
 
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





