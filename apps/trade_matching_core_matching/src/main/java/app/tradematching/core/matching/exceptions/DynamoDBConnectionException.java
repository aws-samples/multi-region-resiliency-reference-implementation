// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
package app.tradematching.core.matching.exceptions;

public class DynamoDBConnectionException  extends Exception  {
    public DynamoDBConnectionException(String info,Object...message)
    {
        super(info);
    }

    public DynamoDBConnectionException(String info,Exception ex)
    {
        super(info, ex);
    }
}
