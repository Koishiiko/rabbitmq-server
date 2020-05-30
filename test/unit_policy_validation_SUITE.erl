%% The contents of this file are subject to the Mozilla Public License
%% Version 1.1 (the "License"); you may not use this file except in
%% compliance with the License. You may obtain a copy of the License at
%% https://www.mozilla.org/MPL/
%%
%% Software distributed under the License is distributed on an "AS IS"
%% basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
%% License for the specific language governing rights and limitations
%% under the License.
%%
%% The Original Code is RabbitMQ.
%%
%% The Initial Developer of the Original Code is GoPivotal, Inc.
%% Copyright (c) 2011-2020 VMware, Inc. or its affiliates.  All rights reserved.
%%

-module(unit_policy_validation_SUITE).

-include_lib("common_test/include/ct.hrl").
-include_lib("eunit/include/eunit.hrl").
-include_lib("rabbit_common/include/rabbit.hrl").

-compile(export_all).

all() ->
    [
      {group, parallel_tests}
    ].

groups() ->
    [
      {parallel_tests, [parallel], [
          alternate_exchange,
          dead_letter_exchange,
          dead_letter_routing_key,
          message_ttl,
          expires,
          max_length,
          max_length_bytes,
          max_in_memory_length
        ]}
    ].

%% -------------------------------------------------------------------
%% Test Cases
%% -------------------------------------------------------------------

alternate_exchange(_Config) ->
    requires_binary_value(<<"alternate-exchange">>).

dead_letter_exchange(_Config) ->
    requires_binary_value(<<"dead-letter-exchange">>).

dead_letter_routing_key(_Config) ->
    requires_binary_value(<<"dead-letter-routing-key">>).

message_ttl(_Config) ->
    requires_non_negative_integer_value(<<"message-ttl">>).

expires(_Config) ->
    requires_positive_integer_value(<<"expires">>).

max_length(_Config) ->
    requires_non_negative_integer_value(<<"max-length">>).

max_length_bytes(_Config) ->
    requires_non_negative_integer_value(<<"max-length-bytes">>).

max_in_memory_length(_Config) ->
    requires_non_negative_integer_value(<<"max-in-memory-bytes">>).

%%
%% Implementation
%%

requires_binary_value(Key) ->
    ?assertEqual(ok, rabbit_policies:validate_policy([
        {Key, <<"a.binary">>}
    ])),
    
    ?assertMatch({error, _, _}, rabbit_policies:validate_policy([
        {Key, 123}
    ])).

requires_positive_integer_value(Key) ->
    ?assertEqual(ok, rabbit_policies:validate_policy([
        {Key, 1}
    ])),
    
    ?assertEqual(ok, rabbit_policies:validate_policy([
        {Key, 1000}
    ])),

    ?assertMatch({error, _, _}, rabbit_policies:validate_policy([
        {Key, 0}
    ])),
    
    ?assertMatch({error, _, _}, rabbit_policies:validate_policy([
        {Key, -1}
    ])),
    
    ?assertMatch({error, _, _}, rabbit_policies:validate_policy([
        {Key, <<"a.binary">>}
    ])).

requires_non_negative_integer_value(Key) ->
    ?assertEqual(ok, rabbit_policies:validate_policy([
        {Key, 0}
    ])),
    
    ?assertEqual(ok, rabbit_policies:validate_policy([
        {Key, 1}
    ])),
    
    ?assertEqual(ok, rabbit_policies:validate_policy([
        {Key, 1000}
    ])),

    ?assertMatch({error, _, _}, rabbit_policies:validate_policy([
        {Key, -1}
    ])),
    
    ?assertMatch({error, _, _}, rabbit_policies:validate_policy([
        {Key, <<"a.binary">>}
    ])).
