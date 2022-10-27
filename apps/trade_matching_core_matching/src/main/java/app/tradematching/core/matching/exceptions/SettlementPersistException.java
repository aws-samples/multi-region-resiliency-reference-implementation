// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
package app.tradematching.core.matching.exceptions;

public class SettlementPersistException extends Exception  {
    public SettlementPersistException(String info, Object...message)
    {
        super(info);
    }
    public SettlementPersistException(String info, Exception ex)
    {
        super(info, ex);
    }

}
