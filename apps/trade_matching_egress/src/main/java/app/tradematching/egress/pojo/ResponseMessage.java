// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
package app.tradematching.egress.pojo;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import lombok.Builder;
import lombok.Data;
import lombok.extern.jackson.Jacksonized;

@Jacksonized
@Data
@Builder
@JsonIgnoreProperties(ignoreUnknown = true)
public class ResponseMessage {
	private String id;
	private long timestamp;
	private String status;
	private String description;
	private String destination;
	private String message;
}
