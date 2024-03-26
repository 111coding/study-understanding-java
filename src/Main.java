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
