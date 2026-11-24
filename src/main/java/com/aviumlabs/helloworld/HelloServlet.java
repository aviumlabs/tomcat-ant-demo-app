package com.aviumlabs.helloworld;

import java.io.IOException;
import java.io.PrintWriter;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Entry point for the Hello World application.
 *
 * <p>Exposes two endpoints:</p>
 * <ul>
 *   <li>{@code GET /} - returns the default greeting.</li>
 *   <li>{@code GET /hello} - returns the default greeting.</li>
 *   <li>{@code GET /hello/name} - returns a greeting for the requested name.</li>
 * </ul>
 */
@WebServlet(urlPatterns = {"/", "/hello"})
public class HelloServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HelloController controller = new HelloController();

        String name = req.getParameter("name");
        String message = controller.greet(name);

        resp.setContentType("text/plain; charset=UTF-8");
        PrintWriter out = resp.getWriter();
        out.println(message);
    }
}
