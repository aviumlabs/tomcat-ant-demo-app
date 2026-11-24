package com.aviumlabs.helloworld;

/**
 * Simple controller that delegates to {@link HelloService}.
 */
public final class HelloController {

    private final HelloService service = new HelloService();

    public String greet(String name) {
        return service.greet(name);
    }
}
