// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

export default class ApiHandler {

  api_ep : string
  private authToken: string;

  private _resources: string[];

  public static requester: Boolean = false;
  public static reviewer: Boolean = false;
  public static auditor: Boolean = false;

  constructor(api_url: string, authToken: string, resources:string[]) {
      this.api_ep = api_url;
      this.authToken = authToken;
      this._resources = resources;
  }

  private get_resource_url(resource_name: string) {
      return this.api_ep + "/" + resource_name
  }

  public to_url_params(params: KeyValue<string,string>[]): string {
      let result = ""
      params.forEach(param => {
         result+=param.key.concat("=").concat(param.value).concat("&")
      })
      return result.slice(0, -1);
  }

  public async get_authorized_resource<T>(resource_name: string, apiMethod:ApiMethod, body_params?:any, url_params?:KeyValue<string,string>[]) : Promise<T> {

    if (this._resources.indexOf(resource_name)>-1) {

      let url = this.get_resource_url(resource_name)
      if (url_params) {
        let url_params_text = this.to_url_params(url_params)
        if (url_params_text !== "") {
          url = url + "?" + this.to_url_params(url_params)
        }
      }

      console.log("URL : " + url)
      const response = await fetch(url,
          {
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
              'x-api-key': this.authToken
            },
            method: apiMethod,
            body: body_params==null? null : JSON.stringify(body_params),
            mode: 'cors'
          });
      console.log("RESPOND : " + await response.json());
      if (!response.ok) {
        const error_message:string = await response.json();
        throw new Error(error_message);
      }
      return response.json() as Promise<T>;
    }
    else {
      console.log("error calling get_resource, resource name not configured!");
      return Promise.reject<T>();
    }
  }

  public async get_resource<T>(resource_name: string, apiMethod:ApiMethod, body_params?:any, url_params?:KeyValue<string,string>[]) : Promise<T> {

    if (this._resources.indexOf(resource_name)>-1) {
      //let url = this.api_ep
      let url = this.get_resource_url(resource_name)
      if (url_params) {
        let url_params_text = this.to_url_params(url_params)
        if (url_params_text !== "") {
          url = url + "?" + this.to_url_params(url_params)
        }
      }
      const response = await fetch(url,
          {
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
              'x-api-key': this.authToken
            },
            method: apiMethod,
            body: body_params == null ? null : JSON.stringify(body_params),
            mode: 'cors'
          });
      if (!response.ok) {
        const error_message: string = await response.json();
        throw new Error(error_message);
      }
      return response.json() as Promise<T>;
    }
    else {
      console.log("error calling get_resource, resource name not configured!");
      return Promise.reject<T>();
    }
  }
}

export enum ApiMethod  {
  POST="POST",
  GET="GET",
  PUT="PUT",
  DELETE="DELETE"
}

export type KeyValue<T, U> = {
  key: T,
  value: U,
};

