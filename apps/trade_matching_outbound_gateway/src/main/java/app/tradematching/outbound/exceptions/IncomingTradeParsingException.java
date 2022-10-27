// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
package app.tradematching.outbound.exceptions;

public class IncomingTradeParsingException extends Exception{
    public IncomingTradeParsingException(String errorMessage){
        super(errorMessage);
    }
}