// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
package app.tradematching.generator.enums;

public enum TradePrice {
    A(5.0), B(7.8), C(12.0), D(18.5), E(41.2), F(26.8);

    private double numVal;

    TradePrice(double numVal) {
        this.numVal = numVal;
    }

    public double getNumVal() {
        return numVal;
    }

}
