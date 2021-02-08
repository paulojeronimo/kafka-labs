package com.example.kafka.producer;

import com.example.kafka.producer.enums.UserId;
import com.example.kafka.producer.model.Event;
import com.example.kafka.producer.model.Product;
import com.example.kafka.producer.model.User;
import com.github.javafaker.Faker;
import com.example.kafka.producer.enums.Color;
import com.example.kafka.producer.enums.ProductType;
import com.example.kafka.producer.enums.DesignType;

public class EventGenerator {

    private Faker faker = new Faker();

    public Event generateEvent() {
        return Event.builder()
                .user(generateRandomUser())
                .product(generateRandomObject())
                .build();
    }

    private User generateRandomUser() {
        return User.builder()
                .userId(faker.options().option(UserId.class))
                .username(faker.name().lastName())
                .dateOfBirth(faker.date().birthday())
                .build();
    }

    private Product generateRandomObject() {
        return Product.builder()
                .color(faker.options().option(Color.class))
                .type(faker.options().option(ProductType.class))
                .designType(faker.options().option(DesignType.class))
                .build();
    }
}
