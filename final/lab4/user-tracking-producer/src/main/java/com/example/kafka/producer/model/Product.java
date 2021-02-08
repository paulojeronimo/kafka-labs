package com.example.kafka.producer.model;

import com.example.kafka.producer.enums.Color;
import com.example.kafka.producer.enums.ProductType;
import com.example.kafka.producer.enums.DesignType;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class Product {
    private Color color;
    private ProductType type;
    private DesignType designType;
}
