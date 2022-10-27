// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
package app.tradematching.outbound.exceptions;

public class SettlementMessageParsingException extends Exception  {
    public SettlementMessageParsingException(String info, Object...message)
    {
        super(info);
    }
    public SettlementMessageParsingException(String info, Exception ex)
    {
        super(info, ex);
    }

}
