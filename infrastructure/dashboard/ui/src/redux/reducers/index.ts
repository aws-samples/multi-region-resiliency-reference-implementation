// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import {combineReducers, Reducer} from 'redux';
import {History} from 'history';
import {connectRouter} from 'connected-react-router';
import {ReduxState} from '../../interfaces';
import {ActionTypes} from "../actions";

let initialState: ReduxState = {
  executionId: ""
};

export const approtationReducer: Reducer<ReduxState> = (state = initialState, action) => {

  switch(action.type) {
    case ActionTypes.STORE_EXECUTION_ID: {
      return {
        ...state,
        executionId: action.executionId
      };
    }

  }
  return state;
};

const createRootReducer = (history: History) => combineReducers({
  router: connectRouter(history),
  approtationReducerState: approtationReducer
});

export default createRootReducer;
export type RootState = ReturnType<typeof createRootReducer>;