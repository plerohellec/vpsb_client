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

### Upload fio results

After calling `setup` on a `VpsbClient::Manager`, upload one measurement with:

```ruby
response = manager.create_fio_test(
    trial_id: 123,
    direction: 'read', access_pattern: 'random', block_size_bytes: 4096,
    prepare_command: prepare_command,
    run_command: run_command,
    raw_data: JSON.parse(fio_json)
)
response.parsed_response.fetch('id')
```

This posts JSON to `/api/fio_tests` and requires an admin API token. `trial_id`,
`hoster_id`, `plan_id`, and `storage_price_id` are optional. VPSB derives IOPS,
throughput in decimal MB/s, and total latency mean and p50/p95/p99 in microseconds
from `raw_data`; clients do not send these metrics. `raw_data` is a parsed JSON
object, not a JSON-encoded string. Workload access patterns are `random` or
`sequential`; directions are `read` or `write`. Incomplete or failed-job fio
results are rejected with HTTP 422.

## Contributing

1. Fork it ( https://github.com/[my-github-username]/vpsb_client/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
