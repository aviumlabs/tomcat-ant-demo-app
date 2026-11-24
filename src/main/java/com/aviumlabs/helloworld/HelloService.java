package com.aviumlabs.helloworld;

/**
 * Plain business logic for the Hello World application.
 */
public final class HelloService {

    private static final String GREETING = "Hello, World! from Hello World";

    public HelloService() {
    }

    /**
     * @param name the name to greet, or {@code null} to greet the world.
     * @return a greeting message.
     */
    public static String greet(String name) {
        if (name != null && !name.isBlank()) {
            return "Hello, " + name + "! from Hello World";
        }
        return GREETING;
    }
}
