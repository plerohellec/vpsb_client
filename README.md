# VpsbClient

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'vpsb_client'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install vpsb_client

## Usage

TODO: Write usage instructions here

### Server-driven fio tests

After calling `setup` on a `VpsbClient::Manager`, request the next test for a trial:

```ruby
test = manager.next_fio_test(123)
```

This calls `GET /api/fio_tests/next_test?trial_id=123` using a user API token.
Admins can access any trial. Other users must be linked to the hoster owning
the trial, and the trial must be private, matching sysbench authorization.
The response is `{ "fio_test": { ... } }`, or `{ "fio_test": null }` when all
current definitions have results in the trial. The manager returns the nested
object or `nil`. Unknown trials return HTTP 404; missing trial ids return HTTP 400.

Each definition includes `test_id` (for example `random_read_4k`), `test_version`,
`access_pattern`, `direction`, `block_size_bytes`, and `prepare_command` and
`run_command` argument arrays. Substitute `%{filename}` and `%{size}` in each
argument with a local temporary filename and file size in bytes, then execute
the arrays directly without a shell. Run preparation before measurement.

Upload the result, then request the next test again until the manager returns
`nil`. Failed requests and uploads raise errors, not completion. Results are
matched by trial, text id, and version, so an interrupted task resumes from the
first missing result. This is not a work-claim API: run only one fio worker per
trial to avoid duplicate execution.

### Upload fio results

After calling `setup` on a `VpsbClient::Manager`, upload one measurement with:

```ruby
response = manager.create_fio_test(
    trial_id: 123,
    test_id: test.fetch('test_id'), test_version: test.fetch('test_version'),
    prepare_command: prepare_command,
    run_command: run_command,
    raw_data: JSON.parse(fio_json)
)
response.parsed_response.fetch('id')
```

This posts JSON to `/api/fio_tests` using the same user-token authorization.
Non-admin uploads require `trial_id`; hoster and plan are derived from the
authorized trial. Only admins can override `hoster_id`, `plan_id`, or
`storage_price_id`, or upload results without a trial. VPSB derives IOPS,
throughput in decimal MB/s, and total latency mean and p50/p95/p99 in microseconds
from `raw_data`; clients do not send these metrics. `raw_data` is a parsed JSON
object, not a JSON-encoded string. Workload access patterns are `random` or
`sequential`; directions are `read` or `write`. Incomplete or failed-job fio
results are rejected with HTTP 422.

Clients must submit the exact `test_id` and `test_version` returned by the
next-test API. Missing identity fields and unknown definitions are rejected with
HTTP 422; VPSB never infers an identity from workload parameters. Workload
direction, access pattern, and block size are derived from the identified
definition rather than stored on each result. The
executed preparation and measurement commands remain stored with each result.

Definitions and fio command templates live in VPSB's `FioTest::DEFINITIONS` and
`FioTest.next_test`. When changing commands or workload parameters, append a new
definition with an incremented integer version; retain the old definition and
its metadata unchanged so historical results remain readable. Only the highest
version of each test id is scheduled, provided it is enabled (default `true`).
Disabling the highest version disables the test without falling back to an older
version. Historical and disabled definitions still accept result uploads.
Changing shared command options requires new versions for all affected tests.

Deploy VPSB and run its identity migration first, then publish/update this gem
before deploying the server-driven uupdates runner. The migration backfills
existing results as version 1. uupdates still chooses the temporary directory
and a safe file size based on local free disk space.

## Contributing

1. Fork it ( https://github.com/[my-github-username]/vpsb_client/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
