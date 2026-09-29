package com.example;

import com.sun.net.httpserver.HttpExchange;
import com.sun.net.httpserver.HttpServer;

import java.io.IOException;
import java.io.OutputStream;
import java.net.InetSocketAddress;

public class App {

    public static void main(String[] args) throws Exception {
        HttpServer server = HttpServer.create(
            new InetSocketAddress("0.0.0.0", 8080),
            0
        );

        server.createContext("/", App::handle);

        server.start();
    }

    private static void handle(HttpExchange exchange) throws IOException {
        if (!exchange.getRequestURI().getPath().equals("/")) {
            exchange.sendResponseHeaders(404, -1);
            exchange.close();
            return;
        }

        String response = String.format(
            "{\"application\":\"enterprise-hardened-java-test\",\"runtime\":\"java\",\"version\":\"%s\",\"uid\":\"%s\"}",
            System.getProperty("java.version"),
            System.getProperty("user.name")
        );

        byte[] payload = response.getBytes();

        exchange.getResponseHeaders().set(
            "Content-Type",
            "application/json"
        );

        exchange.sendResponseHeaders(200, payload.length);

        try (OutputStream output = exchange.getResponseBody()) {
            output.write(payload);
        }
    }
}