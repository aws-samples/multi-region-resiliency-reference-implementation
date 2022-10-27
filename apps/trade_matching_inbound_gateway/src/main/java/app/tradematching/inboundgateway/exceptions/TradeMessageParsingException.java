// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
package app.tradematching.inboundgateway.exceptions;

public class TradeMessageParsingException  extends Exception  {
    public TradeMessageParsingException(String info,Object...message)
    {
        super(info);
    }
    public TradeMessageParsingException(String info, Exception ex)
    {
        super(info, ex);
    }

}
