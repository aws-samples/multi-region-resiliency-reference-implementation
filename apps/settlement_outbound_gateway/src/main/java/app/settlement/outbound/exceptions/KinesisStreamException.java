// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
package app.settlement.outbound.exceptions;

public class KinesisStreamException extends Exception  {
    public KinesisStreamException(String info,Object...message)
    {
        super(info);
    }

    public KinesisStreamException(String info,Exception ex)
    {
        super(info, ex);
    }
}
