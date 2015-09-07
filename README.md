# CFcmd

A command-line interface for managing Rackspace CloudFiles based on the interface of [s3cmd](https://github.com/s3tools/s3cmd)

This is a work in progress and is missing a lot of functionality.

## Installation

There is no point in releasing a gem until the API is more complete. For now, you'll have to build it yourself:

   $ git clone git@github.com:lyconic/cfcmd.git  
   $ cd cfcmd  
   $ bin/setup  
   $ bundle exec rake install

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment. Run `bundle exec cfcmd` to use the code located in this directory, ignoring other installed copies of this gem.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/lyconic/cfcmd/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
