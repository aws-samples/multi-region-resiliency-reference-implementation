// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
package app.tradematching.generator.interfaces;

import app.tradematching.generator.pojo.Trade;

import java.util.List;

public interface IGenerator {
    List<Trade> generate(int quantity);
}
